#!/bin/bash

# Written by Niko Janceski (@deathanchor)
#

USAGE="
    usage: $0 -c <CRITICAL> -w <WARNING> -f <FILE> -s <SEARCH> [-i]
    this will search a log file using grep -c and will alert with
    Critical or Warning if that many or more items were found.
    -i for case insensitive search (default: off)
"


CRITICAL=2
WARNING=1
SEARCH='ERROR'
FILE='/var/log/messages'
CASEI=''
while getopts ':c:w:s:f:i' opt; do
    case $opt in
        c)
            CRITICAL=$OPTARG
            ;;
        w)
            WARNING=$OPTARG
            ;;
        s)
            SEARCH=$OPTARG
            ;;
        f)
            FILE=$OPTARG
            ;;
        i)
            CASEI='-i'
            ;;
        \?)
            echo "UNKNOWN OPTION"
            echo "$USAGE"
            exit 3
            ;;
    esac
    # echo "IND: $OPTIND, ARG: $OPTARG, ERR:$OPTERR, opt: $opt"
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

GREPCMD="grep -c $CASEI $SEARCH $FILE";

count=$( $GREPCMD 2>&1 );

if [[ $? -eq 0 || $? -eq 1 ]]; then
    if [[ $count -gt $CRITICAL || $count -eq $CRITICAL ]]; then
        echo "CRTICAL - $count of '$SEARCH' found in $FILE"
        exit 2
    elif [[ $count -gt $WARNING || $count -eq $WARNING ]]; then
        echo "WARNING - $count of '$SEARCH' found in $FILE"
        exit 1
    else
        echo "OK - $count of '$SEARCH' found in $FILE"
        exit 0
    fi
else
    echo "UNKNOWN - $count"
    exit 3
fi


