#!/bin/sh
#
# muonato/check_softw.sh @ GitHub (07-NOV-2024)
#
# Reports software package version using rpm query or by executing an 
# arbitrary shell command. Compatible with Nagios monitoring as plugin.
#
# Usage:
#       bash check_softw.sh <package-name|command> [<package-name|command>] ...
#
#       Nagios nrpe configuration on host :
#       command[check_softw]=/path/to/plugins/check_softw.sh $ARG1$
#
# Parameters:
#       1..n: package name or shell command
#
# Examples:
#       Check single sw package using rpm query
#       $ bash check_softw.sh "fubar-one"
#
#       Check using rpm query and shell commandline
#       $ bash check_softw.sh "fubar-one" "psql --version"
#
#       Nagios plugin expression for two sw packages
#       check_nrpe -H $HOSTADDRESS$ -c check_softw -a '"fubar-one" "fubar-two"'
#
#       Nagios plugin expression for apache in docker container 'foobar'
#       check_nrpe -H $HOSTADDRESS$ -c check_softw -a '"docker exec foobar apache2 -v"'
#
# Platform:
#       Red Hat Enterprise Linux 8.9 (Ootpa)
#       Opsview Core 3.20140409.0
#
# BEGIN __main__
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
                VER=$($ARG 2>&1)
        else
                VER="$ARG $(rpm -qi $ARG|grep -i version)"
        fi

        MSG="${MSG}${i}: $VER\n"
done

# Message excl. line feed
echo -e ${MSG%??}
