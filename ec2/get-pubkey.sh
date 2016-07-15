#!/bin/sh
#
#  get-pubkey.sh
#  Install the public key for the root user
#
#  Copyright 2008-2013, Marc S. Brooks (http://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Notes:
#   - This script has been tested to work with RHEL & CentOS
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#   - SSH authorized_keys file requires local user permissions
#
#  chkconfig: 3 97 97
#  description: Account update script
#

. /etc/init.d/functions

PUBLIC_KEY=`curl --silent http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key`

if [ -n "$PUBLIC_KEY" ]; then
    OUTFILE=/root/.ssh/authorized_keys

    if [ ! -f $OUTFILE ]; then
        touch $OUTFILE
    fi

    action $"Public key installed:" `echo $PUBLIC_KEY > $OUTFILE`
fi

exit 0
