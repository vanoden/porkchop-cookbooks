nodes = data_bag('nodes');
_content = '';

nodes.each do |name|
	node = data_bag_item('nodes',name)

	_content += node['ip_address'];
	_content += "\t"+node['hostname']
	if node.has_key?('alias')
		_content += " "+node['alias'].join(" ");
	end
	_content += "\n"
end

file "/etc/hosts" do
	action	:create
	content	_content
end
