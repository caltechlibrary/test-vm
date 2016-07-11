#!/bin/bash
#

#
# Check username
#
function assertUsername {
    USERNAME=$1
    ERROR_MSG=$2
    WHOAMI=$(whoami)

    if [ "$USERNAME" = "" ];then
        echo "SCRIPTING error, assertUsername expects a username to be supplied to check."
        exit 1
    fi

    if [ "$WHOAMI" != "$USERNAME" ]; then
        echo "This script should be run as the $USERNAME user."
        if [ "$ERROR_MSG" != "" ]; then
             echo $ERROR_MSG;
        fi
        exit 1
    fi
}

#
# Base Setup
#
function baseSetup() {
    sudo apt-get update -y
    sudo apt install build-essential git curl zip unzip \
        mysql-server libmysql-java \
        libtomcat7-java tomcat7 tomcat7-admin tomcat7-common tomcat7-user \
        default-jdk ant ant-optional maven -y
}


#
# Main
#
assertUsername vagrant "Try: sudo su vagrant"
baseSetup
/vagrant/fedora4-setup/install_scripts/fedora4.sh /vagrant
/vagrant/fedora4-setup/install_scripts/backup_restore.sh /vagrant
/vagrant/fedora4-setup/install_scripts/fedora_camel_toolbox.sh /vagrant

