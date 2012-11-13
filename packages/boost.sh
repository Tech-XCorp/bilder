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

BOOST_BUILDS=${BOOST_BUILDS:-"ser"}
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
    if bilderConfig -i boost ser; then
      bilderBuild -m ./b2 boost ser "-s NO_COMPRESSION=1 --without-mpi --layout=system threading=multi variant=release stage $BOOST_OTHER_ARGS"
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
  local boost_instdir=$CONTRIB_DIR/boost-$BOOST_BLDRVERSION-ser
  local boost_mixed_instdir=
  case `uname` in
    CYGWIN*) boost_mixed_instdir=`cygpath -am $boost_instdir`;;
    *) boost_mixed_instdir=$boost_instdir;;
  esac
# For b2, installation directory must be added at install time,
# and it is relative to the C: root.
  if bilderInstall -m ./b2 boost ser boost "--prefix=$boost_mixed_instdir -s NO_COMPRESSION=1 --without-mpi --layout=system threading=multi variant=release $BOOST_ADDL_ARGS $BOOST_OTHER_ARGS"; then
  #if bilderInstall -m ./b2 boost ser boost "--prefix=$boost_mixed_instdir"; then
    setOpenPerms $boost_instdir
    findBoost
  fi

  # techo "WARNING: Quitting at the end of boost.sh."; cleanup
}

