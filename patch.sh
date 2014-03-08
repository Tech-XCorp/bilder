#!/bin/bash
# To be run from the top level
# This gets this files from a patch
# Puts the dos files in a list
# Converts them to Unix
# Applies the patch
# Converts the previously dos files back to DOS

usage() {
  cat <<EOF
  Usage: patch.sh patchfile
    To be run at level that patch was created.
EOF
}

# Validate input
if test -z "$1"; then
  echo "patchfile missing."
  usage
  exit 1
fi

# Find files to be patched
files=`grep ^Index $1 | sed 's/^Index: *//'`
dir=`echo $files | sed -e "s?/.*??"`
echo "Patching files, "$files" in directory, $dir."

# Determine dos subset and convert those to unix
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

# Apply the patch, relative location or absolute
cd $dir
if echo $1 | grep -q "^/"; then
  cmd="patch -p1 <$1"
else
  cmd="patch -p1 <../$1"
fi
echo "$cmd"
eval "$cmd"

# Convert originally dos files back to dos
cd ..
for f in $dfiles; do
  unix2dos $f
done

