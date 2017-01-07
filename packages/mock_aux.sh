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

setMockTriggerVars() {
  MOCK_BLDRVERSION_STD=${MOCK_BLDRVERSION_STD:-"2.0.0"}
  MOCK_BLDRVERSION_EXP=${MOCK_BLDRVERSION_EXP:-"2.0.0"}
  MOCK_BUILDS=${MOCK_BUILDS:-"pycsh"}
  MOCK_DEPS=setuptools,Python
}
setMockTriggerVars

######################################################################
#
# Find mock
#
######################################################################

findMock() {
  :
}

