http_version = node['http_version']

log "Node HTTP Config Path"
log node['http_conf_d']

log 'platform' do
	message "Platform: "+node['platform']
	level	:info
end

if node['platform'].eql?('raspbian')
	package "apache2" do
		action :install
	end

else
	package "httpd" do
		action	:install
		version	http_version
	end
	package "httpd-tools" do
		action	:install
		version	http_version
	end
end

template "/etc/httpd/conf/httpd.conf" do
	action	:create
end

directory node['http_conf_d'] do
	action	:create
	mode	"0755"
end
