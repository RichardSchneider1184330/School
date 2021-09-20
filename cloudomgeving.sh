#!/bin/bash
echo " Welkom in mijn script , deze installeerd een cloud omgeving"
echo " De maker van dit script is Richard Schneider" 
echo " Welke webserver wil je installeren? (keuze: apache/nginx/lighttpd)" 

read webserver

if [ $webserver == "apache" ]
then 

apt install apache2
apt install php7.4

elif [ $webserver == "nginx" ]
then

apt install nginx
apt install php7.4

elif [ $webserver == "lighttpd" ]
then
apt install lighttpd
apt install php7.4

else 
echo "Verkeerder webserver naam opgegeven"

fi

echo "Nu gaan we een database installeren. Je hebt de opties uit de volgende twee databases: Mysql-server, Mariadb"

read database

if  [ $database == "Mysql-server" ] 
then 

apt install mysql-server


elif [ $database == "Mariadb" ]
then 

apt install mariadb

else
echo "Let op de spelling"
fi

echo "Nu gaan we NextCloud installeren"
echo "Geef een domeinnaam"
read domeinnaam

wget -O /var/www/$domeinnaam https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip
unzip /var/www/$domeinnaam

#sed -i -e '/var/www/html' -e 'var/www/$domeinnaam' /etc/apache2/apache2.conf
sed -i 's/\/var\/www\/html\/var/\/www\/$domeinnaam/g' /etc/apache2/apache2.conf

#sed -i 's/o NOT add/\/www\/$domeinnaam/g' /etc/apache2/apache2.conf
#sed -i -e '/var/www/html' -e 'var/www/$domeinnaam' /etc/apache2/sites-available/default-ssl.conf
systemctl restart apache2.service

echo "wil jij de configuratie van nextcloud nu doen?"
echo "Geen op Ja of Nee?"
read JaofNee

if [ $JaofNee == "Ja" ]
then
echo "Firefox zal open gaan met de tot dus vere geinstalleerde cloudomgeving. Hier kunt u bij opties uw aanpassingen maken"

firefox http://localhost/nextcloud

elif [ $JaofNee == "Nee" ]
then
echo  "Prima dan gaan we door met de basis installatie"

fi

echo "Laten we de firewall gaan instellen"
echo "Wilt u de aangeraden poorten opzetten voor uw cloudomgeving?"
echo "Geef Ja of Nee op"
echo "Deze poorten zijn 21, 22, 80 en 443"

read FirewallJaofNee

if [ $FirewallJaofNee == "Ja" ]
then
echo "De poorten worden nu open gezet"

ufw allow 21
ufw allow 22
ufw allow 80
ufw allow 443

elif [ $firewallJaOfNee == "Nee" ]
then
echo "Prima dan slaan we deze module over"

fi

echo "Laten we fail2ban installeren"
echo "Geef op Ja of Nee"
read fail2ban

if [ $fail2ban == "Ja" ]
then
echo "Fail2ban word geinstalleerd"

apt install fail2ban

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

elif [ $fail2ban == "Nee" ]
then
echo "Prima dan gaan we verder"

else
echo "Verkeerde spelling!"
fi

echo "Met fail2ban kan je bepaalde hackers aanvallen tegen gaan"
echo "Wil je een aantal instellingen veranderen of houd je liever alles op standaard"
echo "Geef Ja of Nee op"

read fail2banconf

if  [ $fail2banconf == "Ja" ]
then
echo "Hier zal een bestand openen waar je de opties kunt zien en de variablen kunt aanpassen"
echo "Als je de aanpassingen wilt opslaan druk dan op control x"

nano /etc/fail2ban/jail.local 

elif [ $fail2banconf == "Nee" ]
then
echo "In dat geval gaan we verder"

else
echo "Let op de spelling"

fi

echo "Voordat we een certificaat gaan aanmaken zetten veranderen we de benodigde veranderingen in apache2"
#sed -i -e '/var/www/html' -e 'var/www/$domeinnaam' /etc/apache2/sites-available/000-default.conf
sed -i 's/\/var\/www\/html\/var/\/www\/$domeinnaam/g' /etc/apache2/sites-available/000-default.conf

echo "Nu gaan we een zelf gemaakt certificaat aanmaken"
echo "Een certificaat gebruiken we om onze cloud omgeving te beveiligen"
echo "Geen aan of je wel of niet een certificaat wilt aanmaken"
echo "Type wel of niet"

read WelofNiet
 
if [ $WelofNiet == "Wel" ]
then
apt install openssl

openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/apache2/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
a2ensite nextcloud.conf
a2enmod ssl
sed -i 's/80/443/g' /etc/apache2/sites-enabled/000-default.conf
sed -i '4 i SSLEngine on' /etc/apache2/sites-enabled/000-default.conf
sed -i '5 i SSLCertificateFile /etc/apache2/ssl/apache-selfsigned.crt' /etc/apache2/sites-enabled/000-default.conf
sed -i '6 i SSLCertificateKeyFile /etc/apache2/ssl/private/apache-selfsigned.key' /etc/apache2/sites-enabled/000-default.conf
a2ensite default-ssl
a2dissite default-ssl.conf
systemctl start apache2.service
systemctl reload apache2.service

elif [ $WelofNiet == "Niet" ]
then
echo "Prima dan gaan we verder"

else
echo "Let op de spelling"
fi

echo "Laten we de database gaan configureren"
echo "Hiermee maak je een gebruiker en database voor nextcloud aan"
echo "Geef op ja of Nee"
read antwoord1

if [ $antwoord1 == "Ja" ]
then

mysql -e "CREATE USER 'cloudgebruiker'@'localhost' IDENTIFIED BY '2)WJsv5w';"
mysql -e "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -e "GRANT ALL PRIVILEGES on nextcloud.* to 'cloudgebruiker'@'localhost';"
mysql -e "FLUSH privileges;"

elif [ $antwoord1 == "Nee" ]
then
echo "In dat geval gaan we verder"
fi

echo "Nu gaan we de laatste module configureren en dat is php7.4"
echo "Deze veranderingen zullen gemaakt moeten worden dus in dit geval is er geen keuze menu"

sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 360/g' /etc/php/7.4/apache2/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 500M/g' /etc/php/7.4/apache2/php.ini

echo "Als je iets hebt gemist of je wilt nu wel aanpassingen maken druk op Y"
read $Y

while [ $Y == "Y" ]
do 
clear
bash cloudomgeving.sh ~/
done
