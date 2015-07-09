#!/bin/bash
#
# Build information for python pillow library
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pillow_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pillow_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPillowNonTriggerVars() {
  PILLOW_UMASK=002
}
setPillowNonTriggerVars

######################################################################
#
# Launch pillow builds.
#
######################################################################

buildPillow() {

# Unpack and determine whether to build
  if ! bilderUnpack Pillow; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/Pillow*"
  techo "$cmd"
  $cmd

# Different targets for windows
  case `uname`-$CC in
    CYGWIN*-cl)
      PILLOW_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
      PILLOW_ENV="$DISTUTILS_ENV"
      ;;
    CYGWIN*-mingw*)
# Have to install with build to get both prefix and compiler correct.
      PILLOW_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
      local mingwgcc=`which mingw32-gcc`
      local mingwdir=`dirname $mingwgcc`
      PILLOW_ENV="PATH=$mingwdir:'$PATH'"
      ;;
    Linux)
      # PILLOW_ARGS=
      local PILLOW_LIBPATH=$LD_LIBRARY_PATH
      if test -n "$PYC_LD_LIBRARY_PATH"; then
        PILLOW_LIBPATH=$PYC_LD_LIBRARY_PATH:$PILLOW_LIBPATH
      fi
      trimvar PILLOW_LIBPATH :
      if test -n "$PILLOW_LIBPATH"; then
        PILLOW_ENV="LDFLAGS='-Wl,-rpath,$PILLOW_LIBPATH -L$PILLOW_LIBPATH'"
      fi
      ;;
  esac

# Build
  bilderDuBuild -p PIL Pillow "$PILLOW_ARGS" "$PILLOW_ENV"

}

######################################################################
#
# Test pillow
#
######################################################################

testPillow() {
  techo "Not testing pillow."
}

######################################################################
#
# Install pillow
#
######################################################################

installPillow() {
  local res=1
  case `uname` in
    CYGWIN*)
# bilderDuInstall should not run python setup.py install, as this
# will rebuild with cl
      bilderDuInstall -n -p PIL Pillow "-" "$PILLOW_ENV"
      res=$?
      ;;
    *)
      bilderDuInstall -r "../../../bin/pilconvert.py  ../../../bin/pildriver.py  ../../../bin/pilfile.py  ../../../bin/pilfont.py  ../../../bin/pilprint.py" -p PIL Pillow "-" "$PILLOW_ENV"
      res=$?
      ;;
  esac
  return $res
}

