#!/bin/sh
#
#  smtp-update.sh
#  Update a remote Sendmail access/domain database using SNMP
#
#  Copyright 2010-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    snmp
#    snmptrap
#    sendmail (on remote host)
#
#  Notes:
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#

# PROVIDE: dns_update
# REQUIRE: DAEMON netif
# KEYWORD: nojail

. /etc/rc.subr

name="smtp_update"
rcvar=${name}_enable
# smtp_update is set by rc.conf

start_cmd="${name}_start"
stop_cmd="${name}_stop"

COMMUNITY=private
REMOTE_HOST=mail.domain.com
DOMAIN=`hostname`
SCRIPT=`basename $0`
LOCKFILE=/var/tmp/$SCRIPT

if [ ! -x /usr/local/bin/snmptrap ]; then
    exit 1
fi

smtp_update_start() {
    STDOUT="Adding domain to Sendmail host:"

    if [ ! -e $LOCKFILE ]; then
        success=`snmptrap -v 2c -c $COMMUNITY $REMOTE_HOST "" SNMPv2-MIB::snmpTrap.2.0 SNMPv2-MIB::sysLocation.0 s $DOMAIN`

        if [ -z "$success" ]; then
            echo "$STDOUT success"
        else
            echo "$STDOUT failed"
            exit 1
        fi

        if [ $? -eq 0 ]; then
            touch $LOCKFILE
        fi
    fi
}

smtp_update_stop() {
    STDOUT="Removing domain from Sendmail host:"

    if [ -e $LOCKFILE ]; then
        success=`snmptrap -v 2c -c $COMMUNITY $REMOTE_HOST "" SNMPv2-MIB::snmpTrap.2.1 SNMPv2-MIB::sysLocation.0 s $DOMAIN`

        if [ -z "$success" ]; then
            echo "$STDOUT success"
        else
            echo "$STDOUT failed"
            exit 1
        fi

        if [ $? -eq 0 ]; then
            rm -f $LOCKFILE
        fi
    fi
}

load_rc_config $name
run_rc_command "$1"
