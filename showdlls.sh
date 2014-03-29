#!/bin/bash

mydir=`dirname $0`
source $mydir/runnr/runnrfcns.sh
# Compute the dlls of these objects
while test -n "$1"; do
  oname=`genbashvar $1`_dlls
  depends /c /ot:${oname}.out /f:1 ${$1}
  grep "DLL$" ${objvar}dlls.txt |\
    grep -v ":\\\\windows" |\
    grep -v "\\\\internet explorer" |\
    sed -e "s/^.*] *//" |\
    grep ":" |\
    tr "\\r\\n" ";" > ${oname}.txt
  shift
done

