#!/bin/sh
#
#  get-pubkey.sh
#  Install the EC2 configured SSH public key for a given user.
#
#  Copyright 2008-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Notes:
#   - This script has been tested to work with RHEL & CentOS
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#   - SSH authorized_keys file requires local user permissions
#
#  chkconfig: 3 97 97
#  description: Account update script
#

. /etc/init.d/functions

HOME_DIR=/root

public_key=`curl -s http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key`

if [ -n "$public_key" ]; then
    sshdir=$HOME_DIR/.ssh

    if [ ! -d $sshdir ]; then
        mkdir $sshdir
        chmod 700 $sshdir
    fi

    keyfile=$sshdir/authorized_keys

    if [ ! -f $keyfile ]; then
        touch $keyfile
        chmod 600 $keyfile
    fi

    action $"Public key installed:" `echo $public_key > $keyfile`
fi

exit 0
