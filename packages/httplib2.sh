#!/bin/bash
#
# Version and build information for httplib2
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

HTTPLIB2_BLDRVERSION=${HTTPLIB2_BLDRVERSION:-"0.7.4"}

######################################################################
#
# Builds and deps
#
######################################################################

HTTPLIB2_BUILDS=${HTTPLIB2_BUILDS:-"pycsh"}
HTTPLIB2_DEPS=Python

######################################################################
#
# Launch httplib2 builds.
#
######################################################################

buildHttplib2() {
# arch flags now fixed in bildvars.sh

  if bilderUnpack httplib2; then
# Remove all old installations
    local cmd="rmall ${PYTHON_SITEPKGSDIR}/httplib2*"
    techo "$cmd"
    $cmd
# httplib2 must be built without compiler option, then installed
    cd $BUILD_DIR/httplib2-${HTTPLIB2_BLDRVERSION}

# Patch incorrect syntax
    local ptchfile=httplib2/missing_posix_functions.inc
    cmd="sed -i.bak -e 's/inline static/inline/g' $ptchfile"
    techo "$cmd"
    sed -i.bak -e 's/inline static/inline/g' $ptchfile

    case `uname`-$CC in
      CYGWIN*-cl)
        HTTPLIB2_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        HTTPLIB2_ENV_USED="$DISTUTILS_ENV"
        ;;
      CYGWIN*-*mingw*)
# Have to install with build to get both prefix and compiler correct.
        HTTPLIB2_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        HTTPLIB2_ENV_USED="PATH=$mingwdir:'$PATH'"
        ;;
      *)
        #HTTPLIB2_ARGS="--fcompiler=gnu95"
        HTTPLIB2_ENV_USED="$DISTUTILS_ENV"
        ;;
    esac
    bilderDuBuild httplib2 "$HTTPLIB2_ARGS" "$HTTPLIB2_ENV_USED"

  fi

}

######################################################################
#
# Test httplib2
#
######################################################################

testHttplib2() {
  techo "Not testing httplib2."
}

######################################################################
#
# Install httplib2
#
######################################################################

installHttplib2() {
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n httplib2 "-" "$HTTPLIB2_ENV_USED"
      ;;
    *)
      bilderDuInstall httplib2 "-" "$HTTPLIB2_ENV_USED"
      ;;
  esac
  # techo "WARNING: Quitting at end of httplib2.sh."; exit
}

