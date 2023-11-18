template "/etc/exim/exim.conf" do
	action	:create
	source	exim.conf.photo
	mode	"0444"
end
