#!/bin/sh
#
#  post-install.sh
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
    resp=`curl -s http://169.254.169.254/latest/user-data`

    if [ "$resp" != "" ]; then
        echo "$resp" > $OUTFILE
        /bin/sh $OUTFILE >& /dev/null

       RESULT=/bin/true
    else
       RESULT=/bin/false
    fi

    action "Configure and launch services:" $RESULT
fi

exit 0
