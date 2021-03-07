#!/bin/bash

if [ ! -f /var/lib/mysql/ibdata1 ]; then
	mysql_install_db
fi
unoconv --listener &
sleep 10
unoconv --listener &
service rsyslog start
service ssh start
service mysql start
service apache2 start
mysqladmin --silent --wait=30 ping || exit 1
mysql -e "CREATE DATABASE resourcespace CHARACTER SET = 'latin1' COLLATE = 'latin1_general_ci';"
if [ ! -d /var/www/html/filestore ]; then
	cd /var/www/html
	rm index.*
	cp -R /var/www/html.first/* /var/www/html
	chmod 777 filestore
	chmod -R 777 include
fi
cd /
cron
exec /bin/bash -c "trap : TERM INT; sleep infinity & wait" 
