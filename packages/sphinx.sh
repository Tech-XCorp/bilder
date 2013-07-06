#!/bin/bash
#
# Version and build information for sphinx
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SPHINX_BLDRVERSION_STD=1.1.3
SPHINX_BLDRVERSION_EXP=2.0.8

######################################################################
#
# Other values
#
######################################################################

SPHINX_BUILDS=${SPHINX_BUILDS:-"cc4py"}
SPHINX_DEPS=docutils,Pygments,Imaging,setuptools,MathJax,Python
SPHINX_UMASK=002

######################################################################
#
# Add to paths.
#
######################################################################

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

  if bilderUnpack sphinx; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/Sphinx*"
    techo "$cmd"
    if ! $cmd; then
      techo "$cmd"
      $cmd
    fi

# Build away
    SPHINX_ENV="$DISTUTILS_ENV $SPHINX_GFORTRAN"
    techo -2 SPHINX_ENV = $SPHINX_ENV
    bilderDuBuild sphinx '-' "$SPHINX_ENV"
  fi

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
    # Windows does not have a lib versus lib64 issue
    CYGWIN*)
      bilderDuInstall sphinx " " "$SPHINX_ENV"
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
  # techo "WARNING: Quitting at end of sphinx.sh."; exit
}

