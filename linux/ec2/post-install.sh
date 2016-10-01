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
#   - This script has been tested to work with RHEL & CentOS
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#
#  chkconfig: 3 98 98
#  description: Post-install configuration script
#

. /etc/init.d/functions

OUTFILE=/root/.install
LOGFILE=/var/log/post-install.log

if [ ! -f $OUTFILE ]; then
    user_data=`curl -s http://169.254.169.254/latest/user-data`

    if [ ! "$(echo $user_data | grep 404)" ]; then
        echo "$user_data" > $OUTFILE
        chmod 755 $OUTFILE
        exec $OUTFILE 2>&1 | tee -a $LOGFILE
        chmod 644 $OUTFILE

        result=/bin/true
    else
        result=/bin/false
    fi

    action "Configure and launch services:" $result
fi

exit 0
