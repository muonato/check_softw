#!/bin/sh
#
# muonato/check_softw.sh @ GitHub (17-JUL-2025)
#
# Reports software package version using rpm query or runs an arbitrary
# shell command. Compatible with Nagios monitoring as host plugin.
#
# Usage:
#       bash check_softw.sh <package-name|command> [<package-name|command>] ...
#
#       Nagios nrpe configuration on host :
#       command[check_softw]=/path/to/plugins/check_softw.sh $ARG1$
#
# Parameters:
#       1: Format output (OPTIONAL): 'LF' for line feed (default CSV)
#       n: package name or shell command
#
# Examples:
#       Check single sw package using rpm query
#       $ bash check_softw.sh "fubar-one"
#
#       Use rpm query and shell commandline, output /w line feed
#       $ bash check_softw.sh LF "fubar-one" "psql --version"
#
#       Nagios plugin expression for two sw packages, output /w line feed
#       check_nrpe -H $HOSTADDRESS$ -c check_softw -a '"LF" "fubar-one" "fubar-two"'
#
#       Nagios plugin expression for apache in docker container 'foobar'
#       check_nrpe -H $HOSTADDRESS$ -c check_softw -a '"docker exec foobar apache2 -v"'
#
# Platform:
#       Red Hat Enterprise Linux 8.9 (Ootpa)
#       Opsview Core 3.20140409.0
#
# BEGIN __main__
ARGS=("$@")

if [[ -z "$ARGS" ]]; then
    echo -e "Check software version\n\tUsage:\
    `basename $0` [OPTIONS] <package-name|command> [<package-name>|command] ...\
        \n\tOPTIONS:\n\t\tLF - Format output with line feed
        \n\tERROR: missing parameter(s)"
    exit 3
fi

FRMT=", "
MESG=""

# First parameter formats output
if [[ ${ARGS[0]} == "LF" ]]; then
        FRMT="\n"
        unset ARGS[0]
fi

# Query rpm when parameter is single word,
# otherwise execute as shell command
for ARG in "${ARGS[@]}"; do
        SUM=$(echo $ARG|wc -w)

        if [[ $SUM -gt 1 ]]; then
                VER=$($ARG 2>&1)
        else
                VER="$ARG $(rpm -qi $ARG|grep -m 1 -i version)"
        fi

        MESG="${MESG}$VER$FRMT"
done

# Exclude last char
echo -e ${MESG%??}
exit 0
