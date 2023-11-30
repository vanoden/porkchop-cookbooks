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
				recursive: true
			end

			_command = "/usr/bin/aws s3 cp s3://" + source + " " + deploy_path
			execute 'pull tarball' do
				command _command
			end

			if ::File.exist?(deploy_path+"/"+site['deploy']['tarball'])
				_command = "cd "+deploy_path+"; /usr/bin/tar zxvf "+site['deploy_tarball']
				execute 'unpack tarball' do
					command _command
				end
			else
				log "File not found"
			end
		end
	end
end
