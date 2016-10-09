#!/usr/bin/env bash
#
#  mount-ebs.sh
#  Set-up the EBS (Elastic block store) to mount on boot.
#
#  Copyright 2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    curl
#
#  Notes:
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/rc.d or run from the command-line
#   - Must support EFS attachments by file-system-id
#

# PROVIDE: mount_ebs
# REQUIRE: LOGIN DAEMON NETWORKING mountcritlocal
# KEYWORD: nojail

. /etc/rc.subr

name="mount_ebs"
rcvar="${name}_enable"
# mount_ebs is set by rc.conf

start_cmd="${name}_start"

CURL_BIN=/usr/local/bin/curl
META_URL='http://169.254.169.254/latest/meta-data/block-device-mapping'
MOUNT_POINT=/mnt/ebs

mount_ebs_start() {
    declare -A block_map

    i=0
    for letter in {a..z}; do
        block_map[sd${letter}]="xbd${i}"
        ((i++))
    done

    j=0
    for device in `$CURL_BIN -s $META_URL/`; do
        if [[ ! $device =~ ^ebs ]]; then
            continue
        fi

        block=${block_map[`$CURL_BIN -s $META_URL/$device`]}

        if [ $j -gt 1 ]; then
            MOUNT_POINT="$MOUNT_POINT${j}"
        fi

        if [ ! -d $MOUNT_POINT ]; then
            mkdir $MOUNT_POINT
            echo -e "/dev/$block\t$MOUNT_POINT\tufs\trw,failok\t0\t2" >> /etc/fstab
            mount $MOUNT_POINT

            echo "Mounting EBS volumes: success"
        fi

        ((j++))
    done
}

load_rc_config ${name}
run_rc_command "$1"
