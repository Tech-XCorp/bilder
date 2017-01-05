#!/bin/bash
#
# Build information for scipy
#
# $Id$
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

# Accumulate linkflags for modules
  local linkflags="$PYCSH_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"

# Determine whether to use atlas.  SciPy must go with NumPy in all things.
  if $NUMPY_USE_ATLAS; then
    techo "Building scipy with ATLAS."
    techo "ATLAS_PYCSH_DIR = $ATLAS_PYCSH_DIR,  ATLAS_PYCSH_LIBDIR = $ATLAS_PYCSH_LIBDIR."
  fi
  SCIPY_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/scipy.files'"

# Get env and args
  case `uname`-"$CC" in

    CYGWIN*-*cl*)
      if ! $NUMPY_WIN_USE_FORTRAN; then
        techo "WARNING: [$FUNCNAME] Numpy was built without fortran.  Scipy cannot be built."
        return 1
      fi
# Determine basic args
      SCIPY_BUILD_ARGS="--compiler=$NUMPY_WIN_CC_TYPE install --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
      SCIPY_BUILD_ARGS="--fcompiler=gnu95 $SCIPY_BUILD_ARGS"
      if $NUMPY_USE_ATLAS; then
        SCIPY_ENV="$DISTUTILS_ENV ATLAS='$ATLAS_PYCSH_LIBDIR'"
      else
        local blslpcklibdir="$CONTRIB_LAPACK_SERMD_DIR"/lib
        blslpcklibdir=`cygpath -aw $blslpcklibdir | sed 's/\\\\/\\\\\\\\/g'`
        SCIPY_ENV="$DISTUTILS_ENV LAPACK='${blslpcklibdir}' BLAS='${blslpcklibdir}'"
      fi
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
      local LAPACK_LIB_DIR=${CONTRIB_DIR}/lapack-${LAPACK_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
      SCIPY_ENV="$DISTUTILS_ENV $SCIPY_GFORTRAN BLAS='$LAPACK_LIB_DIR' LAPACK='$LAPACK_LIB_DIR'"
      linkflags="$linkflags -Wl,-rpath,${PYTHON_LIBDIR}"
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
# Scipy requires fortran
  if ! $HAVE_SER_FORTRAN; then
    techo "WARNING: [$FUNCNAME] No fortran compiler.  Scipy cannot be built."
    return 1
  fi

if false; then
# For CYGWIN builds, remove any detritus lying around now.
  if [[ `uname` =~ CYGWIN ]]; then
    cmd="rmall ${PYTHON_SITEPKGSDIR}/scipy*"
    techo "$cmd"
    $cmd
  fi
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

if false; then
# On CYGWIN, build may have to be run twice
  if [[ `uname` =~ CYGWIN ]] && ! waitAction -n scipy-pycsh; then
    cd $BUILD_DIR/scipy-$SCIPY_BLDRVERSION
    local buildscript=`ls *-build.sh`
    if test -z "$buildscript"; then
      techo "WARNING: [$FUNCNAME] SciPy build script not found."
    else
      techo "Re-executing $buildscript."
      local build_txt=`basename $buildscript .sh`.txt
      ./$buildscript >>$build_txt 2>&1 &
      pid=$!
      addActionToLists scipy-pycsh $pid
    fi
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
  # techo "WARNING: Quitting at the end of scipy.sh."; cleanup
}

