#!/bin/sh
######################################################################
#
# @file    lp_solve.sh
#
# @brief   Version and build information for lp_solve.
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

LP_SOLVE_BLDRVERSION=${LP_SOLVE_BLDRVERSION:-"5.5.2.0"}

######################################################################
#
# Other values
#
######################################################################

LP_SOLVE_BUILDS=${LP_SOLVE_BUILDS:-"ser"}
LP_SOLVE_DEPS=

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/lp_solve/bin

######################################################################
#
# Launch lp_solve builds.
#
######################################################################

buildLp_solve() {
  if bilderUnpack lp_solve; then
    if bilderConfig lp_solve ser; then
      bilderBuild lp_solve ser
    fi
  fi
}

######################################################################
#
# Test lp_solve
#
######################################################################

testLp_solve() {
  techo "Not testing lp_solve."
}

######################################################################
#
# Install lp_solve
#
######################################################################

installLp_solve() {
  bilderInstall -r lp_solve ser lp_solve
}

