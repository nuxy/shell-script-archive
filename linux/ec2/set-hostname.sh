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
    host_name=`cat $OUTFILE`
else
    host_name=`curl -s http://169.254.169.254/latest/meta-data/hostname`

    echo $host_name > $OUTFILE
fi

action $"Hostname updated:" hostname $host_name

exit 0
