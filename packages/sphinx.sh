#!/bin/bash
#
# Version and build information for sphinx
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
# Version
#
######################################################################

SPHINX_BLDRVERSION_STD=${SPHINX_BLDRVERSION_STD="1.3a0"}
SPHINX_BLDRVERSION_EXP=${SPHINX_BLDRVERSION_EXP="1.2.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setSphinxGlobalVars() {
  SPHINX_BUILDS=${SPHINX_BUILDS:-"cc4py"}
  SPHINX_DEPS=docutils,Pygments,Imaging,setuptools,MathJax,Python
  SPHINX_UMASK=002
  case `uname` in
    CYGWIN*) addtopathvar PATH $CONTRIB_DIR/Scripts;;
          *) addtopathvar PATH $CONTRIB_DIR/bin;;
  esac
}
setSphinxGlobalVars

#####################################################################
#
# Launch sphinx builds.
#
######################################################################

buildSphinx() {

# Get sphinx, check for build need
  if ! bilderUnpack sphinx; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/Sphinx*"
  techo "$cmd"
# Do second time for cygwin
  if ! $cmd; then
    techo "$cmd"
    $cmd
  fi

# Build away
  SPHINX_ENV="$DISTUTILS_ENV"
  techo -2 SPHINX_ENV = $SPHINX_ENV
  bilderDuBuild sphinx '-' "$SPHINX_ENV"

}

######################################################################
#
# Test sphinx
#
######################################################################

testSphinx() {
  techo "Not testing sphinx."
}

######################################################################
#
# Install sphinx
#
######################################################################

installSphinx() {
  if bilderDuInstall sphinx "" "$SPHINX_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/easy-install.pth
    setOpenPerms $PYTHON_SITEPKGSDIR/Sphinx-*.egg
    setOpenPerms $PYTHON_SITEPKGSDIR/Jinja2-*.egg
  fi
}

