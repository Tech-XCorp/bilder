#!/bin/bash
#
# Build information for numexpr
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in numexpr_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/numexpr_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNumexprNonTriggerVars() {
  :
}
setNumexprNonTriggerVars

######################################################################
#
# Launch numexpr builds.
#
######################################################################

buildNumexpr() {

  if ! bilderUnpack numexpr; then
    return
  fi

  cd $BUILD_DIR/numexpr-${NUMEXPR_BLDRVERSION}

# Patch incorrect syntax
  local ptchfile=numexpr/missing_posix_functions.inc
  cmd="sed -i.bak -e 's/inline static/inline/g' $ptchfile"
  techo "$cmd"
  sed -i.bak -e 's/inline static/inline/g' $ptchfile

# Accumulate link flags for modules.
# Darwin defines PYC_MODFLAGS = "-undefined dynamic_lookup",
#   but not PYC_LDSHARED
# Linux defines PYC_MODFLAGS = "-shared", but not PYC_LDSHARED
  local linkflags="$PYCSH_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"

# For Cygwin: build, install, and make packages all at once.
  NUMEXPR_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/numexpr.filelist'"
# For others, just build.
  case `uname`-"$CC" in
# For Cygwin builds, one has to specify the compiler during installation,
# but then one has to be building, otherwise specifying the compiler is
# an error.  So the only choice seems to be to install simultaneously
# with building.  Unfortunately, one cannot then intervene between the
# build and installation steps to remove old installations only if the
# build was successful.  One must do any removal then before starting
# the build and installation.
    CYGWIN*-cl | CYGWIN*-*/cl | CYGWIN_NT-6.1)
      NUMEXPR_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' $NUMEXPR_INSTALL_ARGS $BDIST_WININST_ARG"
      NUMEXPR_ENV="$DISTUTILS_ENV"
      ;;
    CYGWIN*-*mingw*)
      NUMEXPR_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $NUMEXPR_INSTALL_ARGS $BDIST_WININST_ARG"
      local mingwgcc=`which mingw32-gcc`
      local mingwdir=`dirname $mingwgcc`
      NUMEXPR_ENV="PATH=$mingwdir:'$PATH'"
      ;;
# For non-Cygwin builds, the build stage does not install.
    Darwin-*)
      # linkflags="$linkflags -bundle -Wall"
      linkflags="$linkflags -Wall"
      NUMEXPR_ENV="$DISTUTILS_ENV CFLAGS='-arch i386 -arch x86_64' FFLAGS='-m32 -m64'"
      ;;
    Linux-*)
	linkflags="$linkflags -Wl,-rpath,${PYTHON_LIBDIR} -Wl,-rpath,${LAPACK_PYCSH_DIR}"
      NUMEXPR_ARGS=""
      NUMEXPR_ENV="$DISTUTILS_ENV"
      ;;
    *)
      techo "WARNING: [numexpr.sh] uname `uname` not recognized.  Not building."
      return
      ;;
  esac
  trimvar linkflags ' '
  techo "linkflags = $linkflags."
  if test -n "$linkflags"; then
    NUMEXPR_ENV="$NUMEXPR_ENV LDFLAGS='$linkflags'"
  fi
  techo "NUMEXPR_ENV = $NUMEXPR_ENV."

# For CYGWIN builds, remove any detritus lying around now.
  if [[ `uname` =~ CYGWIN ]]; then
    cmd="rmall ${PYTHON_SITEPKGSDIR}/numexpr*"
    techo "$cmd"
    $cmd
  fi

# Build/install
  bilderDuBuild numexpr "$NUMEXPR_ARGS" "$NUMEXPR_ENV"

}

######################################################################
#
# Test numexpr
#
######################################################################

testNumexpr() {
  techo "Not testing numexpr."
}

######################################################################
#
# Install numexpr
#
######################################################################

installNumexpr() {
  case `uname` in
    CYGWIN*)
      bilderDuInstall -n numexpr "$NUMEXPR_ARGS" "$NUMEXPR_ENV"
      ;;
    *)
      bilderDuInstall -r numexpr numexpr "$NUMEXPR_INSTALL_ARGS" "$NUMEXPR_ENV"
      ;;
  esac
  # techo "WARNING: Quitting at end of numexpr.sh."; exit
}

