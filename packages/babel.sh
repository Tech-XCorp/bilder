#!/bin/bash
#
# Version and build information for babel
#
# $Id: babel.sh 5710 2012-04-07 13:30:29Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

BABEL_BLDRVERSION=${BABEL_BLDRVERSION:-"1.5.0-r6860"}

######################################################################
#
# Builds and deps
#
######################################################################

BABEL_BUILDS=${BABEL_BUILDS:-"shared,static"}
BABEL_DEPS=numpy,libtool
BABEL_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

if test `uname` = Linuux; then
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/babel-shared/lib
fi

######################################################################
#
# Launch babel builds.
# The shared babel build is done with the front-end serial compilers,
# and it will be used for code generation on the front-end nodes during
# compilation.  The static babel build is done with the back-end serial
# compilers.
#
# Some notes: http://trac.mcs.anl.gov/projects/cca/wiki/babelbgp
#
######################################################################

buildBabel() {

# Downgrade gcc on old darwin
  local BABEL_BUILD_ARGS=
  case `uname`-`uname -r` in
    Darwin-9.*)
      BABEL_BUILD_ARGS="CC=gcc-4.0"
      ;;
  esac

# Configure and build
  if bilderUnpack babel; then
# Use parallel compilers, since this is needed on the backend nodes
    if bilderConfig babel static "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR CPP='$PYC_CC -E' -C --enable-fortran90 --disable-java --disable-numeric --disable-shared --enable-pure-static-runtime --without-sidlx --disable-rmi --disable-iconv $BABEL_STATIC_OTHER_ARGS"; then
      bilderBuild babel static "$BABEL_BUILD_ARGS"
    fi
    if bilderConfig babel shared "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER CPP='$PYC_CC -E' -C --enable-fortran90 --disable-java --disable-numeric --without-sidlx --disable-rmi --disable-iconv $BABEL_SHARED_OTHER_ARGS"; then
      bilderBuild babel shared "$BABEL_BUILD_ARGS"
    fi
  fi

}

######################################################################
#
# Test babel
#
######################################################################

testBabel() {
  techo "Not testing babel."
}

######################################################################
#
# Install babel
#
######################################################################

installBabel() {
  bilderInstall babel shared babel-shared
  bilderInstall babel static babel-static
  # techo "WARNING: Quitting at end of babel.sh."; exit
}

