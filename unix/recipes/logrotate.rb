template /etc/logrotate.d/porkchop do
	source 'logrotate.erb'
	owner 'root'
	group 'root'
	mode '0755'
end
