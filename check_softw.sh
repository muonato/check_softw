#!/bin/sh
#
# muonato/check_softw.sh @ GitHub (16-DEC-2023)
#
# Reports software package version using rpm query,
# compatible with Nagios monitoring as host plugin
#
# Usage:
#       bash check_softw.sh <package-name> [<package-name>] ...
#
#       Nagios nrpe configuration on host :
#       command[check_rpmq]=/path/to/plugins/check_rpmq.sh $ARG1$
#
# Parameters:
#       1..n: package name
#
# Examples:
#       $ bash check_rpmq.sh fubar-one
#       (Check single software package)
#
#       check_nrpe -H $HOSTADDRESS$ -c check_rpmq -a 'fubar-one fubar-two'
#       (Nagios monitor expression for two packages)
#
# Platform:
#       Red Hat Enterprise Linux 8.9 (Ootpa)
#       Opsview Core 3.20140409.0
#

# BEGIN __main__
umask 0077

if [[ -z "$1" ]]; then
    echo -e "check software package version\n\tUsage:\
    `basename $0` <package-name> [<package-name>] ...\n
    \tERROR: missing package name"
    exit 3
else
    MSG=""
fi

# Loop args to append message
for (( i=1; i<=$#; i++ )); do
        ARG=${@:i:1}
        SUM=$(echo $ARG|wc -w)

        if [[ $SUM -gt 1 ]]; then
                VER=$(eval $ARG)
        else
                VER="$ARG $(rpm -qi $ARG|grep -i version)"
        fi

        MSG="${MSG}${i}: $VER\n"
done

# Message excl. line feed
echo -e ${MSG%??}
