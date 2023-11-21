php_postfix = node["php_version"]
php_version = nil

package "php#{php_postfix}" do
	action	:install
	version	php_version
end

package "php#{php_postfix}-mysqlnd" do
	action	:install
	version	php_version
end
package "php#{php_postfix}-xml" do
	action	:install
	version	php_version
end
package "php#{php_postfix}-xmlrpc" do
	action	:install
	version	php_version
end
package "php#{php_postfix}-gd" do
	action	:install
	version	php_version
end
package "php#{php_postfix}-pdo" do
	action	:install
	version php_version
end
package "php#{php_postfix}-mbstring" do
	action	:install
	version php_version
end

if (node['platform'].eql?('raspbian'))
	# Nothing Yet
else
	package "php#{php_postfix}-devel" do
		action	:install
		version	php_version
	end
	package "php#{php_postfix}-process" do
		action	:install
		version	php_version
	end
	#package "php-pecl-memcache" do
	#	action	:install
	#	version	"7.2.12-1.el7.remi"
	#end
	package "php-pear-XML-Serializer" do
		action	:install
	end
end

