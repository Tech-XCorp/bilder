#!/bin/sh
######################################################################
#
# @file    bilddiff.sh
#
# @brief   Documentation goes here.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

#!/bin/sh
#
# Diff two bilder directories with appropriate ignores

usage() {
cat <<EOF
Usage: bilddiff.sh <directory 1> <directory 2>
EOF
}

if test $# -lt 2; then
  usage
  exit
fi

cmd="diff -ruN -I\\\$Rev$ $Date$2"
echo "$cmd"
eval "$cmd"

