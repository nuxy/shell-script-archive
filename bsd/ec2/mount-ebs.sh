#!/bin/sh
#
#  mount-ebs.sh
#  Set-up the EBS (Elastic block store) to mount on boot.
#
#  Copyright 2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Notes:
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/rc.d or run from the command-line
#

# PROVIDE: mount_ebs
# REQUIRE: DAEMON netif
# BEFORE:  LOGIN
# KEYWORD: nojail

. /etc/rc.subr

name="mount_ebs"
rcvar="${name}_enable"
# mount_ebs is set by rc.conf

start_cmd="${name}_start"

MOUNT_POINT=/mnt/ebs
DEVICE_NAME=/dev/xbd

mount_ebs_start() {
    for device in $(ls $DEVICE_NAME*); do
        num=`echo $device | sed -e 's/^\/dev\/[a-z]*\([0-9]*\)$/\1/g'`
        dir="$MOUNT_POINT${num}"

        if [ ! -d $dir ]; then
            mkdir $dir

            fsck -n -t ufs $device

            if ! mount -t ufs $device $dir; then
                warn "Failed to mount ${device}. Skipping.."

                rm -rf $dir
                continue
            fi

            echo -e "$device\t$dir\tufs\trw,failok\t0\t2" >> /etc/fstab

            info "Mounting EBS ($device) at $dir: success"
        fi
    done
}

load_rc_config ${name}
run_rc_command "$1"
