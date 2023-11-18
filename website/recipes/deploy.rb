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
	end
end
