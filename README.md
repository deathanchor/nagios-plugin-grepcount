# Nagios-grepcount

## Overview

This is a simple Nagios check script to monitor specific strings in a log file.

## Authors

### Main Author

Niko The Dread Pirate (@deathanchor)

## Installation

Install script into your nagios plugins for use with nagios checks.

## Usage

```
usage: grepcount.sh -c <CRITICAL> -w <WARNING> -f <FILE> -s <SEARCH> [-v <IGNORE_STRING>] [-t <TAIL NUMBER>] [-i]
this will search a log file using grep -c and will alert with
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
```
