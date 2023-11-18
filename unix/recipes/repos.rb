log 'Platform' do
	message "Platform: "+node['platform']
	level	:info
end

if node['platform'] == 'redhat' || node['platform'] == 'centos'
	#yum_repository 'epel' do
	#	action	:create
	#	url	'http://download.fedoraproject.org/pub/epel/7/i386'
	#	description 'Extra Packages for Enterprise Linux 7 - i386'
	#	enabled	true
	#	gpgcheck	true
	#	gpgkey	'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'
	#end 

	yum_repository "epel" do
		metalink 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch'
		failovermethod 'priority'
		enabled true
		gpgcheck false
		#gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'
	end

	yum_repository "remi" do
		mirrorlist 'http://cdn.remirepo.net/enterprise/7/remi/mirror'
		enabled true
		gpgcheck false
	end

	yum_repository "remi-php73" do
		mirrorlist 'http://cdn.remirepo.net/enterprise/7/php73/mirror'
		enabled	true
		gpgcheck false
		#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
	end

	yum_repository "mariadb" do
		baseurl 'http://yum.mariadb.org/10.5/centos7-amd64'
		#gpgkey	https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
		#gpgcheck true
 	end                                                                                                                                                                    

	yum_package "yum-utils" do
		action	:install
	end
else
	log 'No match' do
		message "No repos for platform"
		level	:error
	end
end
