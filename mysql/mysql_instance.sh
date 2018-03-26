#!/bin/bash
set -e

i=$1
cmd=$2
port=$((3306+$i))

case "$cmd" in
	"create")
		if [ -f "/etc/mysql/my$i.cnf" ]; then
		  echo "This instance is existed"
		  exit 1
		fi
		if [ ! -d /var/lib/mysql$i ]; then
			mkdir /var/lib/mysql$i
			chown -R mysql:mysql /var/lib/mysql$i/
		fi
		if [ ! -d /var/log/mysql$i ]; then
			mkdir /var/log/mysql$i
			chown -R mysql:mysql /var/log/mysql$i/
		fi
		cp /etc/mysql/my.cnf /etc/mysql/my$i.cnf
		
		cd /etc/mysql/
		sed -i "s/3306/$port/g" my$i.cnf
		sed -i "s/mysqld.sock/mysqld$i.sock/g" my$i.cnf
		sed -i "s/mysqld.pid/mysqld$i.pid/g" my$i.cnf
		sed -i "s/var\/lib\/mysql/var\/lib\/mysql$i/g" my$i.cnf
		sed -i "s/var\/log\/mysql/var\/log\/mysql$i/g" my$i.cnf

		if [ -f "/etc/apparmor.d/local/usr.sbin.mysqld" ]; then
			echo "#=====INSTANSE $i======#" >> "/etc/apparmor.d/local/usr.sbin.mysqld"
			echo "/var/lib/mysql$i/ r," >> "/etc/apparmor.d/local/usr.sbin.mysqld"
			echo "/var/lib/mysql$i/** rwk," >> "/etc/apparmor.d/local/usr.sbin.mysqld"
			echo "/var/run/mysqld/mysqld$i.pid rw," >> "/etc/apparmor.d/local/usr.sbin.mysqld"
			echo "/var/run/mysqld/mysqld$i.sock w," >> "/etc/apparmor.d/local/usr.sbin.mysqld"
			echo "/run/mysqld/mysqld$i.pid rw," >> "/etc/apparmor.d/local/usr.sbin.mysqld"
			echo "/run/mysqld/mysqld$i.sock w," >> "/etc/apparmor.d/local/usr.sbin.mysqld"
			service apparmor reload
		fi
		mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql$i --defaults-file=/etc/mysql/my$i.cnf

		;;
	"start")
		if [ ! -f "/etc/mysql/my$i.cnf" ]; then
	  		echo "This instance is not existed"
	  		exit 1
		fi	
		mysqld_safe --defaults-file=/etc/mysql/my$i.cnf --user=mysql &
	;;

	"stop")
		mysqladmin -h127.0.0.1 --port=$port -uroot shutdown
	;;
	*)
		echo "usage: {instance} {create|start|stop}"
	;;
esac

