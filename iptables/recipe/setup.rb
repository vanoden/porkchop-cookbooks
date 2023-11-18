service "iptables" do
	action	[:stop,:disable]
end

service "iptables6" do
	action	[:stop,:disable]
end
