template "/etc/init.d/firewall" do
	source	"web-server.erb"
	mode	"0700"
end
