install_path = "/etc/ssl/private"
domains = ["misfittoys.band","powerup.band","limeyspub.com"]

directory install_path do
	action		:create
	recursive	true
	owner		'root'
	group		'root'
	mode		'0700'
end

domains.each do |domain|
	cookbook_file install_path+"/"+domain+".pem"
		action	:create
		owner	'root'
		group	'root'
		mode	'0600'
	end
end
