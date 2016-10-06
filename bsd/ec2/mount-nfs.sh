#!/bin/sh
#
#  mount-nfs.sh
#  Set-up the EFS (Elastic file system) to mount on boot.
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
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/rc.d or run from the command-line
#   - Must support EFS attachments by file-system-id
#

# PROVIDE: mount_nfs
# REQUIRE: DAEMON netif
# KEYWORD: nojail

. /etc/rc.subr

name="mount_nfs"
rcvar="${name}_enable"
# mount_nfs is set by rc.conf

start_cmd="${name}_start"

CURL_DIR=/usr/local/bin
MOUNT_POINT=/efs
NFS_ID=fs-abc123

mount_nfs_start() {
    if [ ! -d $MOUNT_POINT ]; then
        mkdir $MOUNT_POINT

        avail_zone=`$CURL_DIR/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
        aws_region=`echo $avail_zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`

        echo "$avail_zone.$NFS_ID.efs.$aws_region.amazonaws.com:/ $MOUNT_POINT nfs defaults,vers=4.1 0 0" >> /etc/fstab

        mount -a -t nfs

        echo "Mounting NFS at $MOUNT_POINT: success"
    fi
}

load_rc_config ${name}
run_rc_command "$1"
