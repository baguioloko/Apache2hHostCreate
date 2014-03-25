#!/bin/bash

#inicio da criação do host
function main(){
	echo "Entre com o nome do host!";
	read host
	if [ ! -d "/var/www/$host" ]; then
		mkdir -p /var/www/$host/public_html
        	echo "host criado !";
		chown -R $USER:$USER /var/www/$host/public_html
		chmod -R 755 /var/www/$host
		echo "o host: $host está funcionando: " >> /var/www/$host/public_html/index.html
		#cp /etc/apache2/sites-available/default /etc/apache2/sites-available/$host
		echo "127.0.1.1	$host" >> /etc/hosts
		echo "127.0.1.1 www.$host" >> /etc/hosts
		echo "
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	ServerName $host
        ServerAlias www.$host
	DocumentRoot /var/www/$host/public_html
	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /var/www/$host/public_html>
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


" > /etc/apache2/sites-available/$host
		a2ensite $host
		echo "host: '$host' criado com sucesso acesse: http://$host ou http://www.$host";
	else
		echo "já existe esse host!!";
	fi
}


#verifica se o apache esta instalado
apache=$(dpkg -l | grep -e apache2 > /dev/null && echo "1" || echo "0")

if [ "$apache" == "1" ]; then
	echo "Apache instalado";
	#se o apache estiver instalado começa a criação do host
	main;
else
	echo "Apache não instalado";
	echo "por favor instale para continuar";
fi
