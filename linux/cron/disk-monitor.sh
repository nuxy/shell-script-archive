#!/bin/sh
#
#  disk-monitor.sh
#  Monitor disk partition usage using e-mail alerts
#
#  Copyright 2001-2013, Marc S. Brooks (http://mbrooks.info)
#  Licensed under the MIT license:
#  http://www.opensource.org/licenses/mit-license.php
#
#  Notes:
#   - This script has been tested to work with Linux
#   - This script must be run as root
#   - This script can be run via cronjob
#

good=0

while [ "$#" != 0 ]; do
    flag=$1
    case "$flag" in
        -h) if [ $# -gt 1 ]; then
                host=$2
                good=1
                shift
            fi
                ;;

        -q) if [ $# -gt 1 ]; then
                quota=$2
                good=1
                shift
            fi
                ;;

        -e) if [ $# -gt 1 ]; then
                email=$2
                good=1
                shift
            else
                echo "You failed to provide an admin e-mail using the -e flag"
            fi
                ;;

         *) good=0
                ;;
    esac
    shift
done

if [ $good = 0 ]; then
cat <<EOT

Usage: disk-monitor.sh [-h hostname] [-q quota] [-e email]

Options:
  -h hostname  : specify the server hostname (default: hostname)
  -q quota     : specify the disk quota      (default: 90)
  -e email     : specify the admin e-mail address

EOT
else
    if [ -z "${host}" ]; then
        host=`hostname`
    fi

    if [ -z "${quota}" ]; then
        quota=90
    fi

    df -kP | grep -i / | awk '{ print $6" "$5}' |

    while read LINE; do
        perc=`echo $LINE | cut -d"%" -f1 | awk '{ print $2 }'`
        part=`echo $LINE | awk '{ print $1 }'`

        if [ $perc -gt $quota ]; then
            echo "Disk quota of ${perc}% has been reached" | mail -s "$part on ${host} is almost full" ${email}
        fi
    done
fi

exit 0
