directory "/etc/httpd/sites.d"

template "/etc/rsyslog.conf"
	action	:create
	source	"client.conf"
	notifies :restart, 'service[rsyslog]'
end

service "rsyslog" do
    action  :enable
end
