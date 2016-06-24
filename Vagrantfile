# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  #config.vm.box = "ubuntu/xenial64"
  config.vm.box = "bento/ubuntu-16.04"

  #
  # Network options
  #

  # forward the public admin site
  #config.vm.network "forwarded_port", guest: 8080, host: 8080
  # forward the public website
  #config.vm.network "forwarded_port", guest: 8081, host: 8081
  # forward the API
  #config.vm.network "forwarded_port", guest: 8089, host: 8089
  # forward the Solr admin site
  #config.vm.network "forwarded_port", guest: 8090, host: 8090
  # forward NginX
  #config.vm.network "forwarded_port", guest: 80, host: 8000
  #config.vm.network "forwarded_port", guest: 443, host: 8443
  # forward MySQL port
  #config.vm.network "forwarded_port", guest: 3306, host:3306
  # forward PostgreSQL port
  # forward Play Framework service port
  config.vm.network "forwarded_port", guest:9000, host:9000

  #
  # Customize the CPU, Ram and Video memory
  #

  config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     vb.gui = false
  
     # Customize the amount of memory on the VM:
     vb.memory = "4096"
     vb.cpus = 4
     # Example custom settings:
     vb.customize ["modifyvm", :id, "--vram", "128"]
  end

  #
  # Install baseline software
  #
  config.vm.provision "shell", inline: <<-SHELL
    # Setup the base system with development tools
    sudo apt-get install build-essential git curl zip unzip postgresql postgresql-contrib default-jdk ant ant-optional ivy ivyplusplus doxygen -y
    export HOME=/home/vagrant
    cd $HOME

    # Fetch and compile play 1.3.4
    git clone https://github.com/playframework/play1.git
    cd play1
    git checkout 1.3.4
    cd framework
    ant
    cd ../..
    # Add play to the path
    export PATH=$PATH:$HOME/play1
    echo "export PATH=$PATH" >> $HOME/.profile

    # Fetch and compile Vireo v3.0.6
    git clone https://github.com/TexasDigitalLibrary/Vireo.git
    cd Vireo
    git checkout v3.0.6
    cd $HOME

    echo "Copying install script and updating ownership"
    chown -R vagrant:vagrant $HOME

    echo ""
    echo "Finish setup: "
    echo ""
    echo "   vagrant ssh"
    echo "   bash /vagrant/setup-vireo.sh"
    echo "   play run /home/vagrant/Verio"
    echo ""
  SHELL
end
