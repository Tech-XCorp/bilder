#!/bin/bash
#
# Version and find information for boost
#
# $Id$
#
######################################################################

getBoostVersion() {
  BOOST_BLDRVERSION_STD=1_53_0
# 1_55_0 must be patched to build with NO_COMPRESSION:
#   https://svn.boost.org/trac/boost/ticket/9156
# Boost 1_55_0 does not build using gcc 4.1.2, nor does it seem to build
# on Lion and Snow Leopard.
# For now we're sticking with boost 1_53_0.
  BOOST_BLDRVERSION_EXP=1_53_0
  # BOOST_BLDRVERSION_EXP=1_55_0
}
getBoostVersion

#
# Find the BOOST includes
#
findBoost() {
  if test -L $CONTRIB_DIR/boost -o -d $CONTRIB_DIR/boost; then
    local boostincdir=`(cd $CONTRIB_DIR/boost/include; pwd -P)`
    if [[ `uname` =~ CYGWIN ]]; then
      boostincdir=`cygpath -am $boostincdir`
    fi
    BOOST_INCDIR_ARG="-DBoost_INCLUDE_DIR='$boostincdir'"
  fi
}

