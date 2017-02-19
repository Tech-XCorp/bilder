#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
# Get tarball from zip by
# unzip MathJax-2.5-latest.zip
# mv MathJax-2.5-latest MathJax-2.5
# env COPYFILE_DISABLE=true tar cjf MathJax-2.5.tar.bz2 MathJax-2.5
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

setMathjaxTriggerVars() {
  MATHJAX_BLDRVERSION_STD=${MATHJAX_BLDRVERSION_STD:-"2.7.0"}
  MATHJAX_BLDRVERSION_EXP=${MATHJAX_BLDRVERSION_EXP:-"2.7.0"}
  MATHJAX_BUILDS=${MATHJAX_BUILDS:-"full,lite"}
  MATHJAX_DEPS=Python
}
setMathjaxTriggerVars

######################################################################
#
# Find mathjaxs
#
######################################################################

findMathjax() {
  :
}

