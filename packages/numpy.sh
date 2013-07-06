#!/bin/bash
#
# Version and build information for numpy
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

NUMPY_BLDRVERSION_STD=1.6.2
NUMPY_BLDRVERSION_EXP=1.7.1
computeVersion numpy

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

NUMPY_BUILDS=${NUMPY_BUILDS:-"cc4py"}
NUMPY_DEPS=Python,atlas,clapack_cmake,lapack

######################################################################
#
# Launch builds.
#
######################################################################

buildNumpy() {

  if bilderUnpack numpy; then

    cd $BUILD_DIR/numpy-${NUMPY_BLDRVERSION}

# For windows-ser, since F90 = C:\MinGW\bin\mingw32-gfortran.exe,
# cp /MinGW/lib/libmingw32.a build/temp.win32-2.6/Release/mingw32.lib
# cp /MinGW/lib/libmingwex.a build/temp.win32-2.6/Release/mingwex.lib

# Set the blas and lapack names for site.cfg.  Getting this done
# here also fixes it for scipy, which relies on the distutils that
# gets installed with numpy.
    local lapacknames
    local blasnames
    local blaslapackdir
    case `uname`-"$CC" in
      CYGWIN*-*cl*)
        lapacknames="lapack"
# Add /NODEFAULTLIB:LIBCMT to get this on the link line.
# LDFLAGS did not work.  Nor did -Xlinker.
        blasnames="blas, f2c, /NODEFAULTLIB:LIBCMT"
        blaslapackdir="$CLAPACK_CMAKE_SER_DIR"
        blaslapackdir=`cygpath -aw $blaslapackdir | sed 's/\\\\/\\\\\\\\/g'`\\\\
        ;;
      CYGWIN*-*mingw*)
        lapacknames=`echo $LAPACK_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
        blasnames=`echo $BLAS_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
        blaslapackdir="$LAPACK_CC4PY_DIR"/
        blaslapackdir=`cygpath -aw $blaslapackdir | sed 's/\\\\/\\\\\\\\/g'`\\\\
        ;;
      Linux-*)
        lapacknames=`echo $LAPACK_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
        blasnames=`echo $BLAS_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
        blaslapackdir="$LAPACK_CC4PY_DIR"/
        ;;
# Assuming blas and lapack are in the same directory.
    esac

# Create site.cfg
    if test -n "$lapacknames"; then
      sed -e "s?^include_dirs = /usr/local/?include_dirs = $blaslapackdir?" -e "s?^library_dirs = /usr/local/?library_dirs = $blaslapackdir?" -e "s?^lapack_libs = lapack?lapack_libs = $lapacknames?" -e "s?^blas_libs = blas?blas_libs = $blasnames?" <site.cfg.example >numpy/distutils/site.cfg
    fi

# Accumulate link flags for modules, and make ATLAS modifications.
# Darwin defines PYC_MODFLAGS = "-undefined dynamic_lookup",
#   but not PYC_LDSHARED
# Linux defines PYC_MODFLAGS = "-shared", but not PYC_LDSHARED
    local linkflags="$CC4PY_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"

# For Cygwin, build, install, and make packages all at once.
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
        NUMPY_ARGS="--compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        NUMPY_ENV="$DISTUTILS_ENV"
# Not adding F90 to VS builds for now.
# Need to add F90='C:\MinGW\bin\mingw32-gfortran.exe' if using lapack-ser?
        ;;
      CYGWIN*-*w64-mingw*)
        NUMPY_ARGS="--compiler=mingw64 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        local mingwgcc=`which x86_64-w64-mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        NUMPY_ENV="PATH=$mingwdir:'$PATH'"
        ;;
      CYGWIN*-*mingw*)
        NUMPY_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        NUMPY_ENV="PATH=$mingwdir:'$PATH'"
        ;;
# For non-Cygwin builds, the build stage does not install.
      Darwin-*)
        # linkflags="$linkflags -bundle -Wall"
        linkflags="$linkflags -Wall"
        NUMPY_ENV="$DISTUTILS_ENV2 CFLAGS='-arch i386 -arch x86_64' FFLAGS='-m32 -m64'"
        ;;
      Linux-*)
	linkflags="$linkflags -Wl,-rpath,${PYTHON_LIBDIR} -Wl,-rpath,${LAPACK_CC4PY_DIR}/lib"
        NUMPY_ARGS="--fcompiler=gnu95"
        NUMPY_ENV="$DISTUTILS_ENV2"
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

# For CYGWIN builds, remove any detritus lying around now.
    if [[ `uname` =~ CYGWIN ]]; then
      cmd="rmall ${PYTHON_SITEPKGSDIR}/numpy*"
      techo "$cmd"
      $cmd
    fi

# Build/install
    bilderDuBuild numpy "$NUMPY_ARGS" "$NUMPY_ENV"

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
  case `uname` in
    CYGWIN*) bilderDuInstall -n numpy "-" "$NUMPY_ENV";;
    *) bilderDuInstall -r numpy numpy "-" "$NUMPY_ENV";;
  esac
  # techo "WARNING: Quitting at end of installNumpy."; cleanup
}

