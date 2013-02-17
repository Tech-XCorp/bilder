#!/bin/bash
#
# Version and build information for scipy
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SCIPY_BLDRVERSION_STD=0.11.0
SCIPY_BLDRVERSION_EXP=0.11.0

######################################################################
#
# Other values
#
######################################################################

SCIPY_BUILDS=${SCIPY_BUILDS:-"cc4py"}
SCIPY_DEPS=numpy,atlas

#####################################################################
#
# Launch scipy builds.
#
######################################################################

buildScipy() {

  if bilderUnpack scipy; then

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
    local linkflags="$CC4PY_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"

# Determine whether to use atlas
    if $HAVE_ATLAS_ANY && $USE_ATLAS_CC4PY; then
      techo "Building scipy with ATLAS."
      techo "ATLAS_CC4PY_DIR = $ATLAS_CC4PY_DIR,  ATLAS_CC4PY_LIBDIR = $ATLAS_CC4PY_LIBDIR."
    fi

# Get env and args
    case `uname`-"$CC" in
      CYGWIN*-*cl*)
        SCIPY_ARGS="--compiler=msvc --fcompiler=gfortran install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
         SCIPY_ENV="$DISTUTILS_ENV"
# Need to add LAPACK=<lapack_libdir> BLAS=<blas_libdir> as below.
        # if test -n "$ATLAS_CC4PY_LIBDIR"; then
          # SCIPY_ENV="$DISTUTILS_ENV ATLAS='$ATLAS_CC4PY_LIBDIR'"
        # else
          # SCIPY_ENV="$DISTUTILS_ENV LAPACK='C:\winsame\contrib-mingw\lapack-${LAPACK_BLDRVERSION}-ser\lib' BLAS='C:\winsame\contrib-mingw\lapack-${LAPACK_BLDRVERSION}-ser\lib'"
        # fi
        ;;
      CYGWIN*-*mingw*)
# Have to install with build to get both prefix and compiler correct.
        SCIPY_ARGS="--compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        SCIPY_ENV="PATH=$mingwdir:'$PATH'"
        if test -n "$ATLAS_CC4PY_LIBDIR"; then
          SCIPY_ENV="$SCIPY_ENV ATLAS='$ATLAS_CC4PY_LIBDIR'"
        else
          SCIPY_ENV="$SCIPY_ENV LAPACK='C:\winsame\contrib-mingw\lapack-${LAPACK_BLDRVERSION}-ser\lib' BLAS='C:\winsame\contrib-mingw\lapack-${LAPACK_BLDRVERSION}-ser\lib'"
        fi
        ;;
# For non-Cygwin builds, the build stage does not install.
      Darwin-*)
        # linkflags="$linkflags -bundle -Wall"
        linkflags="$linkflags -Wall"
        SCIPY_ENV="$DISTUTILS_ENV2 CFLAGS='-arch i386 -arch x86_64' FFLAGS='-m32 -m64'"
        ;;
      Linux-*)
        local LAPACK_LIB_DIR=${CONTRIB_DIR}/lapack-${LAPACK_BLDRVERSION}-sersh/lib
        SCIPY_ENV="$DISTUTILS_ENV2 $SCIPY_GFORTRAN BLAS='$LAPACK_LIB_DIR' LAPACK='$LAPACK_LIB_DIR'"
	linkflags="$linkflags -Wl,-rpath,${PYTHON_LIBDIR}"
        ;;
      *)
        techo "WARNING: [scipy.sh] uname `uname` not recognized.  Not building."
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
    bilderDuBuild scipy "$SCIPY_ARGS" "$SCIPY_ENV"
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
    *) bilderDuInstall -r scipy scipy "-" "$SCIPY_ENV";;
  esac
  # techo "WARNING: Quitting at the end of scipy.sh."; cleanup
}

