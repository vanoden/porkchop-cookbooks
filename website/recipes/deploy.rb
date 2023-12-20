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

			tarball_path = deploy_base+"/"+site['deploy']['Tarball']
			deploy_path = deploy_base+"/"+site['name'];
			live_path = site['porkchop']['BASE'];
			backup_path = site['porkchop']['BASE']+".old";

			# Where the tarball is downloaded to
			log "TARBALL PATH: "+tarball_path
			# Where the tarball is extracted to
			log "DEPLOY PATH: "+deploy_path
			# Where the live site is
			log "LIVE PATH: "+live_path
			# Where the live site is backed up to
			log "BACKUP PATH: "+backup_path

			directory deploy_path do
				action :create
				recursive true
			end

			file tarball_path do
				action :delete
				compile_time true
				only_if { ::File.exist?(tarball_path) }
			end

			_command = "/usr/bin/aws s3 cp s3://" + source + " " + tarball_path + ">> /tmp/download.log 2>&1"
			tries = 0
			max_tries = 3
			while tries < max_tries do
				tries += 1
				execute 'pull tarball' do
					command _command
					compile_time true
				end
				chef_sleep "waitforfile" do
					seconds 5
					not_if { ::File.exist?(tarball_path) }
				end
				if (::File.exist?(tarball_path))
					break
				end
			end

			if ::File.exist?(tarball_path)
				_command = "/usr/bin/tar zxvf "+tarball_path

				directory deploy_path do
					action :delete
					recursive true
					only_if { ::File.exist?(deploy_path) }
				end

				archive_file tarball_path do
					destination deploy_path
				end

				file tarball_path do
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

				log "Deleting old backup "+backup_path do
					only_if { ::File.exist?(backup_path) }
					only_if { ::File.exist?(deploy_path) }
					only_if { ::File.exist?(deploy_path+"/config/config.php") }
				end
		
				ruby_block "rotate out backup" do
					block do
						::FileUtils.rm_rf(backup_path)
					end
					only_if { ::File.exist?(backup_path) }
					only_if { ::File.exist?(deploy_path) }
					only_if { ::File.exist?(deploy_path+"/config/config.php") }
				end
		
				log "Backing up current site "+live_path do
					only_if { ::File.exist?(live_path) }
					only_if { ::File.exist?(deploy_path) }
					only_if { ::File.exist?(deploy_path+"/config/config.php") }
				end
		
				ruby_block "backup current site" do
					block do
						::FileUtils.mv(live_path,backup_path)
					end
					only_if { ::File.exist?(live_path) }
					only_if { ::File.exist?(deploy_path) }
					only_if { ::File.exist?(deploy_path+"/config/config.php") }
				end
		
				log "Deploying new site to "+live_path do
					only_if { ::File.exist?(deploy_path) }
				end
		
				ruby_block "deploy new site" do
					block do
						::FileUtils.mv(deploy_path,live_path)
					end
					only_if { ::File.exist?(deploy_path) }
				end
			else
				log "File '"+tarball_path+"' not found"
			end
		end
	end
end

service 'httpd' do
	action :nothing
end
