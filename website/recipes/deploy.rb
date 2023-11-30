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
	elsif site.has_key?('deploy_bucket')
		log "Tarball deploy "+site['deploy_bucket']

		deploy_path = deploy_base+"/"+site['name'];

		directory deploy_path do
			action :create
			recursive: true
		end

		_command = "/usr/bin/aws s3 cp s3://" + site['deploy_bucket']+"/"+site['deploy_tarball']+" "+deploy_path
		execute 'pull tarball' do
			command _command
		end
		_command = "cd "+deploy_path+"; /usr/bin/tar zxvf "+site['deploy_tarball']
		execute 'unpack tarball' do
			command _command
		end
	end
end
