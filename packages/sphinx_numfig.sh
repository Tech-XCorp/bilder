#!/bin/bash
#
# Build information for sphinx_numfig
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in sphinx_numfig_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/sphinx_numfig_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSphinx_numfigNonTriggerVars() {
  SPHINX_NUMFIG_UMASK=002
}
setSphinx_numfigNonTriggerVars

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

