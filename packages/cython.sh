#!/bin/bash
#
# Version and build information for cython
#
# $Id: cython.sh 6152 2012-05-29 13:51:32Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

CYTHON_BLDRVERSION=${CYTHON_BLDRVERSION:-"0.14.1"}

######################################################################
#
# Builds and deps
#
######################################################################

CYTHON_BUILDS=${CYTHON_BUILDS:-"cc4py"}
CYTHON_DEPS=Python
if $HAVE_ATLAS_PYC; then
  CYTHON_DEPS="$CYTHON_DEPS,atlas"
fi

######################################################################
#
# Launch cython builds.
#
######################################################################

buildCython() {
# arch flags now fixed in bildvars.sh

  if bilderUnpack Cython; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/Cython*"
    techo "$cmd"
    $cmd
    case `uname`-"$CC" in
      CYGWIN*-*cl*)
        CYTHON_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        CYTHON_ENV_USED="$DISTUTILS_ENV"
        ;;
      CYGWIN*-mingw*)
# Have to install with build to get both prefix and compiler correct.
        CYTHON_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        CYTHON_ENV_USED="PATH=$mingwdir:'$PATH'"
        ;;
      *)
        CYTHON_ENV_USED="$DISTUTILS_ENV"
        ;;
    esac
    bilderDuBuild Cython "$CYTHON_ARGS" "$CYTHON_ENV_USED"

  fi

}

######################################################################
#
# Test cython
#
######################################################################

testCython() {
  techo "Not testing cython."
}

######################################################################
#
# Install cython
#
######################################################################

installCython() {
  local res=1
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n Cython "-" "$CYTHON_ENV_USED"
      res=$?
      ;;
    *)
      bilderDuInstall Cython "-" "$CYTHON_ENV_USED"
      res=$?
      ;;
  esac
  if test $res = 0; then
    chmod a+r $PYTHON_SITEPKGSDIR/cython.py*
    setOpenPerms $PYTHON_SITEPKGSDIR/pyximport
  fi
  # techo "WARNING: Quitting at end of cython.sh."; cleanup
}

