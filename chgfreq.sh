#!/bin/bash
#
# $Id$
#
# Change the clock frequency (throttling).
#
# With cpufrequtils installed, can use, e.g., chgfreq.sh performance 
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

