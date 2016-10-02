#!/bin/sh
#
#  set-hostname.sh
#  Set the instance name to the EC2 defined public hostname.
#
#  Copyright 2009-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Notes:
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/rc.d or run from the command-line
#

# PROVIDE: set_hostname
# REQUIRE: DAEMON netif
# KEYWORD: nojail

. /etc/rc.subr

name="set_hostname"
start_cmd="${name}_start"

OUTFILE=/root/.hostname

set_hostname_start() {
    if [ -f $OUTFILE ]; then
        host_name=`cat $OUTFILE`
    else
        host_name=`curl --silent http://169.254.169.254/latest/meta-data/hostname`

        echo $host_name > $OUTFILE
    fi

    hostname $host_name
    echo -n "Hostname updated: success"
}

run_rc_command "$1"
