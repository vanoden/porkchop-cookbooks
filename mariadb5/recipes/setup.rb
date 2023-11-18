# Requires: sudo rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
yum_package "mariadb-server" do
	action	:install
	#version "5.5.60-1.el7_5"
end
