#!/bin/bash
#
# Trigger vars and find information
#
# $Id: g4examples_aux.sh 1248 2014-06-24 21:40:50Z cary $
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

setG4examplesTriggerVars() {
  if test -z "$G4EXAMPLES_BUILDS"; then
    G4EXAMPLES_BUILDS=`echo $DOCS_BUILDS | sed 's/develdocs//g'`
  fi
  trimvar G4EXAMPLES_BUILDS ','
  G4EXAMPLES_DEPS=sphinx_numfig,sphinx,MathJax,cmake
}
setG4examplesTriggerVars

######################################################################
#
# Find txutils
#
######################################################################

findG4examples() {
  :
}

