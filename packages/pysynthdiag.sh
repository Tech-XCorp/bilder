#!/bin/sh
######################################################################
#
# @file    pysynthdiag.sh
#
# @brief   Version and build information for pysynthDiag.
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

PYSYNTHDIAG_BLDRVERSION=${PYSYNTHDIAG_BLDRVERSION:-"0.9.8"}

######################################################################
#
# Other values
#
######################################################################

PYSYNTHDIAG_BUILDS=${PYSYNTHDIAG_BUILDS:-"pycsh"}
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
#      if bilderConfig -c pysynthdiag pycsh; then
#        bilderBuild pysynthdiag pycsh
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
#      bilderInstall pysynthdiag pycsh
#      ;;
#    *)
#      bilderInstall -f pysynthdiag pycsh
#     techo " +++++++++++$PYTHON_SITEPKGSDIR =  ${PYTHON_SITEPKGSDIR}"
#      ;;
#  esac
}

 #"--install-purelib=$PYTHON_SITEPKGSDIR" "$PYSYNTHDIAG_ENV"

