yum_package "haproxy"

service 'haproxy' do
	action	:enable
end
