#!/bin/bash

dev_user=webmaster
dev_pass=1234 # TODO : CHANGE THIS IN REAL CASE
db_name=wordpress
db_user=admin
db_pass=admin # TODO : CHANGE THIS IN REAL CASE
db_rt_pass=root # TODO : CHANGE THIS IN REAL CASE

echo -e "\e[35mStart deployment LLMP stack (Linux, Lighttpd, MariaDB, PHP)\e[0m"

useradd -m -s /bin/bash $dev_user
echo "$dev_user:$dev_pass" | chpasswd
echo -e "\e[33mAdd linux user - OK\e[0m"

apt-get update > /dev/null
apt-get upgrade -y > /dev/null
echo -e "\e[33mUpdate repository - OK\e[0m"

apt-get install -y vim net-tools htop mc > /dev/null
echo -e "\e[33mInstall simple utils - OK\e[0m"

apt-get install -y lighttpd > /dev/null
echo -e "\e[33mInstall web-sever - OK\e[0m"

apt-get install -y mariadb-server > /dev/null
echo -e "\e[33mInstall MariaDB - OK\e[0m"

mariadb -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$db_rt_pass')" > /dev/null
mariadb -e "FLUSH PRIVILEGES" > /dev/null
echo -e "\e[33mInstall root password - OK\e[0m"

mariadb -e "CREATE DATABASE $db_name" > /dev/null
mariadb -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass'" > /dev/null
mariadb -e "GRANT ALL ON $db_name.* TO '$db_user'@'localhost'" > /dev/null
mariadb -e "FLUSH PRIVILEGES" > /dev/null
echo -e "\e[33mCreate DB and DB-user - OK\e[0m"

apt-get install -y php-cgi php-mysql > /dev/null
echo -e "\e[33mInstall PHP - OK\e[0m"

lighty-enable-mod fastcgi > /dev/null
lighty-enable-mod fastcgi-php > /dev/null
service lighttpd force-reload
echo -e "\e[33mEnable FastCGI - OK\e[0m"

wget -O wp-cli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /dev/null
chmod +x wp-cli
mv wp-cli /usr/local/bin
wp-cli core download --allow-root --path="/var/www/html" > /dev/null
echo -e "\e[33mInstall Wordpress - OK\e[0m"
wp-cli config create --allow-root --path=/var/www/html --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --dbhost=localhost --dbprefix=wp_
chown -R www-data:www-data /var/www
echo -e "\e[33mConfig Wordpress - OK\e[0m"

apt-get install -y vsftpd > /dev/null
echo -e "\e[33mInstall FTP-server - OK\e[0m"
mkdir -p "/home/$dev_user/ftp/pub"
chown nobody:nogroup "/home/$dev_user/ftp"
chmod a-w "/home/$dev_user/ftp"
echo "write_enable=YES" | tee -a /etc/vsftpd.conf  > /dev/null
echo "chroot_local_user=YES" | tee -a /etc/vsftpd.conf > /dev/null
echo "allow_writeable_chroot=YES" | tee -a /etc/vsftpd.conf > /dev/null
echo 'user_sub_token=$USER' | tee -a /etc/vsftpd.conf > /dev/null
echo 'local_root=/home/$USER/ftp' | tee -a /etc/vsftpd.conf > /dev/null
service vsftpd restart
echo -e "\e[33mConfig FTP-server - OK\e[0m"

apt-get install -y ufw > /dev/null
echo -e "\e[33mInstall Firewall - OK\e[0m"
ufw allow 80 > /dev/null
ufw allow 21 > /dev/null
ufw allow 22 > /dev/null
ufw enable
echo -e "\e[33mConfig Firewall - OK\e[0m"

apt-get install -y sudo > /dev/null
echo -e "\e[33mInstall sudo - OK\e[0m"
usermod -aG sudo $dev_user
mkdir -p /var/log/sudo
echo "Defaults requiretty" | tee -a /etc/sudoers > /dev/null
echo "Defaults passwd_tries=3" | tee -a /etc/sudoers > /dev/null
echo 'Defaults badpass_message="Wrong password. Access denied."' | tee -a /etc/sudoers > /dev/null
echo 'Defaults logfile="/var/log/sudo/su.log"' | tee -a /etc/sudoers > /dev/null
echo "Defaults log_input,log_output" | tee -a /etc/sudoers > /dev/null
echo 'Defaults iolog_dir="/var/log/sudo"' | tee -a /etc/sudoers > /dev/null
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