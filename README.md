
# test vm

This is a Vagrant repo for bring up a test or development instance of various software (e.g. EPrints, ArchivesSpace, Vireo ETD, Loris, Fedora4).

## Basic setup

The installation process works the same across the setup. This example is for setting up EPrints

```
    vagrant up  && vagrant ssh
    bash /vagrant/setup-eprints.sh
```

If you were setting up another system (e.g. Vireo) then you would change "eprints" for "vireo".

## setup-*.sh

The setup files assume Bash and Ubuntu 16.04 LTS as a host system. This means that it could be used with AWS VMs that are also based on
Ubuntu 16.04 LTS. This allows us to explore a simple solution for bringing up library system without having to revert to Chef, Ansible or
other release management software.

Why?  Because each dependent layer of abstraction comes at a cost. Our systems tend to be simple and largely standalone.  Bash is VERY
mature and used for many duties from system administration to data carpentry applications.  Bash is even coming to Windows 10! 
Bash remains common, because of availability, in implementing application specific setup so why not leverage that?

If we were deploying swarms of VMs, custers or other large scale management then adopting a system like Chef or Ansible may make more sense
but increasely this type of management is being addressed in other layers (e.g. unikernal compiled applications, containers with in a virtual 
or bare metal machine)



