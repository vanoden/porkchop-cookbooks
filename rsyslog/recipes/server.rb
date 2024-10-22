template "/etc/rsyslog.conf" do
	action	:create
	source	"server.conf"
	notifies :restart, 'service[rsyslog]'
end

service "rsyslog" do
    action  :enable
end
