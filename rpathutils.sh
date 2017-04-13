#!/bin/sh
######################################################################
#
# @file    rpathutils.sh
#
# @brief   Common methods to fix up rpath in binaries/shared-libs
#
# @version $Rev: 3578 $ $Date: 2017-04-13 08:20:53 -0600 (Thu, 13 Apr 2017) $
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################


######################################################################
#
# Sanity check
#
######################################################################

# Check if chrpath program exists in contrib install location
if ! test -e "$CONTRIB_DIR/bin/chrpath"; then
  echo "chrpath not found in contrib installation, check build"
  echo "rpathutils.sh exiting"
  exit
fi


######################################################################
#
# Takes a directory name/executable that needs its rpath edited.
# Assumes that chrpath build exists in a -k 'contrib' directory
#
# Args:
#  1. full path to directory/executable-name to be edited
#  2. location for rpath to be changed to
#
######################################################################

fixRpathForExec() {

  EXEC_PATH=$1
  RPATH=$2

  echo ""
  echo "fixRpathForExec: EXEC_PATH=$EXEC_PATH"
  echo "fixRpathForExec:     RPATH=$RPATH"

  # Find all executables in a directory and run chrpath
  # This skips running chrpath on non-executable files
  local BINARIES=`ls -1 $EXEC_PATH/*`

  for exe in $BINARIES; do
    if test -x $exe; then
      echo ""
      echo "* binary to fix rpath = $exe"
      cmd="$CONTRIB_DIR/bin/chrpath -r $RPATH  $exe"
      echo "$cmd"
      $cmd
    fi
  done
}


######################################################################
#
# Takes a directory name to shared libs that need to have their
# rpath-s edited. Will check all files in directory and will run
# chrpath only on library files
# Assumes that chrpath build exists in a -k 'contrib' directory
#
# Args:
#  1. full path to directory with .so libs to be edited
#  2. location for rpath to be changed to
#
######################################################################

fixRpathForSharedLibs() {

  SHAREDLIB_PATH=$1
  RPATH=$2

  echo ""
  echo "fixRpathForSharedLibs: SHAREDLIB_PATH=$SHAREDLIB_PATH"
  echo "fixRpathForSharedLibs:          RPATH=$RPATH"

  # Find all .so libraries in a lib directory and run chrpath
  # This skips running chrpath on symbolic links
  local SHAREDLIBS=`ls -1 $SHAREDLIB_PATH/*.so*`

  for lib in $SHAREDLIBS; do
    if ! test -L $lib; then
      echo ""
      echo "*.so lib to fix rpath = $lib"
      cmd="$CONTRIB_DIR/bin/chrpath -r $RPATH  $lib"
      echo "$cmd"
      $cmd
    fi
  done
}
