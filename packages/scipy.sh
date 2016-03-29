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

buildScipy() {

# Determine whether to unpack, whether there is a build
  if ! bilderUnpack scipy; then
    return
  fi
# Scipy requires fortran
  if test -z "$PYC_FC"; then
    techo "WARNING: [$FUNCNAME] No fortran compiler.  Scipy cannot be built."
    return 1
  fi

  cd $BUILD_DIR/scipy-${SCIPY_BLDRVERSION}

# Older ppc require removal of arch from fortran flags
  case `uname -s` in
    Darwin)
      case `uname -r` in
        9.*)
          case `uname -p` in
            powerpc)
              svn up $BILDER_DIR/scipygfortran.sh
              SCIPY_GFORTRAN="F77=$BILDER_DIR/scipygfortran.sh"
              ;;
          esac
          ;;
        esac
      ;;
  esac

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
    CYGWIN*-*mingw*)
# Have to install with build to get both prefix and compiler correct.
      local mingwgcc=`which mingw32-gcc`
      local mingwdir=`dirname $mingwgcc`
      SCIPY_ENV="PATH=$mingwdir:'$PATH'"
      if test -n "$ATLAS_PYCSH_LIBDIR"; then
        SCIPY_ENV="$SCIPY_ENV ATLAS='$ATLAS_PYCSH_LIBDIR'"
      else
        SCIPY_ENV="$SCIPY_ENV LAPACK='C:\winsame\contrib-mingw\lapack-${LAPACK_BLDRVERSION}-ser\lib' BLAS='C:\winsame\contrib-mingw\lapack-${LAPACK_BLDRVERSION}-ser\lib'"
      fi
      SCIPY_BUILD_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' $BDIST_WININST_ARG"
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

# For CYGWIN builds, remove any detritus lying around now.
  if [[ `uname` =~ CYGWIN ]]; then
    cmd="rmall ${PYTHON_SITEPKGSDIR}/scipy*"
    techo "$cmd"
    $cmd
  fi

# On hopper, cannot include LD_LIBRARY_PATH
  bilderDuBuild scipy "$SCIPY_BUILD_ARGS" "$SCIPY_ENV" "$SCIPY_CONFIG_ARGS"

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
    CYGWIN* | Darwin-*) bilderDuInstall -n scipy "-" "$SCIPY_ENV";;
    *) bilderDuInstall -r scipy scipy "-" "$SCIPY_ENV";;
  esac
  # techo "WARNING: Quitting at the end of scipy.sh."; cleanup
}

