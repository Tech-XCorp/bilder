#!/bin/sh
######################################################################
#
# @file    qmcpack.sh
#
# @brief   Version and build information for qmcpack.
#
# @version $Rev: 3599 $ $Date: 2017-04-07 16:13:04 -0600 (Fri, 07 Apr 2017) $
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables and versions set in qmcpack_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/qmcpack_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setQmcpackNonTriggerVars() {
  QMCPACK_UMASK=002
}
setQmcpackNonTriggerVars


######################################################################
#
# Launch qmcpack builds.
#
######################################################################

buildQmcpack() {

  if bilderUnpack qmcpack; then

    techo "==========================================================================================="
    techo " Will run bilder build step (if unpack-ed)"
    techo " TARBALL_NODEFLIB_FLAGS = $TARBALL_NODEFLIB_FLAGS"
    techo "==========================================================================================="

    # ================================================================
    # QMCPack needs specific environment variables set for packages
    # ================================================================

    local QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS"
    local QMCPACK_SER_OTHER_ARGS="$QMCPACK_SER_OTHER_ARGS"
    local QMCPACK_PAR_OTHER_ARGS="$QMCPACK_PAR_OTHER_ARGS"

    # Standard configure parameters
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS $TARBALL_NODEFLIB_FLAGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG"

    # Add boost
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS -DBOOST_ROOT=$CONTRIB_DIR/boost"

    # Add xml
    QMCPACK_OTHER_ARGS="$QMCPACK_OTHER_ARGS -DLIBXML2_HOME=$CONTRIB_DIR/libxml2"

    # Add fftw3
    QMCPACK_SER_OTHER_ARGS="$QMCPACK_SER_OTHER_ARGS -DFFTW_HOME=$CONTRIB_DIR/fftw3"
    QMCPACK_PAR_OTHER_ARGS="$QMCPACK_PAR_OTHER_ARGS -DFFTW_HOME=$CONTRIB_DIR/fftw3-par"

    # Add hdf5
    QMCPACK_SER_OTHER_ARGS="$QMCPACK_SER_OTHER_ARGS -DHDF5_ROOT=$CONTRIB_DIR/hdf5"
    QMCPACK_PAR_OTHER_ARGS="$QMCPACK_PAR_OTHER_ARGS -DHDF5_ROOT=$CONTRIB_DIR/hdf5-par"



    # ================================================================
    # Run bilder configure/build
    # ================================================================

    if bilderConfig -c qmcpack ser "$QMCPACK_SER_OTHER_ARGS $QMCPACK_OTHER_ARGS"; then
        bilderBuild qmcpack ser "$QMCPACK_MAKEJ_ARGS"
    fi

    if bilderConfig -c qmcpack par "-DENABLE_PARALLEL:BOOL=TRUE $QMCPACK_PAR_OTHER_ARGS $QMCPACK_OTHER_ARGS"; then
        bilderBuild qmcpack par "$QMCPACK_MAKEJ_ARGS"
    fi

  fi

}


######################################################################
#
# Install qmcpack
#
######################################################################

installQmcpack() {
  techo "Will run bilder install steps for QMCPack"
  bilderInstall qmcpack ser qmcpack
  bilderInstall qmcpack par qmcpack-par
}


######################################################################
#
# Test Qmcpack
#
######################################################################

testQmcpack() {
  techo "Not testing QMCPACK."
}
