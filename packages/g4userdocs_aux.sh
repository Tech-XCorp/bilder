#!/bin/bash
#
# Trigger vars and find information
#
# $Id: g4userdocs_aux.sh 1250 2014-06-24 23:14:32Z cary $
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

setG4userdocsTriggerVars() {
  if test -z "$G4USERDOCS_BUILDS"; then
    G4USERDOCS_BUILDS=`echo $DOCS_BUILDS | sed 's/develdocs//g'`
  fi
  trimvar G4USERDOCS_BUILDS ','
  G4USERDOCS_DEPS=sphinx,MathJax,doxygen,cmake,g4examples
}
setG4userdocsTriggerVars

######################################################################
#
# Find Package 
#
######################################################################

findG4userdocs() {
  :
}

