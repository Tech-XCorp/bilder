#!/bin/sh
######################################################################
#
# @file    typing_aux.sh
#
# @brief   Trigger vars and find information for typing.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
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

setTypingTriggerVars() {
  TYPING_BLDRVERSION=${TYPING_BLDRVERSION:-"3.5.3.0"}
  TYPING_BUILDS=${TYPING_BUILDS:-"pycsh"}
  TYPING_DEPS=
}
setTypingTriggerVars

######################################################################
#
# Find xz
#
######################################################################

findTyping() {
  :
}

