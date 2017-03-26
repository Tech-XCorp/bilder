#!/bin/sh
######################################################################
#
# @file    setatlaspath.sh
#
# @brief   Source this file to fix the windows path not to have parens
#          Assume one has the mount,
#          "C:/Program Files (x86)" /ProgramFilesX86 ntfs binary 0 0
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

echo $PATH >/tmp/path$$.txt
cat >/tmp/path$$.sed <<EOF
s/:/:\\
/g
s?cygdrive/c/Program Files (x86)?ProgramFilesX86?g
EOF
sed -f /tmp/path$$.sed </tmp/path$$.txt >/tmp/path$$.tmp
grep -v '(' /tmp/path$$.tmp | tr -d '\n' >/tmp/path$$.txt
PATH=`cat /tmp/path$$.txt`
rm /tmp/path$$.tmp /tmp/path$$.txt /tmp/path$$.sed
echo PATH = $PATH
