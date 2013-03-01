#!/bin/sh
#
#  smtp-update.sh
#  Update a remote Sendmail access/domain database using SNMP
#
#  Copyright 2010-2013, Marc S. Brooks (http://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    snmp
#    sendmail    (on remote host)
#    sendmail-cf
#
#  Notes:
#   - This script has been tested to work with RHEL & CentOS
#   - This script must be run as root
#   - This script can be installed in /etc/init.d or run from the command-line
#
#  chkconfig: 2345 98 20
#  description: Remote Sendmail database update script
#

. /etc/init.d/functions

COMMUNITY=private
HOSTNAME=`hostname`
HOST=$HOSTNAME
ALIAS=`echo $HOSTNAME | cut -d'.' -f1`
SCRIPT=`basename $0`
LOCK=/var/lock/subsys/$SCRIPT

if [ ! -x /usr/bin/snmptrap ]; then
    exit 1
fi

start() {
    STDOUT="Adding domain to Sendmail host:"

    if [ ! -e $LOCK ]; then
        action $"$STDOUT" snmptrap -v 2c -c $COMMUNITY $HOST "" SNMPv2-MIB::snmpTrap.2.0 SNMPv2-MIB::sysLocation.0 s $DOMAIN

        if [ $? -eq 0 ]; then
            touch $LOCK
        fi
    else
        echo -n $"$STDOUT"
        failure
        echo
        return 1
    fi
}

stop() {
    STDOUT="Removing domain from Sendmail host:"

    if [ -e $LOCK ]; then
        action $"$STDOUT" snmptrap -v 2c -c $COMMUNITY $HOST "" SNMPv2-MIB::snmpTrap.2.1 SNMPv2-MIB::sysLocation.0 s $DOMAIN

        if [ $? -eq 0 ]; then
            rm -f $LOCK
        fi
    else
        echo -n $"$STDOUT"
        failure
        echo
        return 1
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)

    echo $"Usage: $SCRIPT {start|stop}"
    exit 1
esac

exit 0
