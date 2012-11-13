#!/bin/bash
#
# Version and build information for pspline
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PSPLINE_BLDRVERSION=${PSPLINE_BLDRVERSION:-"1.1.1-r67+1118"}
# PSPLINE_BLDRVERSION=${PSPLINE_BLDRVERSION:-"2012-11-04"}


######################################################################
#
# Other values
#
######################################################################

PSPLINE_BUILDS=${PSPLINE_BUILDS:-"ser,par"}
addBenBuild pspline
PSPLINE_DEPS=fciowrappers

######################################################################
#
# Launch pspline builds.
#
######################################################################


# Build pspline using cmake
buildPsplineCM() {
# Check for svn version or package
  if test -d $PROJECT_DIR/pspline; then
    getVersion pspline
    bilderPreconfig -c pspline
    res=$?
  else
    bilderUnpack pspline
    res=$?
  fi
  if test $res = 0; then
    local PSPLINE_ENVVARS=
    case `uname`-$CC in
      CYGWIN*-mingw*)
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        PSPLINE_ENVVARS="PATH='$mingwdir:$PATH'"
        ;;
    esac
# Serial build
    if bilderConfig -c pspline ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_LINLIB_SER_ARGS $PSPLINE_SER_OTHER_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild pspline ser "" "$PSPLINE_ENVVARS"
    fi
# Parallel build
    if bilderConfig -c pspline par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_LINLIB_PAR_ARGS $PSPLINE_PAR_OTHER_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild pspline par "" "$PSPLINE_ENVVARS"
    fi
  fi
}

# For easy switching
buildPspline() {
  if test -d $PROJECT_DIR/pspline; then
    techo "WARNING: Building the repo, $PROJECT_DIR/pspline."
  fi
  if test $CONTRIB_DIR != $BLDR_INSTALL_DIR; then
    local insts=`\ls -d $BLDR_INSTALL_DIR/pspline* 2>/dev/null`
    if test -n "$insts"; then
      techo "WARNING: pspline is installed in $BLDR_INSTALL_DIR."
    fi
  fi
  # techo "For pspline, PREFER_CMAKE = $PREFER_CMAKE."
  buildPsplineCM
}


######################################################################
#
# Test pspline
#
######################################################################

testPspline() {
  techo "Not testing pspline."
}

######################################################################
#
# Install pspline
#
######################################################################

installPspline() {
  bilderInstall pspline ser pspline
  bilderInstall pspline par pspline-par
  bilderInstall pspline ben pspline-ben
  # techo exit; exit
}

