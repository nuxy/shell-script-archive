#!/bin/sh
#
#  get-pubkey.sh
#  Install the EC2 configured SSH public key for a given user.
#
#  Copyright 2008-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    curl
#
#  Notes:
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/rc.d or run from the command-line
#   - SSH authorized_keys file requires local user permissions
#

# PROVIDE: get_pubkey
# REQUIRE: DAEMON netif
# KEYWORD: nojail

. /etc/rc.subr

name="get_pubkey"
rcvar="${name}_enable"
# get_pubkey is set by rc.conf

start_cmd="${name}_start"

CURL_BIN=/usr/local/bin/curl
HOME_DIR=/root

get_pubkey_start() {
    public_key=`$CURL_BIN -s http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key`

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

        echo $public_key > $keyfile
        echo "Public key installed: success"
    fi
}

load_rc_config ${name}
run_rc_command "$1"
