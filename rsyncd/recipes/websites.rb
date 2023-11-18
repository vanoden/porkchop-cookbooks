dirs = []

sites = data_bag('sites');
sites.each() do |key|
	site = data_bag_item('sites',key);

	directory "/export/web_content/"+site['name'] do
		action	:create
		recursive	true
		group	"web_content"
		mode	"0775"
	end

	dirs << site
end

service "rsyncd"

template "/etc/rsyncd.conf" do
	variables ({
		:directories	=> dirs
	})
	notifies :restart,"service[rsyncd]"
end
