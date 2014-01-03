#!/bin/bash
# Source this file to fix the windows path not to have parens
# Assume one has the mount,
# "C:/Program Files (x86)" /ProgramFilesX86 ntfs binary 0 0
echo $PATH >path.txt
cat >path.sed <<EOF
s/:/:\\
/g
s?cygdrive/c/Program Files (x86)?ProgramFilesX86?g
EOF
sed -f path.sed <path.txt >path.tmp
grep -v '(' path.tmp | tr -d '\n' >path.txt
#rm path.tmp
PATH=`cat path.txt`
echo PATH = $PATH
