#!/bin/bash

#
# Setup example provides a common set of Bash functions and serves as a seed for 
# future setup scripts.  Copy setup-example.sh to the name of the system you're
# creating and modify as needed.
#

#
# Assert the script is running as the expected user (e.g. Vagrant, root, etc).
#
function assertUsername () {
    expectedUser="$1"
    errormsg="$2"
    if [ "$expectedUser" = "" ]; then
        echo "Expected assertUsername to have a username, fix script"
        exit 1
    fi
    if [ "$USER" != "$expectedUser" ];then
        echo "This script should be run as $expectedUser"
        if [ "$errormsg" != "" ]; then
            echo "$errormsg"
        fi
        exit 1
    fi
}

#
# hasProgram checks to see if specific software binary is in the path.
#
function hasProgram() {
    progname="$1"
    errormsg="$2"

    t=$(which $progname)
    if [ "$t" = "" ];then
        echo "Missing $progname, $errormsg"
        exit 1
    fi
}






















