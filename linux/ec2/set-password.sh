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
#    expect
#
#  Notes:
#   - This script has been tested to work with RHEL & CentOS
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#
#  chkconfig: 3 96 96
#  description: Password update script
#

. /etc/init.d/functions

LOCKFILE=/root/.password

if [ ! -f $LOCKFILE ]; then
    password=`/usr/bin/mkpasswd -l 15 -s 0`

    action $"Password reset to: $PASSWORD" `echo $password | passwd --stdin root >& /dev/null`

    touch $LOCKFILE
fi

exit 0
