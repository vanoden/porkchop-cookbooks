php_postfix = node["php_version"]
php_postfix = "82"
php_postfix = "82"

packages = ["php","php-cli","php-mysqlnd","php-xml","php-gd","php-pdo","php-mbstring","php-pear","php-imagick","php-yaml"]
if (node['platform'].eql?('raspbian'))
	packages.push("devel","process");
end

package "php#{php_postfix}" do
	action	:install
	#version	php_version
	#options	['--allowerasing'] 
end

packages.each do |package|
	package "php#{php_postfix}-#{package}" do
		action	:install
		#version	php_version
		#options	['--allowerasing'] 
	end
end
