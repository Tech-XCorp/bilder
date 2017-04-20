#!/bin/sh
######################################################################
#
# @file    pkgutils.sh
#
# @brief   Common methods to fix up rpath in binaries/shared-libs
#          and create a tarball as an installer
#
# @version $Rev: 3578 $ $Date: 2017-04-13 08:20:53 -0600 (Thu, 13 Apr 2017) $
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Notes:
#  1. Each method checks for chrpath at call time, because this
#     will fail on a new build
#
######################################################################



######################################################################
#
# Takes a package directory in the bilder install directory area
# and tar-s and gzip-s this directory. Cleans out old tar files
# and prints out status info
#
# Args:
#  1. prefix name of tar file (creates a ${1}Install.tar.gz file)
#  2. name of package directory in the BLDR_INSTALL_DIR location
#
######################################################################

tarBldrInstallPkg() {

  local PKG_NAME=$1
  local PKG_DIR=$2
  local FULL_TAR_NAME=$BLDR_INSTALL_DIR/${PKG_NAME}-$FQMAILHOST.tar

  # Clean out old tar files
  rm -rf $FULL_TAR_NAME.gz $FULL_TAR_NAME

  # Tar up the nwchem pkg directory created by fixDynNwchem
  echo ""
  echo "Creating an archive file for $PKG_NAME installer"
  echo ""

  cmd1="tar -cvf $FULL_TAR_NAME -C $BLDR_INSTALL_DIR $PKG_DIR"
  cmd2="gzip $FULL_TAR_NAME"
  echo "$cmd1 + $cmd2"
  $cmd1
  $cmd2
}


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

  # Check if chrpath program exists in contrib install location
  if ! test -e "$CONTRIB_DIR/bin/chrpath"; then
    echo "chrpath not found in contrib installation, check build"
    echo "rpathutils.sh exiting"
    exit
  fi

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

  # Check if chrpath program exists in contrib install location
  if ! test -e "$CONTRIB_DIR/bin/chrpath"; then
    echo "chrpath not found in contrib installation, check build"
    echo "rpathutils.sh exiting"
    exit
  fi

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
