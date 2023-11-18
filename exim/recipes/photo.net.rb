conf_dir="/etc/exim"

cookbook_file "#{conf_dir}/photonet.cdb" do
	action	:create
	source	"photonet.cdb.dist"
end

cookbook_file "#{conf_dir}/sa-exim_short.conf"

directory "#{conf_dir}/virtualdomains"

cookbook_file "#{conf_dir}/virtualdomains/photography.com"

cookbook_file "#{conf_dir}/virtualdomains/scalabledisplay.com"

cookbook_file "#{conf_dir}/virtualdomains/luminalpath.com"

cookbook_file "#{conf_dir}/virtualdomains/photo.net"

cookbook_file "#{conf_dir}/sa-exim.conf"

cookbook_file "#{conf_dir}/accept_how_many"

cookbook_file "#{conf_dir}/deny_senders"

template "/etc/default/exim" do
	action	:create
	source	"exim.defaults"
end
