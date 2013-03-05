#!/bin/sh
#
#  post-install.sh (updated: 3/5/2012)
#  Configure and launch non-ephemeral services from a user-data script
#
#  Copyright 2009-2013, Marc S. Brooks (http://mbrooks.info)
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

if [ ! -f $OUTFILE ]; then
    USERDATA=`curl -s http://169.254.169.254/latest/user-data`

    if [ ! "$(echo $USERDATA | grep 404)" ]; then
        echo "$USERDATA" > $OUTFILE
        chmod 755 $OUTFILE
        exec $OUTFILE 2>&1 | tee -a /var/log/post-install.log
        chmod 644 $OUTFILE

        RESULT=/bin/true
    else
        RESULT=/bin/false
    fi

    action "Configure and launch services:" $RESULT
fi

exit 0
