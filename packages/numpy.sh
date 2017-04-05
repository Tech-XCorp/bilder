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
# There is a connection between the numpy and scipy builds,
# with scipy using part of the numpy distutils.
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

setupNumpyBuild() {

# Set the blas and lapack names.
  local blslpcklibdir=
  local blslpckincdir=
  local lapacknames=
  local blasnames=
  local blslpckdir=

  case `uname`-"$CC" in

    CYGWIN*-*cl | CYGWIN*-*cl.exe)
      lapacknames=lapack
# Add /NODEFAULTLIB:LIBCMT to get this on the link line.
# Worked with 1.6.x, but may not be working with 1.8.X
# LDFLAGS did not work.  Nor did -Xlinker.
      if $NUMPY_WIN_USE_FORTRAN && test -n "$CONTRIB_LAPACK_SERMD_DIR"; then
        blslpckdir="$CONTRIB_LAPACK_SERMD_DIR"
        blasnames=blas
      else
        blslpckdir="$CLAPACK_CMAKE_SERMD_DIR"
        blasnames=blas,f2c
      fi
      blslpcklibdir=`cygpath -aw $blslpckdir | sed 's/\\\\/\\\\\\\\/g'`\\\\lib
      blslpckincdir=`cygpath -aw $blslpckdir | sed 's/\\\\/\\\\\\\\/g'`\\\\include
      blslpckdir=`cygpath -aw $blslpckdir | sed 's/\\\\/\\\\\\\\/g'`\\\\
      local flibdir=
      if test -n "$PYC_FC"; then
        flibdir=`$PYC_FC -print-file-name=libgfortran.a`
        flibdir=`dirname $flibdir`
        flibdir=`cygpath -aw "$flibdir" | sed 's/\\\\/\\\\\\\\/g'`
      fi
      ;;

    Linux-*)
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
      ;;

  esac

# Create site.cfg
# Not needed on Linux
# If lapack libs are defined, even clapack, numpy will search for
# a fortran and use it.  If it is going to find cygwin's fortran,
# prevent this by not defining the blas and lapack libraries.
  local sep=','
  if [[ `uname` =~ CYGWIN ]]; then
    sep=';'
  if test -n "$lapacknames" && $HAVE_SER_FORTRAN; then
# In spite of documentation, need semicolon, not comma.
    if test -f site.cfg.example; then
# On Crays this is ignored, and one needs to set LAPACK and BLAS
      techo "Creating site.cfg."
# Format changed with 1.8.0.  All lines begin with '#', and lapack_libs
# and blas_libs no longer specified.  They come from the section by default?
      sed -e "s/^#\[ALL/\[ALL/" -e "s/^#\[DEFAULT/\[DEFAULT/" -e "s?^#include_dirs = /usr/local/include?include_dirs = $blslpckincdir?" -e "s?^#library_dirs = /usr/local/lib?library_dirs = ${blslpcklibdir}${sep}$flibdir?" <site.cfg.example >numpy/distutils/site.cfg
# As of 1.11, the line beginning with #libraries disappeared.
      # sed -i.bak -e "s?^#libraries = lapack,blas?libraries = $lapacknames,$blasnames?" numpy/distutils/site.cfg
      sed -i.bak -e "/^include_dirs =/a\
libraries = $lapacknames,$blasnames" numpy/distutils/site.cfg
    else
      techo "WARNING: [$FUNCNAME] site.cfg.example not found in $PWD.  Will not create numpy/distutils/site.cfg."
    fi
  else
    techo "lapacknames or serial fortran not defined.  Will not create numpy/distutils/site.cfg."
  fi
  fi

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

# For Cygwin, build, install, and make packages all at once, with
# the latter if not building from a repo, as controlled by BDIST_WININST_ARG.
# For others, just build.
  case `uname`-"$CC" in
# For Cygwin builds, one has to specify the compiler during installation,
# but then one has to be building, otherwise specifying the compiler is
# an error.  So the only choice seems to be to install simultaneously
# with building.  Unfortunately, one cannot then intervene between the
# build and installation steps to remove old installations only if the
# build was successful.  Instead one must do any removal before starting
# the build and installation.
    CYGWIN*-*cl*)
      NUMPY_ARGS="--compiler=$NUMPY_WIN_CC_TYPE install --prefix='$NATIVE_CONTRIB_DIR' $NUMPY_INSTALL_ARGS $BDIST_WININST_ARG"
      NUMPY_ENV="$DISTUTILS_ENV"
      if $NUMPY_WIN_USE_FORTRAN && test -n "$PYC_FC"; then
        local fcbase=`basename "$PYC_FC"`
        if which $fcbase 1>/dev/null 2>&1; then
# NUMPY_ARGS="--fcompiler='$fcbase' $NUMPY_ARGS"
# The above specification fails with
# don't know how to compile Fortran code on platform 'nt' with 'x86_64-w64-mingw32-gfortran.exe' compiler. Supported compilers are: pathf95,intelvem,absoft,compaq,ibm,sun,lahey,pg,hpux,intele,gnu95,intelv,g95,intel,compaqv,mips,vast,nag,none,intelem,gnu,intelev)
          NUMPY_ARGS="--fcompiler=gnu95 $NUMPY_ARGS"
          NUMPY_ENV="$NUMPY_ENV F90='$fcbase'"
# Below does not help.  NumPy always uses 'gcc', so one must separate by path.
# local ccbase=`echo $fcbase | sed 's/fortran/cc/g'`
# NUMPY_ENV="$NUMPY_ENV CC='$ccbase'"
        else
          techo "WARNING: [$FUNCNAME] Not using fortran.  $fcbase not in path."
        fi
      else
        techo "WARNING: [$FUNCNAME] Not using fortran.  PYC_FC = $PYC_FC.  NUMPY_WIN_USE_FORTRAN = $NUMPY_WIN_USE_FORTRAN."
      fi
    ;;

# For non-Cygwin builds, the build stage does not install.
    Darwin-*)
# linkflags="$linkflags -bundle -Wall"
      linkflags="$linkflags -Wall"
      NUMPY_ENV="$DISTUTILS_ENV2 CFLAGS='-arch i386 -arch x86_64' FFLAGS='-m32 -m64'"
      ;;
    Linux-*)
      linkflags="$linkflags -Wl,-rpath,${PYTHON_LIBDIR}"
# Handle the case where PYC_FC may not be in path
      NUMPY_ARGS="--fcompiler=`basename ${PYC_FC}`"
      local fcpath=`dirname ${PYC_FC}`
      NUMPY_ENV="$DISTUTILS_ENV2 PATH=${PATH}:${fcpath}"
# With these environment variables set, rpath, library dirs, ... all found
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
  cd $BUILD_DIR/numpy-${NUMPY_BLDRVERSION} # Needed for setupNumpyBuild or pip
# Build/install
  if $BLDR_BUILD_NUMPY; then
    setupNumpyBuild
# For CYGWIN builds, remove any detritus lying around now.
    if [[ `uname` =~ CYGWIN ]]; then
      cmd="rmall ${PYTHON_SITEPKGSDIR}/numpy*"
      techo "$cmd"
      $cmd
    fi
    bilderDuBuild numpy "$NUMPY_ARGS" "$NUMPY_ENV"
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

