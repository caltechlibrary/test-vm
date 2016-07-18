#!/bin/bash
#
# Setup up and install the non-debian package components to run Vireo
#

function setMySQLUserDB () {
    echo "Enter DB Username"
    read MYSQL_USER
    echo "Entry a password for the $MYSQL_USER DB User"
    read -s MYSQL_PASSWORD

    sudo mysql mysql<<MYSQL
CREATE DATABASE IF NOT EXISTS vireo;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_USER.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL
}

cd $HOME

# Setup the base system with development tools
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential git curl zip unzip \
    postgresql postgresql-contrib \
    default-jdk ant ant-optional ivy ivyplusplus doxygen -y
# mysql-server libmysql-java \


# Fetch and compile play 1.3.4
git clone https://github.com/playframework/play1.git
cd play1
git checkout 1.3.4
cd framework
ant
cd
# Add play to the path
export PATH=$PATH:$HOME/play1
echo "export PATH=$PATH" >> $HOME/.profile

# Fetch and compile Vireo v3.0.6
git clone https://github.com/TexasDigitalLibrary/Vireo.git
cd Vireo
git checkout v3.0.6
cd

#
# Setup Postgres and Vireo
#

# Setting up DB
echo "Creating user with password"
sudo -u postgres createuser -dSRP vireo
sudo -u postgres createdb -U vireo -h localhost vireo

# Edit conf/application.conf
if [ -f $HOME/Vireo/conf/application.conf ]; then
    echo -n "Entry a password vireo db user in configuration file: "
    read -s DB_PASSWORD
    sed -i .save -e "s/application.baseUrl=http:\/\/www.yourdomain.com\//application.baseUrl=http:\/\/localhost\//g" \
        -e "s/db=postgres:\/\/host\/database_name/db=postgres:\/\/localhost\/vireo/g" \
        -e "s/db.user = user/db.user = vireo/g" \
        -e "s/db.pass = secret/db.pass = $DB_PASSWORD/" \
        $HOME/Vireo/conf/application.conf
    #echo "DEBUG double check configuration changes"
    #vi $HOME/Vireo/conf/application.conf
else
    echo "Missing $HOME/Vireo/conf/application.conf"
    exit 1
fi

cd $HOME/Vireo

# Configure Framework
play dependencies --sync --clearcache --%test
play secret
echo "You need to configure the Admin Account"
echo "Point your web browser at http://localhost:9000"
echo "May take a few minutes for service to come up"
echo "Tail the log: tail -f /home/vagrant/Vireo/logs/application.log"
$HOME/play1/play run /home/vagrant/Vireo
echo ""
echo "To run as service: $HOME/play1/play start $HOME/vagrant/Vireo"
echo "To stop service: $HOME/play1/play stop $HOME/vagrant/Vireo"
echo ""
