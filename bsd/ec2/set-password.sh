#!/bin/sh
#
#  set-password.sh
#  Generate new root password and output result to console.
#
#  Copyright 2006-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    p5-String-MkPasswd
#
#  Notes:
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#

# PROVIDE: set_password
# REQUIRE: DAEMON netif
# KEYWORD: nojail

. /etc/rc.subr

name="set_password"
start_cmd="${name}_start"

LOCKFILE=/root/.password

set_password_start() {
    if [ ! -f $LOCKFILE ]; then
        password=`/usr/local/bin/mkpasswd.pl -l 15 -s 0`

        echo $password | passwd --stdin root >& /dev/null
        echo "Password reset to: $password"

        touch $LOCKFILE
    fi
}

run_rc_command "$1"
