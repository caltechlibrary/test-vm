#!/bin/bash
#
# Setup up and install the non-debian package components to run Vireo
#

cd $HOME

# Setup the base system with development tools
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential git curl zip unzip \
    postgresql postgresql-contrib \
    default-jdk ant ant-optional ivy ivyplusplus doxygen -y


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
echo "May take a few minutes for service to come up"
echo "Tail the log: tail -f /home/vagrant/Vireo/logs/application.log"
play run /home/vagrant/Vireo
echo ""
echo "To run as service: play start $(pwd)"
echo "To stop service: play stop $(pwd)"
