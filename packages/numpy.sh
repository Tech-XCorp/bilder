#!/bin/sh
######################################################################
#
# @file    numpy.sh
#
# @brief   Build information for numpy.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in numpy_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/numpy_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNumpyNonTriggerVars() {

# Without fortran, numpy builds, but scipy will not.
#
# Binary builds are at
#  https://bitbucket.org/carlkl/mingw-w64-for-python/downloads
#
# Binary installations are possible by installing pip
#  wget https://bootstrap.pypa.io/get-pip.py
#  python get-pip.py
#
# Then, e.g.,
#  python -m pip install --upgrade --target=$MIXED_PYTHON_SITEPKGSDIR -i https://pypi.binstar.org/carlkl/simple numpy
#  python -m pip install --upgrade --target=$MIXED_PYTHON_SITEPKGSDIR -i https://pypi.binstar.org/carlkl/simple scipy

# Below needed for scipy
  NUMPY_WIN_USE_FORTRAN=${NUMPY_WIN_USE_FORTRAN:-"false"}
# Set windows build vars if building on windows
  if $BLDR_BUILD_NUMPY && [[ `uname` =~ CYGWIN ]]; then
# So for now, the default is not to use fortran. Further it is forced off
# if there is no fortran compiler.
    if ! $HAVE_SER_FORTRAN; then
      NUMPY_WIN_USE_FORTRAN=false
    fi
# But if using fortran, must use mingw toolset
    if $NUMPY_WIN_USE_FORTRAN; then
      NUMPY_WIN_CC_TYPE=${NUMPY_WIN_CC_TYPE:-"mingw32"}
    else
      NUMPY_WIN_CC_TYPE=${NUMPY_WIN_CC_TYPE:-"msvc"}
    fi
  fi
  NUMPY_USE_ATLAS=${NUMPY_USE_ATLAS:-"false"}

}
setNumpyNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

#
# This sets the variables needed to build numpy, which for now
# is done on only Linux.  Windows builds are nearly impossible
# so for now we download them from carlkl's website.  MacOS
# builds are easy because one simply uses -framework Accelerate,
# which is found automatically.
#
# For Linux, it seems that now numpy and scipy builds work well
# only when BLAS and LAPACK environment variables are set.  site.cfg
# is then irrelevant.
#
setNumpyBuildVars() {

# Darwin defines PYC_MODFLAGS = "-undefined dynamic_lookup",
#   but not PYC_LDSHARED
# Linux defines PYC_MODFLAGS = "-shared", but not PYC_LDSHARED
  local linkflags="$PYCSH_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"

# With the new setuptools, package managers that want to manage the
# installations need the following arguments.  Otherwise, the installation
# is inside an egg, and the regular python path does not work.
# Doing this on CYGWIN and Darwin.
# Ivy build indicates need to do this on Linux
  if [[ $NUMPY_BLDRVERSION =~ 1.1[0-9] ]]; then
    NUMPY_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/numpy.files'"
  fi

# Set the blas and lapack names.
  local blslpcklibdir=
  local blslpckincdir=
  local lapacknames=
  local blasnames=
  local blslpckdir=

  case `uname`-"$CC" in

# For non-Cygwin builds, the build stage does not install.
    Darwin-*)
# linkflags="$linkflags -bundle -Wall"
      linkflags="$linkflags -Wall"
      NUMPY_ENV="$DISTUTILS_ENV2 CFLAGS='-arch i386 -arch x86_64' FFLAGS='-m32 -m64'"
      ;;

    Linux-*)
      linkflags="$linkflags -Wl,-rpath,${PYTHON_LIBDIR}"
# This is a configuration parameter, not a path to the compiler.
      NUMPY_BUILD_ARGS="--fcompiler=`basename ${PYC_FC}`"
      local fcpath=`dirname ${PYC_FC}`
      NUMPY_ENV="$DISTUTILS_ENV2 PATH=${PATH}:${fcpath}"
# Get basic lapack locations
      lapacknames=`echo $LAPACK_PYCSH_LIBRARY_NAMES | sed 's/ /, /g'`
      blasnames=`echo $BLAS_PYCSH_LIBRARY_NAMES | sed 's/ /, /g'`
      if test -d "$LAPACK_PYCSH_DIR"/lib64; then
        blslpcklibdir="$LAPACK_PYCSH_DIR"/lib64
      elif test -d "$LAPACK_PYCSH_DIR"/lib; then
        blslpcklibdir="$LAPACK_PYCSH_DIR"/lib
      fi
      blslpckincdir="$LAPACK_PYCSH_DIR"/include
# If the name is not lapack or blas, then BLAS and LAPACK should be the
# full path to the library.  Seen on crays.  Assumes a single name.
      if test $blasnames != blas; then
        BLASVAL="$blslpcklibdir"/lib${blasnames}.so
      else
        BLASVAL="$blslpcklibdir"
      fi
      if test $lapacknames != lapack; then
        LAPACKVAL="$blslpcklibdir"/lib${lapacknames}.so
      else
        LAPACKVAL="$blslpcklibdir"
      fi
      if test -n "$blslpcklibdir"; then
        NUMPY_ENV="$DISTUTILS_ENV2 LAPACK='$LAPACKVAL' BLAS='$BLASVAL'"
      fi
      ;;

    *)
      techo "WARNING: [numpy.sh] uname `uname` not recognized.  Not building."
      return
      ;;

  esac
  trimvar linkflags ' '
  techo "linkflags = $linkflags."
  if test -n "$linkflags"; then
# numpy does not recognize --lflags
    NUMPY_ENV="$NUMPY_ENV LDFLAGS='$linkflags'"
  fi
  techo "NUMPY_ENV = $NUMPY_ENV."

}

buildNumpy() {

# Unpack if needs building
  if ! bilderUnpack numpy; then
    return
  fi
# Scipy requires fortran
  if $BLDR_BUILD_NUMPY && ! $HAVE_SER_FORTRAN; then
    techo "WARNING: [$FUNCNAME] No fortran compiler.  Scipy cannot be built."
  fi
  local cmd=

# Move to build directory
  cd $BUILD_DIR/numpy-${NUMPY_BLDRVERSION} # Needed for setNumpyBuildVars or pip
# Build/install
  if $BLDR_BUILD_NUMPY; then
    setNumpyBuildVars
# For CYGWIN builds, remove any detritus lying around now.
    if [[ `uname` =~ CYGWIN ]]; then
      techo "WARNING: [FUNCNAME] Building on cygwin not now supported."
      cmd="rmall ${PYTHON_SITEPKGSDIR}/numpy*"
      techo "$cmd"
      $cmd
    fi
    bilderDuBuild numpy "$NUMPY_BUILD_ARGS" "$NUMPY_ENV"
  else
# We know we should build this, as there is only one build.
    cmd="python -m pip install --upgrade --target=$MIXED_PYTHON_SITEPKGSDIR -i https://pypi.binstar.org/carlkl/simple numpy"
    techo "$cmd"
    if $cmd; then
      ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR numpy,pycsh
      techo "numpy-pycsh installed."
      installations="$installations numpy-pycsh"
    else
      techo "numpy-pycsh failed to install."
      installFailures="$installFailures numpy-pycsh"
    fi
  fi

}

######################################################################
#
# Test
#
######################################################################

testNumpy() {
  techo "Not testing numpy."
}

######################################################################
#
# Install
#
######################################################################

installNumpy() {
  local res=
  case `uname` in
    CYGWIN*) bilderDuInstall -n numpy "-" "$NUMPY_ENV"; res=$?;;
    *) bilderDuInstall -r numpy numpy "$NUMPY_INSTALL_ARGS" "$NUMPY_ENV"; res=$?;;
  esac
  if test "$res" = 0; then
    chmod a+r $PYTHON_SITEPKGSDIR/easy-install.pth
    setOpenPerms $PYTHON_SITEPKGSDIR/numpy
  fi
}

