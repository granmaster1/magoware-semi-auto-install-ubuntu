#!/usr/bin/env bash

#UBUNTU VERSION ARRAYS
VERSIONARRAY=(18.04 18.04.1 18.04.2 18.04.3 18.04.4 20.04)
EIGHTEENARRAY=(18.04 18.04.1 18.04.2 18.04.3 18.04.4)
TWENTYARRAY=(20.04)

#CHECKING UBUNTU VERSION
echo -e "######## \e[32mCHECKING UBUNTU VERSION\e[39m ########"
VERSION=$(lsb_release -rs)

if [[ ! " ${VERSIONARRAY[@]} " =~ " ${VERSION} " ]]; then
    echo -e ""
    echo -e "This script does nopt support your OS/Distribution."
    echo -e "Goodbye!"
    echo -e ""
    exit 1
fi

echo -e ""
echo -e "Found Ubuntu Version: $VERSION"

#INSTALLING UPDATES
sudo apt-get update -y -qq > /dev/null
echo -e ""

#INSTALLING REQUIRED PACKAGES
if [[ " ${EIGHTEENARRAY[@]} " =~ " ${VERSION} " ]]; then
    echo -e "######## \e[32mINSTALLING PACKAGES FOR UBUNTU 18\e[39m ########"
fi

if [[ " ${TWENTYARRAY[@]} " =~ " ${VERSION} " ]]; then
    echo -e "######## \e[32mINSTALLING PACKAGES FOR UBUNTU 20\e[39m ########"
fi

curl -sL https://deb.nodesource.com/setup_10.x -o /tmp/node_setup.sh
sudo bash /tmp/node_setup.sh >/dev/null 2>&1
echo -e ""
echo -e "Have Patience, This takes a while...."
sudo apt install -y mysql-server redis-server git nodejs build-essential unzip -qq > /dev/null
echo -e ""

#CONFIGURING MYSQL
echo -e "######## \e[32mCONFIGURING MYSQL\e[39m ########"
read -s -p "What Password Do You Want To Set For Mysql?: " mysqlpass
echo -e ""
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysqlpass';"
mysql -u root -p$mysqlpass -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p$mysqlpass -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p$mysqlpass -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p$mysqlpass -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -u root -p$mysqlpass -e "CREATE DATABASE magoware;"
mysql -u root -p$mysqlpass -e "FLUSH PRIVILEGES;"
echo -e ""

#CONFIGURING REDIS
echo -e "######## \e[32mCONFIGURING REDIS SERVER\e[39m ########"
read -s -p "What Password Do You Want To Set For Redis?: " redispass
echo -e ""
sed -i "s/supervised no/supervised systemd/g" /etc/redis/redis.conf
sed -i "s/# requirepass foobared/requirepass $redispass/g" /etc/redis/redis.conf
echo -e ""
sudo systemctl restart redis.service

#CONFIGURING MAGOWARE
echo -e "######## \e[32mSETTING UP MAGOWARE FILES\e[39m ########"
echo -e ""
wget -q -O /usr/local/src/magoware.zip https://files.scripting.online/magoware/020520.zip
unzip -q /usr/local/src/magoware.zip -d /usr/local/src
mv /usr/local/src/backoffice-administration-master /usr/local/src/magoware
sudo rm /usr/local/src/magoware.zip
cd /usr/local/src/magoware
sudo npm install --quiet
sudo npm install --quiet stripe
echo -e ""

echo -e "######## \e[32mCONFIGURING MAGOWARE\e[39m ########"
echo -e ""
sed -i "s/process.env.NODE_ENV = 'development';/process.env.NODE_ENV = 'production';/g" /usr/local/src/magoware/server.js
sed -i "s/    password: process.env.REDIS_PASSWORD || \"\",/    password: process.env.REDIS_PASSWORD || \"$redispass\",/g" /usr/local/src/magoware/config/env/production.js
echo -e "Done."
echo -e ""

#INSTALLATION FINISHED
echo -e "######## \e[32mINSTALLATION FINISHED\e[39m ########"
echo -e ""
echo -e "Congratulations, installion is complete!"
echo -e ""
echo -e "	MAGOWARE is installed in \e[32m/usr/local/src/magoware\e[39m"
echo -e "	MAKE SURE YOU ENTER SMTP & HTTPS CERTIFICATE INFO IN \e[32m/usr/local/src/magoware/config/env/production.js\e[39m"
echo -e "	RUN \e[32msudo node /usr/local/src/magoware/server.js\e[39m AND ENTER YOU'RE MYSQL LOGIN DETAILS WHEN REQUESTED"
echo -e "	ADMIN PANEL WILL BE AVAILABLE AT \e[32mhttps://<DOMAIN>/admin\e[39m"
echo -e ""

