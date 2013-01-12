#!/bin/bash
#
# Version and build information for boost
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

BOOST_BLDRVERSION_STD=1_50_0
BOOST_BLDRVERSION_EXP=1_50_0

######################################################################
#
# Other values
#
######################################################################

BOOST_BUILDS=${BOOST_BUILDS:-"ser,sersh"}
BOOST_DEPS=bzip2

######################################################################
#
# Launch boost builds.
#
######################################################################

buildBoost() {

# Look for needed packages
  case `uname` in
    Linux)
      if ! test -f /usr/include/bzlib.h; then
        techo "WARNING: May need to install bzip2-devel."
      fi
      ;;
  esac

# Process
  if bilderUnpack -i boost; then
    local BOOST_ALL_ADDL_ARGS="threading=multi variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi"
    case `uname` in
      CYGWIN*-WOW64*) BOOST_ALL_ADDL_ARGS="address-model=64 $BOOST_ALL_ADDL_ARGS";;
    esac
    BOOST_SER_ADDL_ARGS="link=static $BOOST_ALL_ADDL_ARGS"
    BOOST_SERSH_ADDL_ARGS="link=shared $BOOST_ALL_ADDL_ARGS --without-python"
    if bilderConfig -i boost ser; then
# In-place build, so done now
      cmd="sed -i.bak 's?// \(#define BOOST_ALL_NO_LIB\)?\1?' boost/config/user.hpp"
      techo "$cmd"
      eval "$cmd"
      bilderBuild -m ./b2 boost ser "$BOOST_SER_ADDL_ARGS $BOOST_SER_OTHER_ARGS stage"
    fi
    if bilderConfig -i boost sersh; then
# In-place build, so done now
      cmd="sed -i.bak 's?// \(#define BOOST_ALL_NO_LIB\)?\1?' boost/config/user.hpp"
      techo "$cmd"
      eval "$cmd"
      bilderBuild -m ./b2 boost sersh "$BOOST_SERSH_ADDL_ARGS $BOOST_SERSH_OTHER_ARGS stage"
    fi
  fi
}

######################################################################
#
# Test boost
#
######################################################################

testBoost() {
  techo "Not testing boost."
}

######################################################################
#
# Install boost
#
######################################################################

installBoost() {
  for bld in `echo $BOOST_BUILDS | tr ',' ' '`; do
    local boost_instdir=$CONTRIB_DIR/boost-$BOOST_BLDRVERSION-$bld
    local boost_mixed_instdir=
    case `uname` in
      CYGWIN*) boost_mixed_instdir=`cygpath -am $boost_instdir`;;
      *) boost_mixed_instdir=$boost_instdir;;
    esac
# For b2, installation directory must be added at install time,
# and it is relative to the C: root.
    local sfx=
    local instargs=
    case $bld in
      ser) instargs="$BOOST_SER_ADDL_ARGS";;
      sersh) sfx=-sersh; instargs="$BOOST_SERSH_ADDL_ARGS";;
    esac
    if bilderInstall -m ./b2 boost $bld boost${sfx} "$instargs --prefix=$boost_mixed_instdir"; then
      setOpenPerms $boost_instdir
      findBoost
    fi
  done
}

