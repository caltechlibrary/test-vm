#!/bin/bash
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
# Setup MySQL appropriately
#
function setupMySQL {
    echo "Setup MySQL? [Y/n]"
    read Y_OR_N

    if [ "$Y_OR_N" = "" ] || [ "$Y_OR_N" = "y" ] || [ "$Y_OR_N" = "Y" ]; then
        sudo systemctl start mysqld.service
        sudo mysql_secure_installation
        sudo systemctl enable mysqld.service
    else
        echo "Skipping MySQL setup."
    fi
}

function setupStep2 {
    EPRINTS_HOME=$(grep eprints /etc/passwd | cut -d : -f 6)
    # Add vagrant to the eprints user group as a convienence
    sudo cp sbin/2-final-setup.sh $EPRINTS_HOME/
    sudo chown eprints.eprints $EPRINTS_HOME/2-final-setup.sh
    echo "become the eprints user, run $EPRINTS_HOME/2-final-setup.sh"
    echo "E.g."
    echo "    sudo su eprints"
    echo "    cd"
    echo "    bash $EPRINTS_HOME/2-final-setup.sh"
    echo ""
    exit 0
}

function setupEPrintsRepository {
    # Move to the eprints installation location
    cd
    echo "EPrints installed in directory: "$(pwd)
    # create your first repository
    ./bin/epadmin create
    echo "Hopefully you have created your first repository succeessfully."
    echo "Remember the virtual hostname you entered for later."
}

function setupStep3 {
    echo ""
    echo "Exit session and return to the vagrant user."
    echo "Then run sbin/3-final-setup.sh, E.g."
    echo "    exit"
    echo "    bash sbin/3-final-setup.sh"
    exit 0
}

function fixPermissions {
    EPRINTS_HOME=$(grep eprints /etc/passwd | cut -d : -f 6)
    # fix perms
    sudo chmod -R 770 $EPRINTS_HOME/var/
	sudo chcon -R -h -t httpd_sys_script_rw_t $EPRINTS_HOME/var/
    sudo chmod -R 770 $EPRINTS_HOME/lib/
    sudo chcon -R -h -t httpd_sys_script_rw_t $EPRINTS_HOME/lib/
    cd $EPRINTS_HOME
    find archives/ -maxdepth 1 -type d | while read ITEM; do
        if [ "$ITEM" != "archives/" ]; then
            echo "Updating settings for "$ITEM"/documents"
            sudo chmod -R 770 "$ITEM"/documents
            sudo chcon -R -h -t httpd_sys_script_rw_t "$ITEM"/documents
        fi
    done
}

function reportIPForHostSetup {
    echo "Find your IP address visible to your vagrant host."
    ifconfig
    echo "Don't forget to add your eprints repository virtual host info"
    echo "to /etc/hosts on your vagrant host machine."
    echo ""
    echo "See http://wiki.eprints.org/w/Training_Video:EPrints_Install"
    echo "at about 4 minutes 20 seconds of the installation tutorial."
    exit 0
}

function addEPrintsDependencies {
    sudo apt install apach2-mpm-prefork libapache2-mod-perl2 \
        libxml-libxml-perl libunicode-string-perl \
        libterm-readkey-perl libmime-lite-perl libdbd-mysql-perl libxml-parser-perl \
        gzip tar unzip make lynx wget ncftp ftp \
        gs xpdf xv antiword elinks \
        pdftk tetex-bin psutils imagemagick -y
}

case $1 in
    1)
    #
    # Sequence 1 as vagrant user
    #
    assertUsername vagrant "Step 1 should run as a user vagrant, try: 'vagrant ssh' from your host machine."
    echo "Starting setup step 1"
    addEPrintsDependencies
    #setupMySQL
    #setupStep2
    ;;
    2)

    #
    # Sequence 2 as eprints user 
    #
    assertUsername eprints "Step 2 should run as user eprints under vagrant, try: sudo su eprints"
    echo "Starting setup step 2"
    setupEPrintsRepository
    setupStep3

    # restart apache
    sudo systemctl restart httpd.service
    sudo systemctl enable httpd.service
    ;;
    3)

    #
    # Sequence 3 as vagrant user again.
    #
    assertUsername vagrant "Step 3 should run as user vagrant under vagrant"
    echo "Starting setup step 3"
    fixPermissions
    reportIPForHostSetup
    ;;
    *)
    cat <<EOM
 USAGE: bash setup-eprints STEP_NO

 Run through the steps (one through three) to install EPrints on this
 Vagrant VM.

 Example install sequence:

    # As user vagrant
    bash setup-eprints.sh 1
    # As user eprints
    sudo su eprints
    bash setup-eprints.sh 2
    exit
    # As user vagrant again
    bash setup-eprints.sh 3

EOM
    exit 1
    ;;
esac
