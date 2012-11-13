#!/bin/bash
#
# Version and build information for scitools
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SCITOOLS_BLDRVERSION=${SCITOOLS_BLDRVERSION:-"0.8"}

######################################################################
#
# Other values
#
######################################################################

SCITOOLS_BUILDS=${SCITOOLS_BUILDS:-"cc4py"}
SCITOOLS_DEPS=docutils,Pygments,Imaging,setuptools,MathJax,Python
SCITOOLS_UMASK=002

######################################################################
#
# Add to paths.  Why both?  (JRC) removing second.
#
######################################################################

case `uname` in
  CYGWIN*)
    addtopathvar PATH $CONTRIB_DIR/Scripts
    ;;
  *)
    addtopathvar PATH $CONTRIB_DIR/bin
    ;;
esac
# addtopathvar PATH $BLDR_INSTALL_DIR/bin

#####################################################################
#
# Launch scitools builds.
#
######################################################################

buildScitools() {

  if bilderUnpack scitools; then
# Remove all old installations
    cmd="rm -rf ${PYCONTDIR}/scitools*"
    techo "$cmd"
    $cmd

# Build away
    SCITOOLS_ENV="$DISTUTILS_ENV $SCITOOLS_GFORTRAN"
    decho SCITOOLS_ENV = $SCITOOLS_ENV
    bilderDuBuild -p scitools scitools '-' "$SCITOOLS_ENV"
  fi

}

######################################################################
#
# Test scitools
#
######################################################################

testScitools() {
  techo "Not testing scitools."
}

######################################################################
#
# Install Scitools
#
######################################################################

installScitools() {
  case `uname` in
    # Windows does not have a lib versus lib64 issue
    CYGWIN*)
      bilderDuInstall scitools " " "$SCITOOLS_ENV"
      ;;
    *)
      bilderDuInstall scitools "--install-purelib=$PYCONTDIR" "$SCITOOLS_ENV"
      ;;
  esac
  # techo exit; exit
}

