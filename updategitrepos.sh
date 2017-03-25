#!/bin/sh
######################################################################
#
# @file    updategitrepos.sh
#
# @brief   Update git repos under a Bilder project.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

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
