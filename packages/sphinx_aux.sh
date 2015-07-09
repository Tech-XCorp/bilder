#!/bin/bash
#
# Trigger vars and find information
#
# Repackage by, e.g.,
#  tar xjf birkenfeld-sphinx-869bf6d21292.tar.bz2
#  mv birkenfeld-sphinx-869bf6d21292.tar.bz2 sphinx-1.3a0
#  env COPYFILE_DISABLE=true tar cjf sphinx-1.3a0.tar.bz2 sphinx-1.3a0
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

setSphinxTriggerVars() {
  SPHINX_BLDRVERSION_STD=${SPHINX_BLDRVERSION_STD="1.2.2"}
  SPHINX_BLDRVERSION_EXP=${SPHINX_BLDRVERSION_EXP="1.3.1"}
  SPHINX_BUILDS=${SPHINX_BUILDS:-"pycsh"}
  SPHINX_DEPS=docutils,Pygments,Imaging,setuptools,MathJax,Python
}
setSphinxTriggerVars

######################################################################
#
# Find sphinx
#
######################################################################

findSphinx() {
  case `uname` in
    CYGWIN*) addtopathvar PATH $CONTRIB_DIR/Scripts;;
          *) addtopathvar PATH $CONTRIB_DIR/bin;;
  esac
}

