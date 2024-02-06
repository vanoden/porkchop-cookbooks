template "/etc/haproxy/haproxy.cfg" do
	source  'haproxy.cfg'
	owner   'root'
	group   'root'
	action  :create
	notifies :restart,'service[haproxy]'
end

service 'haproxy' do
	action	[:start]
end
