deploy_base = '/tmp/deploy';

sites = data_bag('sites');
sites.each do |id|
	site = data_bag_item('sites',id);

	type = site['type']

	if site.has_key?('git_repo')
		log "Clone repository "+site['git_repo']
	elsif site.has_key?('rsync_service')
		log "Rsync service "+site['rsync_service']

		_command = "/bin/rsync -av --exclude=node_modules/ --exclude=.git/ --exclude=.gitignore "+site['rsync_service']+"/ "+site['base']+"/"
		execute 'pull site' do
			command	_command
		end
	elsif site.has_key?('deploy')
		if site['deploy'].has_key?('S3Bucket')
			source = site['deploy']['S3Bucket']+"/"+site['deploy']['Tarball']
			log "Tarball deploy "+source

			deploy_path = deploy_base+"/"+site['name'];

			directory deploy_path do
				action :create
				recursive true
			end

			_command = "/usr/bin/aws s3 cp s3://" + source + " " + deploy_base
			execute 'pull tarball' do
				command _command
			end

			if ::File.exist?(deploy_base+"/"+site['deploy']['Tarball'])
				_command = "cd "+deploy_path+"; /usr/bin/tar zxvf "+deploy_base+"/"+site['deploy']['Tarball']

				execute "unpack tarball "+deploy_base+"/"+site['deploy']['Tarball'] do
					command _command
				end

				file deploy_base+"/"+site['deploy']['Tarball'] do
					action :delete
				end

				template node["http_conf_d"]+"/"+site['name']+".conf" do
					source "porkchop.apache.conf"
					variables ({
						:site       => site
					})
					action  :create
				end

				directory deploy_path+"/config" do
					action  :create
					owner   'apache'
				end

				template deploy_path+"/config/config.php" do
					source "porkchop.php.conf"
					variables ({
						:site       => site
					})
					action  :create
				end
			else
				log "File '"+deploy_path+"/"+site['deploy']['Tarball']+"' not found"
			end
		end

		log "Deleting old backup "+site['porkchop']['BASE']+".old" do
			only_if { ::File.exist?(site['porkchop']['BASE']+".old") }
		end

		ruby_block "rotate out backup" do
			block do
				::FileUtils.rm_rf(site['porkchop']['BASE']+".old")
			end
			only_if { ::File.exist?(site['porkchop']['BASE']+".old") }
		end

		log "Backing up current site "+site['porkchop']['BASE'] do
			only_if { ::File.exist?(site['porkchop']['BASE']) }
			only_if { ::File.exist?(deploy_path) }
			only_if { ::File.exist?(deploy_path+"/config/config.php") }
		end

		ruby_block "backup current site" do
			block do
				::FileUtils.mv(site['porkchop']['BASE'],site['porkchop']['BASE']+".old")
			end
			only_if { ::File.exist?(site['porkchop']['BASE']) }
			only_if { ::File.exist?(deploy_path) }
			only_if { ::File.exist?(deploy_path+"/config/config.php") }
		end

		log "Deploying new site to "+site['porkchop']['BASE'] do
			only_if { ::File.exist?(deploy_path) }
		end

		ruby_block "deploy new site" do
			block do
				::FileUtils.mv(deploy_path,site['porkchop']['BASE'])
			end
			only_if { ::File.exist?(deploy_path) }
		end
	end
end

service 'httpd' do
	action :restart
end