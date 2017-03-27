#!/bin/sh
######################################################################
#
# @file    autotools.sh
#
# @brief   Source this file to build all of autotools
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# The libtool package file must be sourced before other packages
# are built, as it determines where they are installed.
# where the rest of autotools are installed
#
######################################################################

techo "WARNING: toolchains/autotools.sh is deprecated as of 2012-07-19."

source $BILDER_DIR/packages/m4.sh
source $BILDER_DIR/packages/autoconf.sh
source $BILDER_DIR/packages/automake.sh
source $BILDER_DIR/packages/libtool.sh

######################################################################
#
# Build all packages
#
######################################################################

# Add to path variable now so visible as build proceeds
addtopathvar PATH $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin
BUILD_AUTOTOOLS=${BUILD_AUTOTOOLS:-"true"}
if $BUILD_AUTOTOOLS; then

# Build all of these with gcc
  CC_SAV=$CC
  CC=gcc

# m4
  buildM4
  installM4

# autoconf
  buildAutoconf
  installAutoconf

# automake
  buildAutomake
  installAutomake

# libtool
  buildLibtool
  installLibtool

# Restore
  CC=$CC_SAV

fi

######################################################################
#
# Check the versions
#
######################################################################

warnAndExit() {
  techo "(NOTE: You can use the -a option to build the latest autotools.)"
  # exit 1
  sleep 10
}

for i in m4 autoconf automake libtool; do
  vervar=`genbashvar $i`_BLDRVERSION
  verval=`deref $vervar`
  echo $i needs to be at version $verval.
  if which $i 1>/dev/null 2>&1; then
    techo -2 "verval = $verval.  version = $version."
    version=`$i --version | head -1 | sed 's/^.* //'`
    echo $i is at version $version.
    if test $version != $verval; then
      techo "$i is not at correct version."
      techo "$i = `which $i`"
      warnAndExit
    fi
  else
    techo "$i not found in your path.  Problems may occur."
    warnAndExit
  fi
done

