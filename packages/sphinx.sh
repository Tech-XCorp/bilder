#!/bin/bash
#
# Version and build information for sphinx
#
# Repackage by, e.g.,
#  tar xjf birkenfeld-sphinx-869bf6d21292.tar.bz2
#  mv birkenfeld-sphinx-869bf6d21292.tar.bz2 sphinx-1.3a0
#  tar cjf sphinx-1.3a0.tar.bz2 sphinx-1.3a0
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
SPHINX_BLDRVERSION_EXP=${SPHINX_BLDRVERSION_EXP="1.3a0"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

SPHINX_BUILDS=${SPHINX_BUILDS:-"cc4py"}
SPHINX_DEPS=docutils,Pygments,Imaging,setuptools,MathJax,Python
SPHINX_UMASK=002
case `uname` in
  CYGWIN*) addtopathvar PATH $CONTRIB_DIR/Scripts;;
        *) addtopathvar PATH $CONTRIB_DIR/bin;;
esac

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
  # SPHINX_ENV="$DISTUTILS_ENV $SPHINX_GFORTRAN"
# Sphinx needs fortran?
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
  case `uname` in
    CYGWIN*)
      bilderDuInstall sphinx "" "$SPHINX_ENV"
      res=$?
      ;;
    *)
      bilderDuInstall sphinx "--install-purelib=$PYTHON_SITEPKGSDIR" "$SPHINX_ENV"
      res=$?
      ;;
  esac
  if test $res = 0; then
    chmod a+r $PYTHON_SITEPKGSDIR/easy-install.pth
    setOpenPerms $PYTHON_SITEPKGSDIR/Sphinx-*.egg
    setOpenPerms $PYTHON_SITEPKGSDIR/Jinja2-*.egg
  fi
}

