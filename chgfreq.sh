#!/bin/sh
######################################################################
#
# @file    chgfreq.sh
#
# @brief   Change the clock frequency (throttling).
# With cpufrequtils installed, can use, e.g., chgfreq.sh performance
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

usage() {
  cat >&2 <<EOF
Usage: $0 [options] <value>
  where value is empty (print current setting) or one of
    ondemand performance powersave
  to change the frequency throttling
OPTIONS:
  -h  Print this help

performance = throttling OFF
on demand = when you run a job, it will step up the power consumption
powersave = throttling on all the time

(OK to leave it at 'performance' and throttling will stay off until next reboot)
EOF
  exit $1
}

while getopts "h" arg; do
  case "$arg" in
    h) usage; exit;;
  esac
done
value=$1
# if test -z "$value"; then
  # usage
  # exit
# fi
case "$value" in
  ondemand | performance | powersave | "")
    ;;
  *)
    usage
    exit
    ;;
esac

i=0
gov=/sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor
if test -f $gov; then
  while test -f $gov; do
    if test -n "$value"; then
      cmd="echo $value > $gov"
      echo "$cmd"
      echo $value > $gov
    else
      # cmd="cat $gov"
      # echo "$cmd"
      # $cmd
      valgot=`cat $gov`
      echo cpu${i}: $valgot
    fi
    i=`expr $i + 1`
    gov=/sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor
  done
else
  echo $gov does not exist.
fi

