#!/bin/sh
#
#  mount-nfs.sh
#  Set-up the EFS (Elastic file storage) to mount on boot.
# 
#  Copyright 2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    curl
#    nfs-common
#
#  Notes:
#   - This script has been tested to work with RHEL & CentOS
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#   - Must support EFS attachments by file-system-id
#
#  chkconfig: 3 95 95 
#  description: NFS mount script
#

. /etc/init.d/functions

MOUNT_POINT=/efs
NFS_ID=fs-abc123

if [ ! -d $MOUNT_POINT ]; then
    mkdir $MOUNT_POINT

    avail_zone=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
    aws_region=`echo $avail_zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`

    echo "$avail_zone.$NFS_ID.efs.$aws_region.amazonaws.com:/ $MOUNT_POINT nfs defaults,vers=4.1 0 0" >> /etc/fstab

    action $"Mounting NFS at $MOUNT_POINT: " mount -a -t nfs
fi

exit 0
