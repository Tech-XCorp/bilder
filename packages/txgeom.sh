#!/bin/bash
#
# Version and build information for txgeom
#
# $Id: txgeom.sh 6265 2012-06-23 23:51:58Z cary $
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
# Other values
#
######################################################################

TXGEOM_BUILDS=${TXGEOM_BUILDS:-"ser,par"}
addBenBuild txgeom
TXGEOM_DEPS=txbase,cmake

######################################################################
#
# Launch txgeom builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildTxgeom() {

# Revert if needed and get version
  getVersion txgeom

# Add args for AIX
  case `uname` in
    AIX)
      TXGEOM_MAKE_ARGS=${TXGEOM_MAKE_ARGS:-"TAR=gtar"}
      ;;
  esac

# Build
  if bilderPreconfig -c txgeom; then
    if bilderConfig -c txgeom ser "$CMAKE_NODEFLIB_FLAGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXGEOM_SER_OTHER_ARGS" ; then
      bilderBuild txgeom ser "$TXGEOM_MAKE_ARGS"
    fi
    if bilderConfig -c txgeom par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_NODEFLIB_FLAGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXGEOM_PAR_OTHER_ARGS"; then
      bilderBuild txgeom par "$TXGEOM_MAKE_ARGS"
    fi
  fi

}

######################################################################
#
# Test txgeom
#
######################################################################

testTxgeom() {
  techo "Not testing txgeom."
}

######################################################################
#
# Install txgeom
#
######################################################################

installTxgeom() {
  bilderInstall txgeom ser txgeom
  bilderInstall txgeom par txgeom-par
  # techo "WARNING: Quitting at end of txgeom.sh."; cleanup
}

