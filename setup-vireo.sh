#!/bin/bash

#
# Setup Postgres and Vireo
#
cd $HOME/Vireo

# Setting up DB
sudo -u postgres createuser -dSRP vireo
sudo -u postgres createdb -U vireo -h localhost vireo

# Edit conf/application.conf
if [ -f conf/application.conf ]; then
    vi conf/application.conf
else
    echo "Missing conf/application.conf"
    exit 1
fi

# Configure Framework
play dependencies --sync --clearcache --%test
play secret
echo "You need to configure the Admin Account"
echo "Point your web browser at http://localhost:9000"
play run
echo ""
echo "To run as service: play start $(pwd)"
echo "To stop service: play stop $(pwd)"
