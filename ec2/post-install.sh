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
#    ec2-metadata
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
    /usr/local/bin/ec2-metadata --user-data > $OUTFILE

    if [ ! "$(grep 'user-data: not available' $OUTFILE)" ]; then
        /bin/sh $OUTFILE

       RESULT=/bin/true
    else
       RESULT=/bin/false
    fi

    action "Configure and launch services:" $RESULT
fi

exit 0
