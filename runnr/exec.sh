#!/bin/bash
##########
#
# File:		exec.sh
#
# Purpose:	Execute a command, but first print its PID on the stdout.
#		Very handy if you need to run something and want to know
#		its PID in case you later have to kill it.
#
#		The key here is that exec will not spawn a new process,
#		but rather, it will overwrite the current process with the
#		new thing to be executed. So $$ will be the PID of the
#		to-be-spawned process.
#
# Version:	$Id: exec.sh 5429 2012-03-09 14:15:24Z cary $
#
##########

if test "$1" = -o; then
    echo $$ > $2
    shift
    shift
fi

exec "$@"
