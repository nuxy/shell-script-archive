#!/bin/sh
#
#  dns-add-record.sh
#  Add a new 'A' record to the DNS zone file in Bind using SNMP
#
#  Copyright 2010-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    bind
#    snmp
#    snmptrapd
#
#  Notes:
#   - This script has been tested to work with Unix-like operating systems
#   - Requires a reverse zone record (10.in-addr.arpa)
#   - Requires a properly configured snmpd.conf and snmptrapd.conf
#   - This script must be executed via an SNMP trap
#
#  Command:
#   snmptrap -v 2c -c public localhost "" SNMPv2-MIB::snmpTrap.1.0 SNMPv2-MIB::sysLocation.0 s "alias"
#

FWD_ZONE=/var/named/chroot/var/named/data/forward/domain.com.zone.db
REV_ZONE=/var/named/chroot/var/named/data/reverse/10.in-addr.arpa.zone.db
ZONE_NAME=domain.com

read host
read ip

while read oid val; do
    if [ "$val" != "" ]; then
        NAME=$val
    fi
done

EXISTS=`cat $FWD_ZONE | grep -P "^$NAME\t"`

if [ "$EXISTS" = "" ]; then
    FWD_ADDR=`echo $ip | sed -s 's/UDP: \[\(.*\)\]\:.*/\1/g'`
    set ${FWD_ADDR//./ }
    REV_ADDR="$4.$3.$2";

    echo -e "$NAME\t\tA\t$FWD_ADDR" >> $FWD_ZONE
    echo -e "$REV_ADDR\t\tPTR\t$NAME.$ZONE_NAME." >> $REV_ZONE

    rndc reload $ZONE_NAME
    rndc reload 10.in-addr.arpa

    logger "Added new record '$NAME' to DNS zone file"
fi

exit 0
