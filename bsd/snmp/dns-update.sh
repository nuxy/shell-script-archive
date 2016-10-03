#!/bin/sh
#
#  dns-update.sh
#  Update a remote DNS zone record using SNMP
#
#  Copyright 2010-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    snmp
#    snmptrap
#    bind (on remote host)
#
#  Notes:
#   - This script has been tested to work with FreeBSD & OpenBSD
#   - This script must be run as root
#   - This script can be installed in /etc/rc.d or run from the command-line
#

# PROVIDE: dns_update
# REQUIRE: DAEMON netif
# KEYWORD: nojail

. /etc/rc.subr

name="dns_update"
rcvar=${name}_enable
# dns_update is set by rc.conf
 
start_cmd="${name}_start"
stop_cmd="${name}_stop"

COMMUNITY=private
HOSTNAME=`hostname`
REMOTE_HOST=ns.domain.com
ALIAS=`echo $HOSTNAME | cut -d'.' -f1`
SCRIPT=`basename $0`
LOCKFILE=/var/tmp/$SCRIPT

if [ ! -x /usr/local/bin/snmptrap ]; then
    exit 1
fi

dns_update_start() {
    STDOUT="Adding record to remote DNS host:"

    if [ ! -e $LOCKFILE ]; then
        success=`snmptrap -v 2c -c $COMMUNITY $REMOTE_HOST "" SNMPv2-MIB::snmpTrap.1.0 SNMPv2-MIB::sysLocation.0 s $ALIAS`

        if [ "$success" != "" ]; then
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

dns_update_stop() {
    STDOUT="Removing record from the remote DNS host:"

    if [ -e $LOCKFILE ]; then
        success=`snmptrap -v 2c -c $COMMUNITY $REMOTE_HOST "" SNMPv2-MIB::snmpTrap.1.1 SNMPv2-MIB::sysLocation.0 s $ALIAS`

        if [ "$success" != "" ]; then
            echo "$STDOUT success"
        else
            echo "$STDOUT failed"
            exit 1
        fi

        if [ $? -eq 0 ]; then
            rm -f $LOCKFILE
        fi
    else
        echo "$STDOUT failed"
        exit 1
    fi
}

load_rc_config $name
run_rc_command "$1"
