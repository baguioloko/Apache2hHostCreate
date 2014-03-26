#!/bin/bash

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <hostname>"
	exit 1
else
	HOST_NAME=$1 
	VHOST_PATH="/var/www/"$HOST_NAME
fi

if  [ ! $(which apache2) ]; then
	echo "Apache2 is not available"
	exit 1
fi

if [ ! -d "$VHOST_PATH" ]; then
	mkdir -p $VHOST_PATH/public_html
	chown -R $USER:$USER $VHOST_PATH/public_html
	chmod -R 755 $VHOST_PATH
	echo "$HOST_NAME is working!" >> $VHOST_PATH/public_html/index.html
	echo "127.0.0.1	$HOST_NAME" >> /etc/hosts
	echo "
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	ServerName $HOST_NAME
        ServerAlias $HOST_NAME
	DocumentRoot $VHOST_PATH/public_html
	<Directory />
		Options FollowSymLinks
		AllowOverride All
	</Directory>
	<Directory $VHOST_PATH/public_html>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>

	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	<Directory "/usr/lib/cgi-bin">
		AllowOverride None
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>

	ErrorLog \${APACHE_LOG_DIR}/error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

" > /etc/apache2/sites-available/$HOST_NAME
	a2ensite $HOST_NAME >> /dev/null
	service apache2 restart >> /dev/null
	#Testing the new host
	HOST_OUTPUT=$(curl http://$HOST_NAME/ 2>> /dev/null)
	if [ "$HOST_OUTPUT" == "$HOST_NAME is working!" ]; then
		echo "http://$HOST_NAME is ready to use"
	else
		echo "Some problems occurred with your new host:$HOST_NAME"
	fi
else
	echo "There is already a host called $HOST_NAME"
fi


























