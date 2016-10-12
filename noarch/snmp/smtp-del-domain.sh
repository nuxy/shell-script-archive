#!/usr/bin/env bash
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
#   snmptrap -v 2c -c public localhost "" SNMPv2-MIB::snmpTrap.1.1 SNMPv2-MIB::sysLocation.0 s "domain"
#

MAIL_DIR=/etc/mail

read host
read ip

while read oid val; do
    if [ "$val" != "" ]; then
        domain="$val"
    fi
done

ip_addr=`echo $ip | sed -r 's/^UDP: \[([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\].*/\1/g'`

# Remove records
if grep "^$ip_addr" $MAIL_DIR/access; then
    sed -i '' "/^$ap_addr.*/d" $MAIL_DIR/access
fi

if grep "^$domain" $MAIL_DIR/domaintable; then
    sed -i '' "/^$domain.*/d" $MAIL_DIR/domaintable
fi

# Update Sendmail database and restart
makemap hash $MAIL_DIR/access.db      < $MAIL_DIR/access
makemap hash $MAIL_DIR/domaintable.db < $MAIL_DIR/domaintable

service sendmail restart

logger "Removed domain '$domain' from the Sendmail database"

exit 0
