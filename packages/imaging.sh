#!/bin/bash
#
# Build information for python imaging library
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in imaging_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/imaging_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setImagingNonTriggerVars() {
  IMAGING_UMASK=002
}
setImagingNonTriggerVars

######################################################################
#
# Launch imaging builds.
#
######################################################################

buildImaging() {

# Unpack and determine whether to build
  if ! bilderUnpack Imaging; then
    return
  fi

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

# Build
  bilderDuBuild -p PIL Imaging "$IMAGING_ARGS" "$IMAGING_ENV"

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
  return $res
}

