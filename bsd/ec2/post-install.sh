#!/bin/sh
#
#  post-install.sh
#  Configure and launch non-ephemeral services from a user-data script.
#
#  Copyright 2009-2016, Marc S. Brooks (https://mbrooks.info)
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
#

# PROVIDE: post_install
# REQUIRE: DAEMON netif
# KEYWORD: nojail

. /etc/rc.subr

name="post_install"
start_cmd="${name}_start"

CURL_DIR=/usr/local/bin
OUTFILE=/root/.install

post_install_start() {
    if [ ! -f $OUTFILE ]; then
        user_data=`$CURL_DIR/curl -s http://169.254.169.254/latest/user-data`

        if [ ! "$(echo $user_data | grep 404)" ]; then
            echo "$user_data" > $OUTFILE
            chmod 755 $OUTFILE
            exec $OUTFILE 2>&1 | tee -a /var/log/post_install.log
            chmod 644 $OUTFILE

            result="success"
        else
            result="failed"
        fi

        echo "Configure and launch services: $result"
    fi
}

run_rc_command "$1"
