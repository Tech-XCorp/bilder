#!/bin/bash
#
# Version and build information for pandas
#
# $Id: pandas.sh 6364 2012-07-15 09:04:57Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PANDAS_BLDRVERSION=${PANDAS_BLDRVERSION:-"0.6.1"}

######################################################################
#
# Other values
#
######################################################################

PANDAS_BUILDS=${PANDAS_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
PANDAS_DEPS=Python,tables
PANDAS_UMASK=002

#####################################################################
#
# Launch pandas builds.
#
######################################################################

buildPandas() {

  if bilderUnpack pandas; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/pandas*"
    techo "$cmd"
    $cmd

# Build away
    PANDAS_ENV="$DISTUTILS_ENV"
    decho PANDAS_ENV = $PANDAS_ENV
    ZEROMQ_ARG="--rpath=$CONTRIB_DIR/zeromq --zmq=$CONTRIB_DIR/zeromq"
    bilderDuBuild -p pandas pandas "build_ext $ZEROMQ_ARG --inplace" "$PANDAS_ENV"
  fi

}

######################################################################
#
# Test pandas
#
######################################################################

testPandas() {
  techo "Not testing pandas."
}

######################################################################
#
# Install Pandas
#
######################################################################

installPandas() {
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p pandas pandas '-' "$PANDAS_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p pandas pandas "--install-purelib=$PYTHON_SITEPKGSDIR" "$PANDAS_ENV"
      ;;
  esac
}

