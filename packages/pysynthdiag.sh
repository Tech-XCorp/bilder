#!/bin/bash
#
# Version and build information for pysynthDiag
#
# $Id: pysynthdiag.sh 6700 2012-09-19 19:08:00Z alexanda $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYSYNTHDIAG_BLDRVERSION=${PYSYNTHDIAG_BLDRVERSION:-"0.9.8"}

######################################################################
#
# Other values
#
######################################################################

PYSYNTHDIAG_BUILDS=${PYSYNTHDIAG_BUILDS:-"cc4py"}
PYSYNTHDIAG_DEPS=Python,numpy,scipy,tables,matplotlib,fusion_machine
PYSYNTHDIAG_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $PROJECT_DIR/bin
addtopathvar PYTHONPATH $PROJECT_DIR/pysynthdiag

#####################################################################
#
# Launch pysynthdiag builds.
#
######################################################################

buildPysynthdiag() {
  techo "Nothing to build"
## Configure and build serial and parallel
#  getVersion pysynthdiag
#  if bilderPreconfig pysynthdiag; then
#      if bilderConfig -c pysynthdiag cc4py; then
#        bilderBuild pysynthdiag cc4py
#      fi
#  fi
#
}

######################################################################
#
# Test PYSYNTHDIAG
#
######################################################################

testPysynthdiag() {
  techo "Not testing PySynthDiag."
}

######################################################################
#
# Install Pysynthdiag
#
######################################################################

installPysynthdiag() {
  techo "Nothing to install for now"
#  case `uname` in
#    # Windows does not have a lib versus lib64 issue
#    CYGWIN*)
#      bilderInstall pysynthdiag cc4py
#      ;;
#    *)
#      bilderInstall -f pysynthdiag cc4py
#     techo " +++++++++++$PYTHON_SITEPKGSDIR =  ${PYTHON_SITEPKGSDIR}"
#      ;;
#  esac
}

 #"--install-purelib=$PYTHON_SITEPKGSDIR" "$PYSYNTHDIAG_ENV"

