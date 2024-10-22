directory "/etc/httpd/sites.d"

template "/etc/rsyslog.conf"
	action	:create
	source	"server.conf"
	notifies :restart, 'service[rsyslog]'
end

service "rsyslog" do
    action  :enable
end
