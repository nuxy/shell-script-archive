#!/bin/sh
#
#  smtp-del-domain.sh
#  Remove a domain from the Sendmail access/domain database using SNMP
#
#  Copyright 2010-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    snmp
#    snmptrapd
#    sendmail
#    sendmail-cf (Linux only)
#
#  Notes:
#   - This script has been tested to work with Unix-like operating systems
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
        record="$val"
    fi
done

exists=`cat $MAIL_DIR/domaintable | grep -P "^$record\t"`

if [ "$exists" != "" ]; then
    ip_addr=`echo $ip | sed -s 's/UDP: \[\(.*\)\]\:.*/\1/g'`

    sed "/^$ip_addr\t/d" $MAIL_DIR/access      > $MAIL_DIR/access\.bak
    sed "/^$record\t/d"  $MAIL_DIR/domaintable > $MAIL_DIR/domaintable\.bak

    mv $MAIL_DIR/access\.bak      $MAIL_DIR/access
    mv $MAIL_DIR/domaintable\.bak $MAIL_DIR/domaintable

    makemap hash $MAIL_DIR/access      < $MAIL_DIR/access
    makemap hash $MAIL_DIR/domaintable < $MAIL_DIR/domaintable

    service sendmail restart

    logger "Removed domain '$record' from the Sendmail database"
fi

exit 0
