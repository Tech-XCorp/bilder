#!/bin/sh
#
# $Id$

topdir=`pwd`
for i in *; do
  if test -d $i/.git; then
    cd $i
    if git branch | grep '^\*' | grep -q detached; then
      echo "Not updating $i because it is detached."
    else
      echo "Updating $i."
      git pull
    fi
    cd $topdir
  fi
done
