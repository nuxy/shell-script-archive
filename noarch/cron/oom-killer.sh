#!/bin/sh
#
#  oom-killer.sh
#  Create a OOM (out of memory) exception handler for a selected process.
#
#  Copyright 2004-2016, Marc S. Brooks (https://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Dependencies:
#    pidof
#
#  Notes:
#   - This script has been tested to work with Unix-like operating systems
#   - This script cannot be run in a virtualized environment
#   - This script must be run as root
#   - This script can be run via cronjob
#

good=0

while [ "$#" != 0 ]; do
    flag=$1
    case "$flag" in
        -p) if [ $# -gt 1 ]; then
                proc=$2
                good=1
                shift
            else
                echo "You failed to provide a server process using the -p flag"
            fi
                ;;

         *) good=0
                ;;
    esac
    shift
done

if [ $good = 0 ]; then
cat <<EOT

Usage: oom-killer.sh [-p process]

Options:
  -p process  : specify the server process to be excluded by OOM

EOT
else
    found=`ps aux | grep "[/]${proc}" | wc -l`

    if [ $found -gt 0 ]; then

        # create OOM kill exception for the selected process
        for pid in $(pidof ${proc}); do
            echo -17 | tee /proc/$pid/oom_adj > /dev/null
        done
    else
        echo "${proc} is not a valid server process"
        exit 1
    fi
fi

exit 0
