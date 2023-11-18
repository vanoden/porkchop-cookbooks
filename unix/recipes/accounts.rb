log 'msg_env' do
	message "Environment: "+node.chef_environment
	level	:info
end

#log 'more_env' do
#	message "Description: "+node[:description]
#	level	:info
#end

file "/etc/sudoers.d/91-chef" do
	action	:create
	content	"%sysadmin	ALL=(ALL)	NOPASSWD: ALL\n"
	mode "0644"
end

if node.key?('groups') then
	node[:groups].each do |os_group|
		group os_group[:name] do
			gid	os_group[:id]
			action	:create
		end
	end
end

groups = {}

accounts = data_bag('accounts');
accounts.each do |login|
	_user = data_bag_item('accounts',login)

	if ! _user.key?('home')
		log 'home_err' do
			message "home not defined"
			level	:error
		end
	elsif ! _user.key?('name')
		log 'name_err' do
			message "name not defined"
			level	:error
		end
	else
		home_dir = _user[:home]
		user_id = _user[:uid]
		group_id = _user[:gid]
		user_name = _user[:name]

		user user_name do
			comment _user[:comment]
			uid	user_id
			gid	group_id
			home	home_dir
			manage_home	true
			password	_user[:password]
		end

		directory 'home' do
			path	home_dir
			owner	user_id
			group	group_id
		end

		cookbook_file '.bashrc' do
			path	home_dir + "/.bashrc";
			owner	user_id
			group	group_id
			action	:create
		end

		cookbook_file '.bash_profile' do
			path	home_dir + '/.bash_profile';
			owner	user_id
			group	group_id
			action	:create
		end

		cookbook_file '.bash_logout' do
			path	home_dir + '/.bash_logout';
			owner	user_id
			group	group_id
			action	:create
		end

		if _user.key?('groups')
			if _user[:groups].kind_of? Array
				_user[:groups].each() do |_group|
					if ! groups[_group].kind_of? Array
						groups[_group] = []
					end

					groups[_group].push(user_name)
				end
			end
		end

		if _user.key?('ssh_key')
			directory home_dir+'/.ssh' do
				user	user_id
				group	group_id
				action	:create
			end

			if _user[:ssh_key].kind_of? Array
				file home_dir + '/.ssh/authorized_keys' do
					content	_user[:ssh_key].join("\n")
					owner	user_id
					group	group_id
					mode	'0644'
				end
			else
				file home_dir + '/.ssh/authorized_keys' do
					content	_user[:ssh_key]
					owner	user_id
					group	group_id
					mode	'0644'
				end
			end
		end
	end
end

groups.each() do |name,_group|
	log "group:" do
		message "Group: "+name+" includes "+groups[name].join(",")
		level	:info
	end
	group name do
		append true
		members	groups[name]
	end
end

if node.key?('sudoers')
	template '/etc/sudoers.d/91-chef' do
		source	'sudoers.erb'
	end
end
