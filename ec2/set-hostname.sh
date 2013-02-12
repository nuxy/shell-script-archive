#!/bin/sh
#
#  set-hostname.sh
#  Set the instance name to the public hostname
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
#  chkconfig: 3 95 95 
#  description: Hostname update script
#

. /etc/init.d/functions

OUTFILE=/root/.hostname

if [ -f $OUTFILE ]; then
    HOST=`cat $OUTFILE`
else
    HOST=`/usr/local/bin/ec2-metadata --public-hostname | awk '{ print $2 }'`

    echo $HOST > $OUTFILE
fi

action $"Hostname updated:" hostname $HOST

exit 0
