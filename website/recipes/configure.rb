directory "/etc/httpd/sites.d"

sites = data_bag('sites');
sites.each do |id|
	site = data_bag_item('sites',id);

	type = site['type']

	directory "/var/www/"+site['name'] do
		action  :create
		owner   'apache'
	end

	if type == 'wordpress'
		template "/etc/httpd/sites.d/"+site['name']+".conf" do
			source "wordpress.apache.conf"
			variables ({
				:site		=> site
			})
			action	:create
		end
		template site['base']+"/wp-config.php" do
			source "wordpress.php.conf"
			variables ({
				:site		=> site
			})
			action	:create
		end
	elsif type == 'porkchop'
		template "/etc/httpd/sites.d/"+site['name']+".conf" do
			source porkchop.apache.conf
			variables ({
				:site		=> site
			})
			action	:create
		end

		directory site['base']+"/core" do
			action	:create
			owner	'apache'
		end

		template site['base']+"/core/config.php" do
			source porkchop.php.conf
			variables ({
				:site		=> site
			})
			action	:create
		end
	elsif type == 'rootseven'
		template "/etc/httpd/sites.d/"+site['name']+".conf" do
			source static.apache.conf
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
