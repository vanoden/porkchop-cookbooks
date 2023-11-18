template "/etc/openvpn/server.conf" do
	action	:create
	source	"server.conf"
	owner	'root'
	mode	'0440'
	notifies :restart,"service[openvpn]"
end

service "openvpn" do
	pattern 'openvpn@server.service'
	action	:start
end
