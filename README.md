
# Vireo test vm

This is a Vagrant repo for bring up a test instance of Vireo ETD software.

## Requirements under Ubuntu 16.04 LTS

+ Java >= 8 (openjdk 1.8)
+ PostgreSQL >= 9
+ Ubuntu Packages
    + default-jdk-8
    + postgress, postgres-contrib
    + git
    + ant, ant-optional
    + ivy, ivyplusplus
    + curl
    + zip/unzip
    + doxygen
+ Compiled
    + playframework 1.3.4
    + Vireo 3.0.6

## Notes

1. Install the debian packages
2. Clone playframework and Vireo from Github
3. Build play1/framework with Ant
4. Build Vireo with Play
5. "Run" Play on Vireo so that initial user gets created
6. After that Vireo can be "played" as a service with start, pid and stop


