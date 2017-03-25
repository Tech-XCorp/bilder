#!/bin/sh
######################################################################
#
# @file    exec.sh
#
# @brief   Execute a command, but first print its PID on the stdout.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# Execute a command, but first print its PID on the stdout.
# Very handy if you need to run something and want to know
# its PID in case you later have to kill it.
#
# The key here is that exec will not spawn a new process,
# but rather, it will overwrite the current process with the
# new thing to be executed. So $$ will be the PID of the
# to-be-spawned process.
#
######################################################################

if test "$1" = -o; then
    echo $$ > $2
    shift
    shift
fi

exec "$@"
