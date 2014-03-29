#!/bin/bash

mydir=`dirname $0`
# echo "0 = $0. mydir = $mydir."
# source $mydir/runnr/runnrfcns.sh
source $mydir/bildfcns.sh
# Compute the dlls of these objects
while test -n "$1"; do
  oname=`genbashvar $1`_dlls
  echo "Output is in ${oname}.out"
  depends /c /ot:${oname}.out /f:1 `cygpath -w $1`
  grep "DLL$" ${oname}.out |\
    grep -v ":\\\\windows" |\
    grep -v "\\\\internet explorer" |\
    sed -e "s/^.*] *//" |\
    grep ":" |\
    tr "\\r\\n" ";" > ${oname}.txt
  dlls=`cat ${oname}.txt`
  dlls=`echo $dlls | sed 's/;$//'`
  echo "dlls = $dlls"
  shift
done

