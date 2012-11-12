#!/bin/bash
#
# Version and build information for sphinx_numfig
#
# $Id: sphinx_numfig.sh 6819 2012-10-08 16:38:22Z cary $
#
# This package was taken from bitbucket and put into sourceforge:
# https://svn.code.sf.net/p/numfig/code-0/trunk
#
# Create the tarball by running tarup.sh in the checked out repo.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SPHINX_NUMFIG_BLDRVERSION=${SPHINX_NUMFIG_BLDRVERSION:-"r13"}

######################################################################
#
# Other values
#
######################################################################

SPHINX_NUMFIG_BUILDS=${SPHINX_NUMFIG_BUILDS:-"cc4py"}
SPHINX_NUMFIG_DEPS=Sphinx
SPHINX_NUMFIG_UMASK=002

######################################################################
#
# Add to paths.
#
######################################################################

#####################################################################
#
# Launch sphinx_numfig builds.
#
######################################################################

buildSphinx_numfig() {

  if bilderUnpack sphinx_numfig; then
    bilderDuBuild sphinx_numfig
  fi

}

######################################################################
#
# Test sphinx_numfig
#
######################################################################

testSphinx_numfig() {
  techo "Not testing sphinx_numfig."
}

######################################################################
#
# Install sphinx_numfig
#
######################################################################

installSphinx_numfig() {
  bilderDuInstall sphinx_numfig
}

