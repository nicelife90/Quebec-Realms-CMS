#!/bin/bash

# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#Make sure CMS is installed
ENV_FILE="/var/www/html/.env"
if [ ! -f "$ENV_FILE" ]
then
   echo "Install Threenity CMS before running this script!" 1>&2
   exit 1
fi

#Initial update
apt-get update -y
apt-get upgrade -y

#Install trinity prerequisite
apt-get install git clang cmake make gcc g++ libmariadbclient-dev libssl1.0-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev p7zip net-tools -y
update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100
update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

#Download and compile Trinity Core
cd /var/www/html/WoWServer/
git clone -b 3.3.5 git://github.com/TrinityCore/TrinityCore.git
cd TrinityCore
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=/var/www/html/WoWServer/Server -DTOOLS=0

#Install Server
yes | make -j $(nproc) install

#Download and Extract Last DB
cd /var/www/html/WoWServer/
last_db="https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.64/TDB_full_world_335.64_2018_02_19.7z"
wget $last_db
7zr e TDB_*
yes | cp -f TDB_*.sql /var/www/html/WoWServer/Server/bin

#Install DB
mysql_user="$(grep -oP 'BDD_USER=\K.*' /var/www/html/.env)"
mysql_pass="$(grep -oP 'BDD_PASS=\K.*' /var/www/html/.env)"

mysql -u $mysql_user -p$mysql_pass < /var/www/html/WoWServer/TrinityCore/sql/create/create_mysql.sql

#Prepare conf
mv /var/www/html/WoWServer/Server/etc/authserver.conf.dist /var/www/html/WoWServer/Server/etc/authserver.conf
mv /var/www/html/WoWServer/Server/etc/worldserver.conf.dist /var/www/html/WoWServer/Server/etc/worldserver.conf

#create logs and data dir
mkdir /var/www/html/WoWServer/Server/logs
mkdir /var/www/html/WoWServer/Server/data

#download and extract dbc maps vmaps mmaps
cd /var/www/html/WoWServer/
data="https://github.com/nicelife90/ThreenityCMS/releases/download/3.3.5/dbc-maps-vmaps-mmaps-3.3.5-en-us.7z"
wget $data
7zr x dbc-maps-vmaps-mmaps-3.3.5-en-us.7z data/
yes | cp -Rf /var/www/html/WoWServer/data/* /var/www/html/WoWServer/Server/data/
rm -rf data

#Get local IP
local_ip="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"

#edit conf file
sed -i 's#LogsDir = ""#LogsDir = "/var/www/html/WoWServer/Server/logs/"#g' /var/www/html/WoWServer/Server/etc/authserver.conf
sed -i 's#LogsDir = ""#LogsDir = "/var/www/html/WoWServer/Server/logs/"#g' /var/www/html/WoWServer/Server/etc/worldserver.conf
sed -i 's#DataDir = "."#DataDir = "/var/www/html/WoWServer/Server/data/"#g' /var/www/html/WoWServer/Server/etc/worldserver.conf
sed -i 's#BindIP = "0.0.0.0"#BindIP = "'${local_ip}'"#g' /var/www/html/WoWServer/Server/etc/authserver.conf
sed -i 's#BindIP = "0.0.0.0"#BindIP = "'${local_ip}'"#g' /var/www/html/WoWServer/Server/etc/worldserver.conf
sed -i 's#LoginDatabaseInfo = "127.0.0.1;3306;trinity;trinity;auth"#LoginDatabaseInfo = "127.0.0.1;3306;'${mysql_user}';'${mysql_pass}';auth"#g' /var/www/html/WoWServer/Server/etc/authserver.conf
sed -i 's#LoginDatabaseInfo     = "127.0.0.1;3306;trinity;trinity;auth"#LoginDatabaseInfo = "127.0.0.1;3306;'${mysql_user}';'${mysql_pass}';auth"#g' /var/www/html/WoWServer/Server/etc/worldserver.conf
sed -i 's#WorldDatabaseInfo     = "127.0.0.1;3306;trinity;trinity;world"#WorldDatabaseInfo = "127.0.0.1;3306;'${mysql_user}';'${mysql_pass}';world"#g' /var/www/html/WoWServer/Server/etc/worldserver.conf
sed -i 's#CharacterDatabaseInfo = "127.0.0.1;3306;trinity;trinity;characters"#CharacterDatabaseInfo = "127.0.0.1;3306;'${mysql_user}';'${mysql_pass}';characters"#g' /var/www/html/WoWServer/Server/etc/worldserver.conf

#Start server for first time
/var/www/html/WoWServer/Server/bin/worldserver




