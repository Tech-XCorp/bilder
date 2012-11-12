#!/bin/bash
#
# Version and build information for python imaging library
#
# $Id: imaging.sh 6627 2012-09-07 03:03:19Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

IMAGING_BLDRVERSION=${IMAGING_BLDRVERSION:-"1.1.7"}

######################################################################
#
# Builds and deps
#
######################################################################

IMAGING_BUILDS=${IMAGING_BUILDS:-"cc4py"}
IMAGING_DEPS=Python
IMAGING_UMASK=002

######################################################################
#
# Launch imaging builds.
#
######################################################################

buildImaging() {
  if bilderUnpack Imaging; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/Imaging*"
    techo "$cmd"
    $cmd
# Different targets for windows
    case `uname`-$CC in
      CYGWIN*-cl)
        IMAGING_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        IMAGING_ENV="$DISTUTILS_ENV"
        ;;
      CYGWIN*-mingw*)
# Have to install with build to get both prefix and compiler correct.
        IMAGING_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        IMAGING_ENV="PATH=$mingwdir:'$PATH'"
        ;;
      Linux)
        # IMAGING_ARGS=
        local IMAGING_LIBPATH=$LD_LIBRARY_PATH
        if test -n "$PYC_LD_LIBRARY_PATH"; then
          IMAGING_LIBPATH=$PYC_LD_LIBRARY_PATH:$IMAGING_LIBPATH
        fi
        trimvar IMAGING_LIBPATH :
        if test -n "$IMAGING_LIBPATH"; then
          IMAGING_ENV="LDFLAGS='-Wl,-rpath,$IMAGING_LIBPATH -L$IMAGING_LIBPATH'"
        fi
        ;;
    esac
    bilderDuBuild -p PIL Imaging "$IMAGING_ARGS" "$IMAGING_ENV"
  fi
}

######################################################################
#
# Test imaging
#
######################################################################

testImaging() {
  techo "Not testing imaging."
}

######################################################################
#
# Install imaging
#
######################################################################

installImaging() {
  local res=1
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n -p PIL Imaging "-" "$IMAGING_ENV"
      res=$?
      ;;
    *)
      bilderDuInstall -r "../../../bin/pilconvert.py  ../../../bin/pildriver.py  ../../../bin/pilfile.py  ../../../bin/pilfont.py  ../../../bin/pilprint.py" -p PIL Imaging "-" "$IMAGING_ENV"
      res=$?
      ;;
  esac
  # techo "WARNING: Quitting at end of imaging.sh."; exit
  return $res
}

