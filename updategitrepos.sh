#!/bin/sh
#
# $Id$

for i in *; do
  if test -d $i/.git; then
    echo "Updating $i."
    (cd $i; git pull)
  fi
done
