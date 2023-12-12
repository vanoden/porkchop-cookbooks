directory "/etc/httpd/sites.d"

sites = data_bag('sites');
sites.each do |id|
	site = data_bag_item('sites',id);

	type = site['type']

	directory "/var/www/"+site['name'] do
		action  :create
		owner   'apache'
	end

	directory "/var/log/httpd/"+site['name'] do
		action	:create
	end

	if type == 'porkchop'
		template "/etc/httpd/sites.d/"+site['name']+".conf" do
			source porkchop.apache.conf
			variables ({
				:site		=> site
			})
			action	:create
		end
	elsif type == 'static'
		template "/etc/httpd/sites.d/"+site['name']+".conf" do
			source static.apache.conf
			variables ({
				:site		=> site
			})
			action	:create
		end
	end
end
