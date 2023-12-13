directory "/etc/httpd/sites.d"

sites = data_bag('sites');
sites.each do |id|
	site = data_bag_item('sites',id);

	type = site['type']

	# Website Base Folder
	directory "/var/www/"+site['name'] do
		action  :create
		owner   'apache'
	end

	# Website Server Logs
	directory "/var/log/httpd/"+site['name'] do
		action	:create
	end

	# Website Application Log
	directory "/var/lib/porkchop/api/"+site['name'] do
		action	:create
		owner	"apache"
		recursive	true
	end

	# Website Cache Folder
	directory "/var/lib/porkchop/"+site['name'] do
		action	:create
		owner	"apache"
		recursive true
	end

	# Website Server Configuration
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
