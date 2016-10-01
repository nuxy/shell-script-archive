#!/bin/bash
#
#  dns-del-record.sh
#  Remove an 'A' record from the DNS zone file in Bind using SNMP
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
#   snmptrap -v 2c -c public localhost "" SNMPv2-MIB::snmpTrap.1.1 SNMPv2-MIB::sysLocation.0 s "alias"
#

FWD_ZONE=/var/named/chroot/var/named/data/forward/domain.com.zone.db
REV_ZONE=/var/named/chroot/var/named/data/reverse/10.in-addr.arpa.zone.db
ZONE_NAME=domain.com

read host
read ip

while read oid val; do
    if [ "$val" != "" ]; then
        record=$val
    fi
done

exists=`cat $FWD_ZONE | grep -P "^$record\t"`

if [ "$exists" != "" ]; then
    FWD_ADDR=`echo $ip | sed -s 's/UDP: \[\(.*\)\]\:.*/\1/g'`
    set ${FWD_ADDR//./ }
    REV_ADDR="$4.$3.$2";

    sed "/^$record\t/d"     $FWD_ZONE > $FWD_ZONE\.bak
    sed "/^$REV_ADDR\t/d" $REV_ZONE > $REV_ZONE\.bak

    mv $FWD_ZONE\.bak $FWD_ZONE
    mv $REV_ZONE\.bak $REV_ZONE

    rndc reload $ZONE_NAME
    rndc reload 10.in-addr.arpa

    logger "Removed record '$record' from the DNS zone file"
fi

exit 0
