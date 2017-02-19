#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setSnowballstemmerTriggerVars() {
  SNOWBALLSTEMMER_BLDRVERSION_STD=${SNOWBALLSTEMMER_BLDRVERSION_STD:-"1.2.1"}
  SNOWBALLSTEMMER_BLDRVERSION_EXP=${SNOWBALLSTEMMER_BLDRVERSION_EXP:-"1.2.1"}
  SNOWBALLSTEMMER_BUILDS=${SNOWBALLSTEMMER_BUILDS:-"pycsh"}
  SNOWBALLSTEMMER_DEPS=Python
}
setSnowballstemmerTriggerVars

######################################################################
#
# Find snowballstemmer
#
######################################################################

findSnowballstemmer() {
  :
}

