#!/bin/sh
#
#  smtp-add-domain.sh
#  Add a new domain to the Sendmail access/domain database using SNMP
#
#  Copyright 2010-2013, Marc S. Brooks (http://domain.com)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    snmp
#    snmptrapd
#    sendmail
#    sendmail-cf
#
#  Notes:
#   - This script has been tested to work with RHEL & CentOS 5.5
#   - Requires a properly configured snmpd.conf and snmptrapd.conf
#   - This script must be executed via an SNMP trap
#
#  Command:
#   snmptrap -v 2c -c public localhost "" SNMPv2-MIB::snmpTrap.1.1 SNMPv2-MIB::sysLocation.0 s "alias"
#

MAIL_HOST=mail.domain.com
MAIL_DIR=/etc/mail

read host
read ip

while read oid val; do
    if [ "$val" != "" ]; then
        NAME="$val"
    fi
done

EXISTS=`cat $MAIL_DIR/domaintable | grep -P "^$NAME\t"`

if [ "$EXISTS" = "" ]; then
    IP_ADDR=`echo $ip | sed -s 's/UDP: \[\(.*\)\]\:\w\+\?/\1/g'`

    echo -e "$IP_ADDR\t\t\tRELAY"   >> $MAIL_DIR/access
    echo -e "$NAME\t\t\t$MAIL_HOST" >> $MAIL_DIR/domaintable

    makemap hash $MAIL_DIR/access      < $MAIL_DIR/access
    makemap hash $MAIL_DIR/domaintable < $MAIL_DIR/domaintable

    service sendmail restart

    logger "Added new domain '$NAME' to the Sendmail database"
fi

exit 0
