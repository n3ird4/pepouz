#!/bin/bash
# Author: n3ird4
# Sat May  9 01:42:42 CEST 2020
# pepouz.sh: Creates logs to help troubleshooting issues
# Big up Ox4 brisket power !!!
#
# Version: 0.1
#

#{{{ COMMANDS
WHOAMI=/usr/bin/whoami
MKDIR=/bin/mkdir
NETSTAT=/bin/netstat
GREP=/bin/grep
DATE=/bin/date
AWK=/usr/bin/awk
MYSQL=/usr/bin/mysql
PS=/bin/ps
TIMEOUT=/usr/bin/timeout
PSTREE=/usr/bin/pstree
SS=/bin/ss
LS=/bin/ls
IP=/sbin/ip
LSOF=/usr/bin/lsof
UPTIME=/usr/bin/uptime
FREE=/usr/bin/free
IPCS=/usr/bin/ipcs
XARGS=/usr/bin/xargs
STRACE=/usr/bin/strace
SLEEP=/bin/sleep
WGET=/usr/bin/wget
IP=/sbin/ip
CAT=/bin/cat
ECHO=/bin/echo
PIDOF=/bin/pidof
TR=/usr/bin/tr
TOP=/usr/bin/top
SLEEP=/bin/sleep
UNAME=/bin/uname
W=/usr/bin/w
#}}}


if [ `$WHOAMI` != "root" ]; then
    if [ `$WHOAMI` != "n3ird4" ]; then
        $ECHO "You need to be root to launch this script"
        exit 1
    fi
fi

$CAT << "EOF"

                ,        ,
               /(        )`
               \ \___   / |
               /- _  `-/  '
              (/\/ \ \   /\
              / /   | `    \
              O O   ) /    |
              `-^--'`<     '
             (_.)  _  )   /
              `.___/`    /
                `-----' /
   <----.     __ / __   \
   <----|====O)))==) \) /====
   <----'    `--' `.__,' \
                |        |
                 \       /       /\
            ______( (_  / \______/
          ,'  ,-----'   |
          `--{__________)

        Pepouz is now running...

EOF
# subshell
(
    DESTDIR="/space/OTHERS/"$($DATE +%Y%m%d-%Hh%Mm%Ss)
    TOUTSTR=15

    $MKDIR -p $DESTDIR

    # network
    $NETSTAT -laputen > $DESTDIR/netstat_laputen.txt
    $SS > $DESTDIR/ss.txt

    # MySQL
    if [[ `$PSTREE | $GREP mysql` ]]; then
        MySQL_Port=$($GREP mysql $DESTDIR/netstat_laputen.txt | $GREP LISTEN | $AWK '{print $4}' | cut -d':' -f2)
        for instance in `$ECHO $MySQL_Port`; do
            $MYSQL -e "SHOW FULL PROCESSLIST;" > $DESTDIR/full_processlist-$instance.txt
            $MYSQL -e "SHOW ENGINE INNODB STATUS\G" > $DESTDIR/innod_engine-status-$instance.txt
        done
    fi

    # Apache
    if [[ `$PSTREE | $GREP apache` ]]; then
        Apache_Port=$($GREP apache $DESTDIR/netstat_laputen.txt | $AWK '{print $4}' | cut -d':' -f2)
        $WGET -q --no-proxy localhost:$Apache_Port/server-status -O $DESTDIR/server-status.html &
        #commandlinefu tips:
        #$PS auxw | $GREP apache | $AWK '{print"-p " $2}' | $TIMEOUT ${TOUTSTR} $XARGS $STRACE -ttT -s 4096 2> $DESTDIR/strace_apache.txt &
        # Work in progress...
        $STRACE -f -ttT -s1024 -p `$PIDOF apache2 | $TR ' ' ','` 2> $DESTDIR/apache2-strace.txt &
    fi

    $PS faux > $DESTDIR/ps_faux.txt &
    $LSOF > $DESTDIR/lsof.txt &
    $TOP -b -n 1 > $DESTDIR/top.txt &

    $SLEEP 1s

    $UNAME -a > $DESTDIR/uname_a.txt &
    $UPTIME > $DESTDIR/uptime.txt &
    $CAT /proc/loadavg > $DESTDIR/load.txt &
    $LS -l /proc/*/fd/ 2> /dev/null > $DESTDIR/file_descriptors.txt &
    $IP a l > $DESTDIR/ip_a_l.txt &

    $SLEEP 1s

    $FREE -gth > $DESTDIR/free_gth.txt &
    $W > $DESTDIR/w.txt &
    $IPCS > $DESTDIR/ipcs.txt &
) &
