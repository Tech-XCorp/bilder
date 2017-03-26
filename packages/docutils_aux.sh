#!/bin/sh
######################################################################
#
# @file    docutils_aux.sh
#
# @brief   Trigger vars and find information for docutils.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
  DOCUTILS_BLDRVERSION_STD=${DOCUTILS_BLDRVERSION_STD:-"0.13.1"}
  DOCUTILS_BLDRVERSION_EXP=${DOCUTILS_BLDRVERSION_EXP:-"0.13.1"}
  DOCUTILS_BUILDS=${DOCUTILS_BUILDS:-"pycsh"}
# Does docutils depend on roman?  Used to look for it.
  # techo "NOTE: [$FUNCNAME] determine whether docutils depends on roman."
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

