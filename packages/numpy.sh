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
NUMPY_BLDRVERSION_EXP=1.8.0
computeVersion numpy

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setNumpyGlobalVars() {
  NUMPY_BUILDS=${NUMPY_BUILDS:-"cc4py"}
# On Windows numpy can be built with any of
#   no linear algebra libraries
#   clapack_cmake (no fortran need)
#   netlib-lapack (fortran needed)
#   atlas-clp (atlas built with clp, no fortran needed)
#   atlas-ser (atlas built with netlib-lapack, fortran needed)
# These flags determine how numpy is built, with or without fortran, atlas.
# Without fortran, numpy builds, but scipy will not.
# There seems to be a connection between the numpy and scipy builds,
# with scipy using part of the numpy distutils.
# On the web, there are various claims:
# Python has to be 32bit: http://www.andrewsturges.com/2012/05/installing-numpy-for-python-3-in.html
# Intel 64bit builds exist at http://www.lfd.uci.edu/~gohlke/pythonlibs/
  # NUMPY_WIN_USE_FORTRAN=false
# With fortran but not atlas, numpy not yet building.
  NUMPY_WIN_USE_FORTRAN=$HAVE_SER_FORTRAN
  NUMPY_USE_ATLAS=false
  NUMPY_WIN_CC_TYPE=${NUMPY_WIN_CC_TYPE:-"msvc"}  # mingw32 is experimental
# Can now determine the deps
  NUMPY_DEPS=Python
  if $NUMPY_USE_ATLAS; then
    NUMPY_DEPS=$NUMPY_DEPS,atlas
  fi
  NUMPY_DEPS=$NUMPY_DEPS,clapack_cmake,lapack
}
setNumpyGlobalVars

######################################################################
#
# Launch builds.
#
######################################################################

buildNumpy() {

# Unpack if needs updating
  if ! bilderUnpack numpy; then
    return
  fi
  cd $BUILD_DIR/numpy-${NUMPY_BLDRVERSION}

# Set the blas and lapack names for site.cfg.  Getting this done
# here also fixes it for scipy, which relies on the distutils that
# gets installed with numpy.
  local lapacknames=
  local blasnames=
# Assuming blas and lapack are in the same directory.
  local blslpckdir=
  case `uname`-"$CC" in

    CYGWIN*-*cl*)
      lapacknames=lapack
# Add /NODEFAULTLIB:LIBCMT to get this on the link line.
# Worked with 1.6.x, but may not be working with 1.8.X
# LDFLAGS did not work.  Nor did -Xlinker.
      local blslpcklibdir=
      local blslpckincdir=
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
        flibdir=`$PYC_FC --print-file-name=libgfortran.a`
        flibdir=`dirname $flibdir`
        flibdir=`cygpath -aw "$flibdir" | sed 's/\\\\/\\\\\\\\/g'`
      fi
      local atlasdir=
      local atlaslibdir=
      local atlasincdir=
      if $NUMPY_USE_ATLAS; then
        if $NUMPY_WIN_USE_FORTRAN && test -n "$ATLAS_SER_DIR"; then
          atlasdir="$ATLAS_SER_DIR"
        elif test -n "$ATLAS_CLP_DIR"; then
          atlasdir="$ATLAS_CLP_DIR"
        fi
        atlaslibdir=`cygpath -aw $atlasdir | sed 's/\\\\/\\\\\\\\/g'`\\\\lib
        atlasincdir=`cygpath -aw $atlasdir | sed 's/\\\\/\\\\\\\\/g'`\\\\include
        atlasdir=`cygpath -aw $atlasdir | sed 's/\\\\/\\\\\\\\/g'`\\\\
      fi
      ;;

    CYGWIN*-*mingw*)
      lapacknames=`echo $LAPACK_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
      blasnames=`echo $BLAS_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
      blslpckdir="$LAPACK_CC4PY_DIR"/
      blslpcklibdir=`cygpath -aw $blslpckdir | sed 's/\\\\/\\\\\\\\/g'`\\\\lib
      blslpckincdir=`cygpath -aw $blslpckdir | sed 's/\\\\/\\\\\\\\/g'`\\\\include
      blslpckdir=`cygpath -aw $blslpckdir | sed 's/\\\\/\\\\\\\\/g'`\\\\
      ;;

    Linux-*)
      lapacknames=`echo $LAPACK_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
      blasnames=`echo $BLAS_CC4PY_LIBRARY_NAMES | sed 's/ /, /g'`
      blslpcklibdir="$LAPACK_CC4PY_DIR"/lib
      blslpckincdir="$LAPACK_CC4PY_DIR"/include
      blslpckdir="$LAPACK_CC4PY_DIR"/
      ;;

  esac

# Create site.cfg
# Format changed by 1.8.0.  Lines all begin with '#', and lapack_libs
# and blas_libs no longer specified.  They come from the section by default?
  local sep=':'
  if [[ `uname` =~ CYGWIN ]]; then
# Have verified that only the ',' works for the build of NumPy on CYGWIN.
# But causes problems for SciPy?
    sep=','
  fi
  if test -n "$lapacknames"; then
    case $NUMPY_BLDRVERSION in
      1.8.*)
        sed -e "s/^#\[DEFAULT/\[DEFAULT/" -e "s?^#include_dirs = /usr/local/include?include_dirs = $blslpckincdir?" -e "s?^#library_dirs = /usr/local/lib?library_dirs = ${blslpcklibdir}${sep}$flibdir?" -e "s?^#libraries = lapack,blas?libraries = $lapacknames,$blasnames?" <site.cfg.example >numpy/distutils/site.cfg
        if test -n "$atlasdir"; then
          sed -i.bak -e "s?^# *include_dirs = /opt/atlas/?include_dirs = $atlasdir?" -e "s?^# *library_dirs = /opt/atlas/lib?library_dirs = ${atlaslibdir}${sep}$flibdir?" -e "s/^# *\[atlas/\[atlas/" numpy/distutils/site.cfg
        fi
        ;;
      *)
        sed -e "s?^include_dirs = /usr/local/?include_dirs = $blslpckdir?" -e "s?^library_dirs = /usr/local/?library_dirs = $blslpckdir?" -e "s?^lapack_libs = lapack?lapack_libs = $lapacknames?" -e "s?^blas_libs = blas?blas_libs = $blasnames?" <site.cfg.example >numpy/distutils/site.cfg
        ;;
    esac
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
      NUMPY_ARGS="--compiler=$NUMPY_WIN_CC_TYPE install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
      local fcbase=`basename "$PYC_FC"`
      NUMPY_ENV="$DISTUTILS_ENV"
      if $NUMPY_WIN_USE_FORTRAN && `which "$fcbase" 1>/dev/null 2>&1`; then
        # NUMPY_ARGS="--fcompiler='$fcbase' $NUMPY_ARGS"
# The above specification fails with
# don't know how to compile Fortran code on platform 'nt' with 'x86_64-w64-mingw32-gfortran.exe' compiler. Supported compilers are: pathf95,intelvem,absoft,compaq,ibm,sun,lahey,pg,hpux,intele,gnu95,intelv,g95,intel,compaqv,mips,vast,nag,none,intelem,gnu,intelev)
        NUMPY_ARGS="--fcompiler=gnu95 $NUMPY_ARGS"
      else
        techo "WARNING: [numpy.sh] $fcbase not found in path."
      fi
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
      # Handle the case where PYC_FC may not be in path
      NUMPY_ARGS="--fcompiler=`basename ${PYC_FC}`"
      local fcpath=`dirname ${PYC_FC}`
      NUMPY_ENV="$DISTUTILS_ENV2 PATH=${PATH}:${fcpath}"
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
# Get the installed nodes of the numpy packages
#
######################################################################

getInstNumpyNodes() {
# Get full paths, convert to native as needed
  local nodes=("$PYTHON_SITEPKGSDIR/numpy" "$PYTHON_SITEPKGSDIR/numpy-${NUMPY_BLDRVERSION}-py${PYTHON_MAJMIN}.egg-info")
  echo ${nodes[*]}
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
  techo "numpy installation nodes are `getInstNumpyNodes`."
}

