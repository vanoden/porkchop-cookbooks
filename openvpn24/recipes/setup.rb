yum_package 'openvpn' do
	action	:install
	version	'2.4.6-1.el7'
end

yum_package 'easy-rsa' do
	action	:install
end

service 'openvpn' do
	pattern 'openvpn@server.service'
	action	:enable
end
