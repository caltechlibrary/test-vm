#!/bin/bash
#
REVISION="v1.4.2"

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

function setupUsers() {
    sudo adduser --system archivesspace
    sudo addgroup archivesspace
    sudo adduser archivesspace archivesspace
    sudo adduser vagrant archivesspace
    echo "Groups archivesspace"
    groups archivesspace
    echo "Gourps vagrant"
    groups vagrant
}

#
# Setup MySQL appropriately
#
function setupMySQL {
    echo "Setup MySQL? [Y/n]"
    read Y_OR_N

    if [ "$Y_OR_N" = "" ] || [ "$Y_OR_N" = "y" ] || [ "$Y_OR_N" = "Y" ]; then
        cd /vagrant/
        echo "Working directory now $(pwd)"
        echo "Setting up MySQL users and creating database"
        if [ -f archivesspace-mysql-setup.sql ]; then
            /bin/rm archivesspace-mysql-setup.sql
        fi
        cat <<EOT > archivesspace-mysql-setup.sql
CREATE DATABASE IF NOT EXISTS archivesspace DEFAULT CHARACTER SET utf8;
GRANT ALL ON archivesspace.* TO 'as'@'localhost' IDENTIFIED BY 'as123';
FLUSH PRIVILEGES;
EOT
        echo "Loading the setup SQL"
        sudo mysql < archivesspace-mysql-setup.sql
        echo "Running the ArchivesSpace setup-database.sh script"
        cd /archivesspace/$REVISION/archivesspace/
        echo "Working directory now $(pwd)"
        bash scripts/setup-database.sh
        # Now make things more secure.
        #sudo mysql_secure_installation
    else
        echo "Skipping MySQL setup."
    fi
}

#
# Setup ArchivesSpace
#
function setupArchivesSpace() {
    # See https://www.youtube.com/watch?v=peRcBYqJHGc&index=19&list=PLJFitFaE9AY_DDlhl3Kq_vFeX27F1yt6I
    # for Video tutorial for similar steps on Cent OS 6.x
    echo "Adding archivesspace."
    RELEASE_URL="https://github.com/archivesspace/archivesspace/releases/download/$REVISION/archivesspace-$REVISION.zip"
    ZIP_FILE="/vagrant/archivesspace-$REVISION.zip"
    if [ -f "$ZIP_FILE" ]; then
        echo "Using existing $ZIP_FILE"
    else
        echo "Grabbing the ArchivesSpace $REVISION (current stable) release saving as $ZIP_FILE."
        echo "$RELEASE_URL"
        curl -L -k -o "$ZIP_FILE" --url $RELEASE_URL
    fi
    echo "Making /archivesspace/$REVISION"
    sudo mkdir -p /archivesspace/$REVISION
    echo "Updating ownership /archivesspace"
    sudo chown -R vagrant:archivesspace /archivesspace
    echo "Changing to new directory"
    cd /archivesspace/$REVISION
    echo "Working directory $(pwd)"
    echo "Unpacking $ZIP_FILE"
    unzip $ZIP_FILE
    echo "Copy in MySQL Java connection."
    cd /archivesspace/$REVISION/archivesspace/lib
    echo "Working directory is now $(pwd)"
    sudo curl -Oq http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.35/mysql-connector-java-5.1.35.jar
    # Setup MySQL connector for use with ArchivesSpace
    # Update config/config.rb
    cd /archivesspace/$REVISION/archivesspace
    echo "Working directory is now $(pwd)"
    sudo chown $USER /archivesspace/$REVISION/archivesspace/config/config.rb
    cat <<EOT >> /archivesspace/$REVISION/archivesspace/config/config.rb

# Our local configuration
AppConfig[:db_url] = "jdbc:mysql://localhost:3306/archivesspace?user=as&password=as123&useUnicode=true&characterEncoding=UTF-8"
AppConfig[:compile_jasper] = true
AppConfig[:enable_jasper] = true

EOT
}


function setupJasperReportsFonts() {
    # Setup Jasper reports Add the TTF fonts required to run them.
    cd /vagrant
    echo "Downloading the TTF fonts"
    curl -O http://thelinuxbox.org/downloads/fonts/msttcorefonts.tar.gz
    echo "Unpacking the TTF fonts"
    tar zxvf msttcorefonts.tar.gz
    echo "Moving them into /usr/share/fonts/TTF"
    sudo mkdir -p /usr/share/fonts/TTF
    sudo cp msttcorefonts/*.ttf /usr/share/fonts/TTF/
    echo "Updating the font cache"
    sudo fc-cache -fv
}

function setupFinish() {
    sudo chown -R archivesspace:archivesspace /archivesspace
    echo ""
    echo "Web Access:"
    echo "    http://localhost:8089/ -- the backend"
    echo "    http://localhost:8080/ -- the staff interface"
    echo "    http://localhost:8081/ -- the public interface"
    echo "    http://localhost:8090/ -- the Solr admin console"
    echo ""
    echo "Start archivespace"
    echo ""
    echo "    sudo /archivesspace/v1.4.2/archivesspace/archivesspace.sh"
    echo ""
    echo "And you're ready to create a new repository, load data, and begin development."
    echo ""
}

function setupUbuntu() {
    echo "Installing additional Ubuntu 16.04 LTS packages needed"
    sudo apt-get install build-essential git curl zip unzip \
         default-jdk ant ant-contrib ant-optional \
         maven mysql-server libmysql-java  -y
}

#
# Main
#
assertUsername vagrant "Try: sudo su vagrant"
setupUbuntu
setupUsers
setupArchivesSpace
setupMySQL
setupJasperReportsFonts
setupFinish
