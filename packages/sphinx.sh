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

SPHINX_BLDRVERSION=${SPHINX_BLDRVERSION:-"1.1.3"}

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

  if bilderUnpack Sphinx; then
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
    bilderDuBuild -p sphinx Sphinx '-' "$SPHINX_ENV"
  fi

}

######################################################################
#
# Test sphinx
#
######################################################################

testSphinx() {
  techo "Not testing Sphinx."
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
      bilderDuInstall -p sphinx Sphinx " " "$SPHINX_ENV"
      res=$?
      ;;
    *)
      bilderDuInstall -p sphinx Sphinx "--install-purelib=$PYTHON_SITEPKGSDIR" "$SPHINX_ENV"
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

