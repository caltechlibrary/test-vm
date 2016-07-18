Vagrant.configure(2) do |config|
  #config.vm.box = "ubuntu/xenial64"
  config.vm.box = "bento/ubuntu-16.04"

  #
  # Network options
  #

  # forward the public admin site
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  # forward the public website
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  # forward the API
  config.vm.network "forwarded_port", guest: 8089, host: 8089
  # forward the Solr admin site
  config.vm.network "forwarded_port", guest: 8090, host: 8090
  # forward NginX
  #config.vm.network "forwarded_port", guest: 80, host: 8000
  #config.vm.network "forwarded_port", guest: 443, host: 8443
  # forward MySQL port
  config.vm.network "forwarded_port", guest: 3306, host:3306
  # forward PostgreSQL port
  # forward Play Framework service port
  config.vm.network "forwarded_port", guest:9000, host:9000
  # forward EPrints (Apache/NginX)
  config.vm.network "forwarded_port", guest:80, host:8000
  config.vm.network "forwarded_port", guest: 443, host: 8443
  # forward for Fedora4
  #
  #config.vm.network :forwarded_port, guest: 8080, host: 8080 # Tomcat
  config.vm.network :forwarded_port, guest: 9080, host: 9080 # Fixity and Reindexing


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
    echo ""
    echo " Finish setup"
    echo ""
    echo "   vagrant ssh"
    echo ""
    echo " and run the desired setup script in /vagrant."
    echo ""
    echo "+ /vagrant/setup-eprints.sh"
    echo "+ /vagrant/setup-archivesspace.sh"
    echo "+ /vagrant/setup-loris-imageserver.sh"
    echo "+ /vagrant/setup-vireo.sh"
    echo "+ /vagrant/setup-fedora4.sh"
    echo ""
  SHELL
end
