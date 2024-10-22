template "/etc/rsyslog.conf" do
	action	:create
	source	"client.conf"
	notifies :restart, 'service[rsyslog]'
end

service "rsyslog" do
    action  :enable
end
