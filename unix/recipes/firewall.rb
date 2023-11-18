nodes = begin
	data_bag('nodes')
	rescue Net::HTTPServerException, Chef::Exceptions::InvalidDataBagPath
		[]
	end

# Group nodes by service
apache_servers = []
nodes.each() do |name|
	host = data_bag_item('nodes',name)
	if (host['role'] == 'apache')
		apache_servers.push(host['ip_address'])
	end
end

log "roles" do
	message apache_servers.inspect
end

if node.has_key?('name')
	me = data_bag_item('nodes',node[:name])

	log "role" do
		message "Node: "+me.inspect
		level	:info
	end
end

if (node.has_key?('iptables') && node[:iptables])
then
	template "/etc/init.d/firewall" do
		action  :create
		mode	'0755'
		owner	'root'
		variables ({
			:me => me,
			:apache_servers => apache_servers
		})
		notifies :restart,"service[firewall]"
	end

	service "firewall" do
		action	[:enable,:start]
	end
end
