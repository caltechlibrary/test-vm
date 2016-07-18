#!/bin/bash

function setupUserAndGroup() {
    sudo adduser loris
}

function setupApache() {
    sudo a2enmod headers expires
    cat /etc/apache2/sites-available/default.conf > etc/apache2/loris2.conf
    cat <<EOF>> etc/loris2.conf
ExpiresActive On
ExpiresDefault "access plus 5184000 seconds"

AllowEncodedSlashes On

WSGIDaemonProcess loris2 user=loris group=loris processes=10 threads=15 maximum-requests=10000
WSGIScriptAlias /loris /home/$USER/www/loris2/loris2.wsgi
WSGIProcessGroup loris2

EOF
    sudo cp etc/apache2/loris2.conf /etc/apache2/sites-available/
    sudo ln -sf /etc/apache2/sites-available/loris2.conf /etc/apache2/sites-enabled/loris2.conf
}

function setupPillow() {
    sudo pip uninstall PIL --yes
    sudo pip uninstall Pillow --yes
    sudo apt-get purge python-imaging -y
    sudo pip install --upgrade werkzeug
    sudo pip install --upgrade Pillow
    sudo pip install --upgrade configobj
    sudo pip install --upgrade requests
    sudo pip install --upgrade mock
    sudo pip install --upgrade responses
}

function cloneLoris() {
    git clone https://github.com/loris-imageserver/loris
    cd loris
    python2.7 test.py
}

function baseSetup() {
    sudo apt-get update -y
    sudo apt-get install build-essential git \
        zlib1g-dev libssl-dev python-dev \
        python-pip python-setuptools \
        apache2 libapache2-mod-wsgi \
        libjpeg-turbo8-dev libfreetype6-dev zlib1g-dev \
        liblcms2-utils liblcms2-dev libtiff5-dev python-dev \
        libwebp-dev -y
    sudo pip install --upgrade pip
    sudo pip install --upgrade virtualenv
}

baseSetup
setupUserAndGroups
setupPillow
cloneLoris
