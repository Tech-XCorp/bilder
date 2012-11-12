#!/bin/bash
#
# Change to a new programming environment
# Source this file above the bilder directory.  E.g.,
#   source ./bilder/changeprogenv.sh pgi
# to change to pgi paths.
#
# $Id: changeprogenv.sh 6596 2012-09-03 14:48:14Z cary $

#
# Method to print out general and script specific options
#
usage() {
  cat >&2 <<_
Usage: $0 [options] <newenv>
<newenv> is the new value for PrgEnv
OPTIONS
  -h    print this message
_
}

while getopts "h" arg; do
  case "$arg" in
    h) usage; exit;;
  esac
done

if test -z "$1"; then
  echo You need to specify a value new PrgEnv compiler as the last argument.
  exit
fi

# mydir=`dirname $0`
# source $mydir/mkvars-nersc.sh
source bilder/defaultsfcns.sh
setBilderHostVars
echo Compiler is $compiler
echo New compiler is $1
oldcompver=$COMPVER
echo oldcompver=$oldcompver

# cmd="modulecmd bash switch PrgEnv-$compiler PrgEnv-$1"
cmd="module switch PrgEnv-$compiler PrgEnv-$1"
echo $cmd
# cmdres=`$cmd`
$cmd
if test $? != 0; then
  echo 'Command failed.  Valid compiler?'
fi

setBilderHostVars
newcompver=$COMPVER
echo newcompver=$newcompver

# echo Old PATH = $PATH
newpath=`echo $PATH | sed "s/$oldcompver/$newcompver/g"`
PATH=$newpath
# echo New PATH = $PATH

# For janus
cat >/dev/null <<EOF
unuse .openmpi-1.6_intel-12.1.4_torque-2.5.11
use .openmpi-1.6_gcc-4.7.1_torque-2.5.11_ib
# And to check
env | grep _dk_inuse
EOF

