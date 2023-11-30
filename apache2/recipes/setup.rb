http_version = node['http_version']

log "Node"
log node
log "Site"
#log site

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

#directory node['httpd_conf_d'] do
#	action	:create
#	mode	"0755"
#end
