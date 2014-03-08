#!/bin/bash
# To be run from the top level
# This gets this files from a patch
# Puts the dos files in a list
# Converts them to Unix
# Applies the patch
# Converts the previously dos files back to DOS

files=`grep ^Index $1 | sed 's/^Index: *//'`
echo "Files are" $files
dir=`echo $files | sed -e "s?/.*??"`
echo "Directory is" $dir
dfiles=
for f in $files; do
  if file $f | grep -q ' CRLF '; then
    dfiles="$dfiles $f"
  fi
done
echo "DOS files are" $dfiles
for f in $dfiles; do
  dos2unix $f
done
cd $dir
cmd="patch -p1 <../$1"
echo "$cmd"
eval $cmd
cd ..
for f in $dfiles; do
  unix2dos $f
done

