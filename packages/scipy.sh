#!/bin/sh
######################################################################
#
# @file    scipy.sh
#
# @brief   Build information for scipy.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in scipy_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/scipy_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setScipyNonTriggerVars() {
  :
}
setScipyNonTriggerVars

#####################################################################
#
# Launch scipy builds.
#
######################################################################

setupScipyBuild() {

# Get native fortran compiler
  local SCIPY_FC="$PYC_FC"
  if [[ `uname` =~ CYGWIN ]]; then
    SCIPY_FC=`cygpath -u "$SCIPY_FC"`
  fi

# Set the blas and lapack names.
  local blslpcklibdir=
  local blslpckincdir=
  local blslpckdir=

# Accumulate linkflags for modules
  local linkflags="$PYCSH_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"
  SCIPY_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/scipy.files'"

# Get env and args
  case `uname`-"$CC" in

    CYGWIN*-*cl*)
# Determine basic args
      SCIPY_BUILD_ARGS="--compiler=$NUMPY_WIN_CC_TYPE install --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
      SCIPY_BUILD_ARGS="--fcompiler=gnu95 $SCIPY_BUILD_ARGS"
      local blslpcklibdir="$CONTRIB_LAPACK_SERMD_DIR"/lib
      blslpcklibdir=`cygpath -aw $blslpcklibdir | sed 's/\\\\/\\\\\\\\/g'`
      SCIPY_ENV="$DISTUTILS_ENV LAPACK='${blslpcklibdir}' BLAS='${blslpcklibdir}'"
      local fcbase=`basename "$PYC_FC"`
      if ! eval "$SCIPY_ENV" which $fcbase 1>/dev/null 2>&1; then
        techo "ERROR: [$FUNCNAME] Cannot build scipy, as $fcbase is not in PATH."
        return
      fi
      ;;

# For non-Cygwin builds, the build stage does not install.
    Darwin-*)
# -bundle found necessary for scipy, otherwise
# python -c "import scipy.interpolate"
# ...
# ImportError: dlopen(/contrib/lib/python2.7/site-packages/scipy/special/_ufuncs.so, 2): Symbol not found: _main
# -bundle prevents undefined symbol, _main
      linkflags="$linkflags -bundle -Wall"
# See http://trac.macports.org/changeset/118776 and
# http://trac.macports.org/browser/trunk/dports/python/py-scipy/Portfile
      local fflags="-m32 -m64 -fno-second-underscore"
      if [[ $PYC_CC =~ clang ]]; then
        fflags="$fflags -ff2c"
      fi
# Looks like a little belt and suspenders on the options and the env
      SCIPY_ENV="$DISTUTILS_ENV2 CFLAGS='-arch i386 -arch x86_64' FFLAGS='$fflags'"
      SCIPY_CONFIG_ARGS="config_fc --fcompiler gnu95 --f77exec='$PYC_FC' --f77flags='$fflags' --f90exec='$PYC_FC' --f90flags='$fflags' config --cc='$PYC_CC'"
      SCIPY_BUILD_ARGS="install --prefix='$NATIVE_CONTRIB_DIR'"
      ;;

    Linux-*)
      SCIPY_ENV="$DISTUTILS_ENV2 $SCIPY_GFORTRAN"
# This is the only way to specify different libraries:
# https://www.scipy.org/scipylib/building/linux.html
      linkflags="$linkflags -Wl,-rpath,${PYTHON_LIBDIR}"
      if test -d ${LAPACK_PYCSH_DIR}/lib64; then
        blslpcklibdir=${LAPACK_PYCSH_DIR}/lib64
      elif test -d ${LAPACK_PYCSH_DIR}/lib; then
        blslpcklibdir=${LAPACK_PYCSH_DIR}/lib
      fi
      if test -n "$blslpcklibdir"; then
        SCIPY_ENV="$DISTUTILS_ENV2 LAPACK='$blslpcklibdir' BLAS='$blslpcklibdir'"
      fi
      ;;

    *)
      techo "WARNING: [$FUNCNAME] uname `uname` not recognized.  Not building."
      return
      ;;

  esac
  trimvar linkflags ' '
  if test -n "$linkflags"; then
    SCIPY_ENV="$SCIPY_ENV LDFLAGS='$linkflags'"
  fi

}

buildScipy() {

# Determine whether to unpack, whether there is a build
  if ! bilderUnpack scipy; then
    return
  fi
  local cmd=
  if [[ `uname` =~ CYGWIN ]]; then
    cmd="rmall ${PYTHON_SITEPKGSDIR}/scipy*"
    techo "$cmd"
    $cmd
  fi

# On hopper, cannot include LD_LIBRARY_PATH
  if $BLDR_BUILD_NUMPY && $HAVE_SER_FORTRAN; then
    setupScipyBuild
    bilderDuBuild scipy "$SCIPY_BUILD_ARGS" "$SCIPY_ENV" "$SCIPY_CONFIG_ARGS"
  else
# Building at this point as only one package, and that checked by bilderUnpack
    cd $BUILD_DIR/scipy-${SCIPY_BLDRVERSION}
    cmd="python -m pip install --upgrade --target=$MIXED_PYTHON_SITEPKGSDIR -i https://pypi.binstar.org/carlkl/simple scipy"
    techo "$cmd"
    if $cmd; then
      ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR scipy,pycsh
      techo "scipy-pycsh installed."
      installations="$installations scipy-pycsh"
    else
      techo "scipy-pycsh failed to install."
      installFailures="$installFailures scipy-pycsh"
    fi
  fi

}

######################################################################
#
# Test scipy
#
######################################################################

testScipy() {
  techo "Not testing scipy."
}

######################################################################
#
# Install scipy
#
######################################################################

installScipy() {
  case `uname`-$PYC_CC in
    CYGWIN*) bilderDuInstall -n scipy "-" "$SCIPY_ENV";;
    *) bilderDuInstall -r scipy scipy "$SCIPY_INSTALL_ARGS" "$SCIPY_ENV";;
  esac
}

