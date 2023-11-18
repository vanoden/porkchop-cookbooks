http_version = [ "2.4.6" ]

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
