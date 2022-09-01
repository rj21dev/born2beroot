#!/bin/bash

dev_user="webmaster"
dev_pass="1234" # TODO : CHANGE THIS IN REAL CASE
db_name="wordpress"
db_user="admin"
db_pass="admin" # TODO : CHANGE THIS IN REAL CASE
db_rt_pass="root" # TODO : CHANGE THIS IN REAL CASE
wp_title="Title of website"
wp_admin="admin"
wp_pass="admin"
wp_mail="admin@$(hostname)"

echo -e "\e[35mStart deployment LLMP stack (Linux, Lighttpd, MariaDB, PHP)\e[0m"

useradd -m -s /bin/bash $dev_user
chpasswd <<< "$dev_user:$dev_pass"
echo -e "\e[33mAdd linux user - OK\e[0m"

apt-get update > /dev/null
apt-get upgrade -y > /dev/null
echo -e "\e[33mUpdate repository - OK\e[0m"

apt-get install -y net-tools htop mc > /dev/null
echo -e "\e[33mInstall simple utils - OK\e[0m"

apt-get install -y lighttpd > /dev/null
echo -e "\e[33mInstall web-sever - OK\e[0m"

apt-get inslall -y php-cgi php-mysql > /dev/null
echo -e "\e[33mInstall PHP - OK\e[0m"

lighty-enable-mod fastcgi
lighty-enable-mod fastcgi-php
service lighttpd force-reload
echo -e "\e[33mEnable FastCGI - OK\e[0m"

apt-get install -y mariadb-server > /dev/null
echo -e "\e[33mInstall MariaDB - OK\e[0m"

mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$db_rt_pass')"
mariadb -e "DROP USER ''@'localhost'"
mariadb -e "DROP DATABASE test"
mariadb -e "FLUSH PRIVILEGES"
echo -e "\e[33mInstall DB secure - OK\e[0m"

mariadb -e "CREATE DATABASE $db_name"
mariadb -e "CREATE USER $db_user@'localhost' IDENTYFIED BY '$db_pass'"
mariadb -e "GRANT ALL ON $db_name.* TO $db_user@'localhost'"
mariadb -e "FLUSH PRIVILEGES"
echo -e "\e[33mCreate DB and DB-user - OK\e[0m"

apt-get install -y phpmyadmin
echo -e "\e[33mInstall phpMyAdmin - OK\e[0m"

wget -O wp-cli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli
mv wp-cli /usr/local/bin
wp-cli core download --allow-root --path="/var/www/html"
echo -e "\e[33mInstall Wordpress - OK\e[0m"
wp-cli config create --allow-root --path=/var/www/ --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --dbhost=localhost --dbprefix=wp_
wp-cli core install --allow-root --path=/var/www/ --url="http://$(hostname)" --title=$wp_title --admin_user=$wp_admin --admin_password=$wp_pass --admin_email=$wp_mail --skip-email
chown -R www-data:www-data /var/www
echo -e "\e[33mConfig Wordpress - OK\e[0m"

apt-get install -y vsftpd > /dev/null
echo -e "\e[33mInstall FTP-server - OK\e[0m"
mkdir -p /home/$dev_user/ftp/pub
chown nobody:nogroup /home/$dev_user/ftp
chmod a-w /home/$new_user/ftp
tee -a /etc/vsftpd.conf <<< "write_enable=YES" > /dev/null
tee -a /etc/vsftpd.conf <<< "chroot_local_user=YES" > /dev/null
tee -a /etc/vsftpd.conf <<< "allow_writeable_chroot=YES" > /dev/null
tee -a /etc/vsftpd.conf <<< "user_sub_token=$USER" > /dev/null
tee -a /etc/vsftpd.conf <<< "local_root=/home/$USER/ftp" > /dev/null
service vsftpd restart
echo -e "\e[33mConfig FTP-server - OK\e[0m"

apt-get install -y ufw > /dev/null
echo -e "\e[33mInstall Firewall - OK\e[0m"
ufw allow 80 > /dev/null
ufw allow 21 > /dev/null
ufw allow 22 > /dev/null
service ufw restart
echo -e "\e[33mConfig Firewall - OK\e[0m"

apt-get install -y sudo > /dev/null
echo -e "\e[33mInstall sudo - OK\e[0m"
usermod -aG sudo $dev_user
touch /etc/sudoers.d/the.conf
mkdir -p /var/log/sudo
echo -e "Defaults\trequiretty" | tee /etc/sudoers.d/the.conf > /dev/null
echo -e "Defaults\tpasswd_tries=3" | tee -a /etc/sudoers.d/the.conf > /dev/null
echo -e 'Defaults\tbadpass_message="Wrong password. Access denied."' | tee -a /etc/sudoers.d/the.conf > /dev/null
echo -e 'Defaults\tlogfile="/var/log/sudo/su.log"' | tee -a /etc/sudoers.d/the.conf > /dev/null
echo -e "Defaults\tlog_input,log_output" | tee -a /etc/sudoers.d/the.conf > /dev/null
echo -e 'Defaults\tiolog_dir="/var/log/sudo"' | tee -a /etc/sudoers.d/the.conf > /dev/null
echo -e "\e[33mConfig sudo - OK\e[0m"

echo -e "\e[35mDeployment is finished successfully\e[0m"
echo -e "\e[31mReboot in 5\e[0m"
sleep 1
echo -e "\e[31mReboot in 4\e[0m"
sleep 1
echo -e "\e[31mReboot in 3\e[0m"
sleep 1
echo -e "\e[31mReboot in 2\e[0m"
sleep 1
echo -e "\e[31mReboot in 1\e[0m"
sleep 1
echo -e "\e[31mReboot...\e[0m"
reboot