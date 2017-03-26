#!/bin/sh
######################################################################
#
# @file    qhull.sh
#
# @brief   Version and build information for qhull.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Builds and deps
#
######################################################################

QHULL_BLDRVERSION=${QHULL_BLDRVERSION:-"2010.1"}
QHULL_BUILDS=${QHULL_BUILDS:-"ser"}
QHULL_DEPS=

addtopathvar PATH $BLDR_INSTALL_DIR/qhull/bin

######################################################################
#
# Launch qhull builds.
#
######################################################################

buildQhull() {

# Set cmake options
  local QHULL_SER_OTHER_ARGS="$QHULL_SER_CMAKE_OTHER_ARGS"

  # Fix ranlib on aix
  case `uname` in
    AIX)
      QHULL_MAKE_ARGS=${QHULL_MAKE_ARGS:-"RANLIB=:"}
      ;;
    Darwin)
      ;;
    Linux)
      ;;
  esac

  if bilderUnpack qhull; then
      if bilderConfig $USE_CMAKE_ARG qhull ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $QHULL_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
                bilderBuild qhull ser "$QHULL_MAKEJ_ARGS $QHULL_MAKE_ARGS"
      fi
  fi

}

######################################################################
#
# Install polyswift
#
######################################################################

installQhull() {
      echo "Qhull does not have an install target"
#  bilderInstall qhull ser

}
