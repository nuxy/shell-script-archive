#!/bin/sh
#
#  get-pubkey.sh
#  Install the public key for the select user
#
#  Copyright 2008-2013, Marc S. Brooks (http://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Notes:
#   - This script has been tested to work with RHEL & CentOS
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#   - The authorized_keys outfile requires local user permissions
#
#  chkconfig: 3 97 97
#  description: Account update script
#

. /etc/init.d/functions

OUTFILE=~/.ssh/authorized_keys

if [ -f $OUTFILE ]; then
    action $"Public key installed:" `curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > $OUTFILE`
else
    exit 1
fi

exit 0
