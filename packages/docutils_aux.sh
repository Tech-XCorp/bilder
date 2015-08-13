#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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

setDocutilsTriggerVars() {
  DOCUTILS_BLDRVERSION_STD=${DOCUTILS_BLDRVERSION_STD:-"0.8.1"}
  DOCUTILS_BLDRVERSION_EXP=${DOCUTILS_BLDRVERSION_EXP:-"0.12"}
  DOCUTILS_BUILDS=${DOCUTILS_BUILDS:-"pycsh"}
# Does docutils depend on roman?  Used to look for it.
  techo "NOTE: [$FUNCNAME] determine whether docutils depends on roman."
  DOCUTILS_DEPS=Python
}
setDocutilsTriggerVars

######################################################################
#
# Find docutils
#
######################################################################

findDocutils() {
  :
}

