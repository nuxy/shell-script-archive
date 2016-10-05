#!/usr/bin/env bash
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

FWD_ZONE=/var/named/forward/domain.com.zone.db
REV_ZONE=/var/named/reverse/10.in-addr.arpa.zone.db
ZONE_NAME=domain.com

read host
read ip

while read oid val; do
    if [ "$val" != "" ]; then
        alias=$val
    fi
done

fwd_addr=`echo $ip | sed -r 's/^UDP: \[([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\].*/\1/g'`
set ${fwd_addr//./ }
rev_addr="$4.$3.$2";

# Remove duplicates
if grep "^$alias" $FWD_ZONE; then
    sed -i '' "/^$alias.*/d" $FWD_ZONE
fi

if grep "^$rev_addr" $REV_ZONE; then
    sed -i '' "/^$rev_addr.*/d" $REV_ZONE
fi

# Create new records
echo -e "$alias\t\tA\t$fwd_addr"               >> $FWD_ZONE
echo -e "$rev_addr\t\tPTR\t$alias.$ZONE_NAME." >> $REV_ZONE

# Reload zone files
rndc reload $ZONE_NAME
rndc reload 10.in-addr.arpa

logger "Added new record '$alias' at '$fwd_addr' to DNS zone file"

exit 0
