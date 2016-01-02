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
      res=$?
      if test "$res" != 0; then
        echo "Error in updating $i.  Fix or just remove?"
      fi
    fi
    cd $topdir
  fi
done
