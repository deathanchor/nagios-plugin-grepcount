#!/bin/bash

# Written by Niko Janceski (@deathanchor)
#
# vim:noexpantab
# vim:tabstop=4

usage="
	usage: $0 -c <CRITICAL> -w <WARNING> -f <FILE> -s <SEARCH> [-v <IGNORE_STRING>] [-t <TAIL NUMBER>] [-i]
	This will search a log file using grep -c and will alert with
	Critical or Warning if that many or more items were found.
	Defaults:
		<SEARCH> = 'ERROR'
		<CRITICAL> = 1
		<WARNING> = 1
		<FILE> = /var/log/messages
	Optional:
		-v <IGNORE_STRING> will grep -v first before counting
		-i for case insensitive search
		-t <NUMBER> tail file these # of lines and then grep
"


critical=2
warning=1
search='ERROR'
file='/var/log/messages'
casei=''
ignore_string=''
while getopts ':t:c:w:s:f:v:i' opt; do
	case $opt in
		c)
			critical=$OPTARG
			;;
		w)
			warning=$OPTARG
			;;
		s)
			search=$OPTARG
			;;
		f)
			file=$OPTARG
			;;
		t)
			tailing=$OPTARG
			;;
		i)
			casei='-i'
			;;
		v)
			ignore_string=$OPTARG
			;;
		\:)
			echo "-$OPTARG OPTION REQUIRES AN ARGUMENT"
			echo "$usage"
			exit 3
			;;
		\?)
			echo "UNKNOWN OPTION"
			echo "$usage"
			exit 3
			;;
	esac
done

shift $((OPTIND-1))  # This tells getopts to move on to the next argument.

if [[ $tailing -gt 0 ]]; then
	grepcmd() { 
		if [ -r $file ]; then
			if [ -z $ignore_string ]; then
				tail -n $tailing $file | grep -c $casei "$search" 2>&1;
			else
				tail -n $tailing $file | grep -v "$ignore_string" | grep -c $casei "$search" 2>&1;
			fi
		else 
			tail $file 2>&1 || $(exit 2); # this will fail
		fi
	}
else
	grepcmd() { 
		if [ -z $ignore_string ]; then
			grep -c $casei "$search" $file 2>&1;
		else
			grep -v "$ignore_string" $file | grep -c $casei "$search" 2>&1;
		fi
	}
fi

# declare -f grepcmd
count=$(grepcmd);

if [[ $? -eq 0 || $? -eq 1 ]]; then
	tailing=$( [[ $tailing -gt 0 ]] && echo "last $tailing lines of" )
	ignore_string=$( [[ ! -z $ignore_string ]] && echo "ignoring '$ignore_string'" )
	if [[ $count -gt $critical || $count -eq $critical ]]; then
		echo "CRTICAL - $count of '$search' found in $tailing $file $ignore_string"
		exit 2
	elif [[ $count -gt $warning || $count -eq $warning ]]; then
		echo "WARNING - $count of '$search' found in $tailing $file $ignore_string"
		exit 1
	else
		echo "OK - $count of '$search' found in $tailing $file $ignore_string"
		exit 0
	fi
else
	echo "UNKNOWN - $count"
	exit 3
fi


