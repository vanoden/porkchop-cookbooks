_node = data_bag_item('nodes',node['name']);

log "Run" do
	message "Running chef-solo role "+_node['role']
	level	:info
end

template "/usr/sbin/run_chef_solo.sh" do
	mode "0750"
	action	:create
	variables ({
		:personality	=> _node['role']
	})
end

file "/etc/cron.d/chef" do
	action	:create
	content	"*/5 * * * * root /usr/sbin/run_chef_solo.sh > /var/log/chef.log\n"
end
