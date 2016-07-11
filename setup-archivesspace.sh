#!/bin/bash
#

#
# Basic Configuration
#
export ARCHIVESSPACE_REVISION="v1.5.0-RC2"
export ARCHIVESSPACE_INSTALL_DIRECTORY="/home/$USER/archivesspace-$ARCHIVESSPACE_REVISION"

#
# Base Setup
#
function baseSetup() {
    sudo apt-get update -y
    sudo apt install build-essential git curl zip unzip \
        mysql-server libmysql-java \
        default-jdk ant ant-optional maven -y
}

#
# Below should remain the same for supported versions
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

function setupUsers {
    sudo adduser archivesspace
    sudo usermod -G vagrant,archivesspace vagrant
}

#
# Setup MySQL appropriately
#
function setupMySQL {
    cd
    echo "Setup MySQL? [Y/n]"
    read Y_OR_N

    if [ "$Y_OR_N" = "" ] || [ "$Y_OR_N" = "y" ] || [ "$Y_OR_N" = "Y" ]; then
        echo "Setting up MySQL users and creating database"
        sudo systemctl start mysqld.service
        touch archivesspace-mysql-setup.sql
        echo "CREATE DATABASE archivesspace DEFAULT CHARACTER SET utf8;" >> archivesspace-mysql-setup.sql
        echo "GRANT ALL ON archivesspace.* TO 'as'@'localhost' IDENTIFIED BY 'as123';" >> archivesspace-mysql-setup.sql
        echo "FLUSH PRIVILEGES;" >> archivesspace-mysql-setup.sql
        sudo mysql < archivesspace-mysql-setup.sql
        echo "Running the ArchivesSpace setup-database.sh script"
        cd $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace
        bash scripts/setup-database.sh
        cd
        # Now make things more secure.
        #sudo mysql_secure_installation
        sudo systemctl enable mysqld.service
    else
        echo "Skipping MySQL setup."
    fi
}

#
# Setup ArchivesSpace
#
function setupArchivesSpace {
    # See https://www.youtube.com/watch?v=peRcBYqJHGc&index=19&list=PLJFitFaE9AY_DDlhl3Kq_vFeX27F1yt6I
    # for Video tutorial for similar steps on Cent OS 6.x
    echo "Adding archivesspace."
    REVISION="$ARCHIVESSPACE_REVISION"
    RELEASE_URL="https://github.com/archivesspace/archivesspace/releases/download/$REVISION/archivesspace-$REVISION.zip"
    ZIP_FILE="/vagrant/archivesspace-$REVISION.zip"
    if [ -f "$ZIP_FILE" ]; then
        echo "Using existing $ZIP_FILE"
    else
        echo "Grabbing the ArchivesSpace $REVISION (current stable) release."
        echo "$RELEASE_URL"
        curl -L -k -O --url $RELEASE_URL
    fi
    if [ ! -d "$ARCHIVESSPACE_INSTALL_DIRECTORY" ]; then
        sudo mkdir -p "$ARCHIVESSPACE_INSTALL_DIRECTORY"
    fi
    cd $ARCHIVESSPACE_INSTALL_DIRECTORY/
    echo "Unpacking $ZIP_FILE"
    sudo unzip $ZIP_FILE
    echo "Copy in MySQL Java connection."
    cd $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace/lib
    sudo curl -Oq http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.35/mysql-connector-java-5.1.35.jar
    # Setup MySQL connector for use with ArchivesSpace
    # Update config/config.rb
    cd $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace
    sudo chown $USER config/config.rb
    echo 'AppConfig[:db_url] = "jdbc:mysql://localhost:3306/archivesspace?user=as&password=as123&useUnicode=true&characterEncoding=UTF-8"' >> config/config.rb
    echo 'AppConfig[:compile_jasper] = true' >> config/config.rb
    echo 'AppConfig[:enable_jasper] = true' >> config/config.rb

    echo "Update ownership to be archivesspace user."
    sudo chown -R archivesspace.archivesspace $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace
    sudo chcon -R -h -t httpd_sys_script_rw_t $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace
    # Finally make ArchivesSpace come up on boot as archivesspace user.
    sudo ln -s $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace/archivesspace.sh /etc/init.d/archivesspace
    sudo sed --in-place=.original -e "s/ARCHIVESSPACE_USER=/ARCHIVESSPACE_USER=archivesspace/g" $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace/archivesspace.sh
}

function setupJasperReportsFonts {
    # Setup Jasper reports Add the TTF fonts required to run them.
    cd
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

function setupFinish {
    cd
    mkdir bin
    cp -v /vagrant/setup/reset-archivesspace.sh bin/
    cp -vR /vagrant/tests ./
    sudo chown -R archivesspace $ARCHIVESSPACE_INSTALL_DIRECTORY/archivesspace
    echo ""
    echo "Web Access:"
    echo "    http://localhost:8089/ -- the backend"
    echo "    http://localhost:8080/ -- the staff interface"
    echo "    http://localhost:8081/ -- the public interface"
    echo "    http://localhost:8090/ -- the Solr admin console"
    echo ""
    echo "Bring up archivespace by "
    echo ""
    echo "    sudo /etc/init.d/archivesspace start"
    echo ""
    echo "And you're ready to create a new repository, load data, and begin development."
    echo ""
}

#
# Main
#
assertUsername vagrant "Try: sudo su vagrant"
baseSetup
setupUsers
setupArchivesSpace
setupMySQL
setupJasperReportsFonts
setupFinish
