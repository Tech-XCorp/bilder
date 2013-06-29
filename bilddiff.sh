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

cmd="diff -ruN -I\\\$Id -I\\\$Rev -x.svn $1 $2"
echo "$cmd"
eval "$cmd"

