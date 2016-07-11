
# test vm

This is a Vagrant repo for bring up a test instance of various software (e.g. EPrints, ArchivesSpace, Vireo ETD, Loris, Fedora4).

## Basic setup

The installation process works the same across the setup. This example is for setting up EPrints

```
    vagrant up  && vagrant ssh
    bash /vagrant/setup-eprints.sh
```

If you were setting up another system (e.g. Vireo) then you would change "eprints" for "vireo".



