#!/bin/sh

bdir=`dirname $0`
bdir=`(cd $bdir; pwd -P)`

replaceName() {
  for j in */* *; do
    if grep -q $1 $j; then
      echo $j contains $1
      sed -i.bak "s/$1/$2/g" $j
    fi
  done
  find . -name '*.bak' -delete
}

for i in */scimake */txcmake bilder txcbilder; do
  cd $i
  echo Examining $i.

  replaceName isCcCc4py isCcPyc
  replaceName cc4py pycsh
  replaceName CC4PY PYCSH
  replaceName FORPYTHON_BUILD FORPYTHON_SHARED_BUILD

  cd - 1>/dev/null 2>&1
done
