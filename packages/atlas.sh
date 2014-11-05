#!/bin/bash
#
# Build information for atlas
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in atlas_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/atlas_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setAtlasNonTriggerVars() {
  ATLAS_UMASK=002
}
setAtlasNonTriggerVars

######################################################################
#
# Fix atlas builds.
#
######################################################################

# Clean up a file from build failure and restart the build.
#
# 1: the build
#
fixRestartAtlasBuild() {
  case `uname` in
# Build fails on cygwin due to a return in a generated file.
    CYGWIN*)
      waitAction atlas-$1
      local resvar=`genbashvar atlas-$1`_RES
      local resval=`deref $resvar`
      if test "$resval" != 0; then
        local fixfile=$BUILD_DIR/atlas-$ATLAS_BLDRVERSION/$1/include/atlas_buildinfo.h
        techo "tr -d '\r' <$fixfile >tmp.h"
        tr -d '\r' <$fixfile >tmp.h
        mv tmp.h $fixfile
        cd $BUILD_DIR/atlas-$ATLAS_BLDRVERSION/$1
        $FQMAILHOST-atlas-$1-build.sh 1>build2.out 2>&1 &
        local pidval=$!
        local pidvar=`genbashvar atlas-$1`_PID
        eval $pidvar=$pidval
        eval $resvar=
        techo "atlas-$1 build restarted with $pidvar = $pidval."
      fi
      ;;
  esac
}

######################################################################
#
# Launch atlas builds.
#
######################################################################

buildAtlas() {

# If the sersh build required and not present, set ser build to be uninstalled
  if echo $ATLAS_BUILDS | grep -q sersh && ! isInstalled -i $CONTRIB_DIR atlas-${ATLAS_BLDRVERSION}-sersh; then
    techo "atlas-${ATLAS_BLDRVERSION}-sersh is not installed, so setting atlas-ser as not installed."
    $BILDER_DIR/setinstald.sh -i $CONTRIB_DIR -r atlas,ser
  else
    techo "atlas-${ATLAS_BLDRVERSION}-sersh is installed."
  fi


# All builds and deps now taken from global variables
  if ! bilderUnpack atlas; then
    return
  fi

# No attempt to build atlas if not possible due to throttling
  case `uname` in
    Linux)
      perfvals=`$BILDER_DIR/chgfreq.sh`
      if echo $perfvals | grep -q powersave || echo $perfvals | grep ondemand; then
      techo "WARNING: Throttling turned on.  Atlas will not build."
      techo "WARNING: Use 'bilder/chgfreq.sh performance' to fix."
      return 1
      fi
      ;;
  esac

# Atlas environment
  if test -n "$NOPAREN_PATH"; then
    ATLAS_ENV="PATH='$NOPAREN_PATH'"
  fi

#
# --cc=<C compiler> : compiler to compile configure probes
# --cflags='<flags>' : flags for above
# C args
  local ATLAS_C_ARGS
  # local HAVE_ATLAS_FC=true
  # techo "CC = $CC"
  local ATLAS_CC="$CC"
  if [[ `uname` =~ CYGWIN ]]; then
    ATLAS_CC=`cygpath -u "$CC"`
    ATLAS_SER_O3_FLAG=-O3
  fi
  case "$CC" in
    cl | */cl) ATLAS_C_ARGS="--cc=/usr/bin/gcc --cflags='-O3' -C ic '$ATLAS_CC'";;
    *mingw*) ATLAS_C_ARGS="--cc=/usr/bin/gcc --cflags='-O3' -C ic '$ATLAS_CC'";;
    *)
      ATLAS_C_ARGS="--cflags='-O3' -C ic '$CC'" # Use -fPIC on Linux?
# CFLAGS assumed to contain PIC_FLAG as needed.
      ;;
  esac
# For clp build
  local ATLAS_CFLAGS="$CFLAGS $O3_FLAG"
  trimvar ATLAS_CFLAGS ' '
  if test -n "$ATLAS_CFLAGS"; then
    ATLAS_C_ARGS="$ATLAS_C_ARGS -F ic '$ATLAS_CFLAGS'"
  fi

# Fortran args
  local ATLAS_F_ARGS
# If fortran exists, use it.
  if test -n "$FC"; then
    local ATLAS_FC="$FC"
    if [[ `uname` =~ CYGWIN ]]; then
      ATLAS_FC=`cygpath -u "$ATLAS_FC"`
      ATLAS_SER_CC=`echo "$ATLAS_FC" | sed 's/gfortran/gcc/g'`
    else
      ATLAS_SER_CC=$CC
    fi
    ATLAS_SER_C_ARGS="-C ic '$ATLAS_SER_CC'"
    local ATLAS_SER_CFLAGS="$CFLAGS $ATLAS_SER_O3_FLAG"
    trimvar ATLAS_SER_CFLAGS ' '
    if test -n "$ATLAS_SER_CFLAGS"; then
      ATLAS_SER_C_ARGS="$ATLAS_SER_C_ARGS -F ic '$ATLAS_SER_CFLAGS'"
    fi
    ATLAS_F_ARGS="-C if '$ATLAS_FC'"
# FFLAGS assumed to contain PIC_FLAG as needed.
    local ATLAS_FFLAGS="$FFLAGS $ATLAS_SER_O3_FLAG"
    case $FC in
      xlf* | */xlf*) ATLAS_FFLAGS="$ATLAS_FFLAGS -qfixed=132";;
    esac
    trimvar ATLAS_FFLAGS ' '
    if test -n "$ATLAS_FFLAGS"; then
      ATLAS_F_ARGS="$ATLAS_F_ARGS -F if '$ATLAS_FFLAGS'"
    fi
  fi

# Get lapack if needed
  if grep -q with-netlib-lapack-tarfile $BUILD_DIR/atlas-$ATLAS_BLDRVERSION/configure; then
    if test -z ${LAPACK_BLDRVERSION}; then
      source $BILDER_DIR/packages/lapack.sh
    fi
    local lapack_tarfilebase=lapack-${LAPACK_BLDRVERSION}
    getPkg $lapack_tarfilebase
    local lapack_tarfile="$GETPKG_RETURN"
    if test -z ${CLAPACK_CMAKE_BLDRVERSION}; then
      source $BILDER_DIR/packages/clapack_cmake.sh
    fi
    local clapack_tarfilebase=clapack_cmake-${CLAPACK_CMAKE_BLDRVERSION}
    getPkg $clapack_tarfilebase
    local clapack_tarfile="$GETPKG_RETURN"
  fi

# Lapack ser args
  for bld in `echo $ATLAS_BUILDS | tr ',' ' '`; do
    if grep -q with-netlib-lapack-tarfile $BUILD_DIR/atlas-$ATLAS_BLDRVERSION/configure; then
      local lpargsvar=`genbashvar ATLAS_${bld}`_LP_ARGS
      if test $bld = clp; then
        eval ${lpargsvar}="--with-netlib-lapack-tarfile='${clapack_tarfile}'"
      else
        eval ${lpargsvar}="--with-netlib-lapack-tarfile='${lapack_tarfile}'"
      fi
    else
# Below not fixed for CLP case
      local lapack_lib=`deref CONTRIB_LAPACK_${BLD}_LIB`
      if test -n "$lapack_lib"; then
        case `uname` in
          CYGWIN*)
            lapack_lib=`cygpath -au $lapack_lib`
            ;;
        esac
        eval ATLAS_${BLD}_LP_ARGS="--with-netlib-lapack='$lapack_lib'"
      fi
    fi
    eval lpargsval=`deref ${lpargsvar}`
    techo "${lpargsvar} = ${lpargsval}"
  done

# Get load library path for ser build
  case `uname` in
    Linux)
      if test -n "$LIBFORTRAN_DIR"; then
        ATLAS_SER_ENV="LD_LIBRARY_PATH=$LIBFORTRAN_DIR:$LD_LIBRARY_PATH"
      fi
      ;;
  esac

# Do for one case
  ATLAS_CLP_ENV="$ATLAS_ENV $ATLAS_CLP_ENV"
  ATLAS_SER_ENV="$ATLAS_ENV $ATLAS_SER_ENV"

# Atlas does not alway correctly detect 32 versus 64 bit
  case `uname`-`uname -m` in
    CYGWIN*)
      if $IS_64BIT; then
        ATLAS_PTR_ARG="-b 64"
      else
        ATLAS_PTR_ARG="-b 32"
      fi
      ;;
    Linux-i?86)
      ATLAS_PTR_ARG="-b 32"
      ;;
  esac

# ser build.  Has no /MT or /MD so good for shared or static on Windows.
  if bilderConfig atlas ser "$ATLAS_SER_C_ARGS $ATLAS_F_ARGS $ATLAS_PTR_ARG $ATLAS_SER_LP_ARGS --shared $ATLAS_SER_OTHER_ARGS" "" "$ATLAS_SER_ENV"; then
    # techo "WARNING: Quitting after configuring atlas for ser build."; exit 1
    if bilderBuild atlas ser "" "$ATLAS_SER_ENV"; then
# Fix any build problems
      : # fixRestartAtlasBuild ser
    fi
  fi

# Not doing sersh build, as we will get that from the ser build.

# pycsh build
#
# Find the python build of lapack
  if bilderConfig atlas pycsh "-C ic '$PYC_CC' -F ic '$PYC_CFLAGS -O3' -C if '$PYC_F77' -F if '$PYC_FFLAGS -O3' -Fa alg -fPIC --shared $ATLAS_PTR_ARG $ATLAS_PYCSH_LP_ARGS $ATLAS_PYCSH_OTHER_ARGS" "" "$ATLAS_PYCSH_ENV"; then
    bilderBuild atlas pycsh "" "$ATLAS_PYCSH_ENV"
  fi

# clapack build
  if bilderConfig atlas clp "$ATLAS_C_ARGS --nof77 $ATLAS_PTR_ARG $ATLAS_CLP_LP_ARGS $ATLAS_CLP_OTHER_ARGS" "" "$ATLAS_CLP_ENV"; then
# Patch top Makefile for Darwin.  Should do this at unpacking time.
    # techo "WARNING: Quitting after configuring atlas for clp build."; exit 1
    if bilderBuild atlas clp "" "$ATLAS_CLP_ENV"; then
# Fix any build problems
      fixRestartAtlasBuild clp
    fi
  fi
}

######################################################################
#
# Test atlas
#
######################################################################

testAtlas() {
  techo "Not testing atlas."
}

######################################################################
#
# Install atlas, look for it again.
#
######################################################################

installAtlas() {
  ATLAS_INSTALLED=false
  rm -f $CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-ser/lib/*.so
  for bld in `echo $ATLAS_BUILDS | tr ',' ' '`; do
    if bilderInstall -r atlas $bld; then
      ATLAS_INSTALLED=true
      case `uname` in

        CYGWIN*)
          local instlibdir=$CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-$bld/lib
          for i in lapack cblas f77blas atlas ptcblas ptf77blas; do
            if test -f $instlibdir/lib${i}.a; then
              cmd="mv $instlibdir/lib${i}.a $instlibdir/${i}.lib"
              techo "$cmd"
              $cmd
            fi
          done
          case $bld in
            clp)
# Copy the f2clib over
              cp $CLAPACK_CMAKE_SER_LIBDIR/f2c.lib $CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-$bld/lib
              ;;
          esac
          ;;

        Linux)
# If built static, then it seems numpy cannot find atlas?
# If build shared, then cannot import numpy, unless it gets an rpath flag
          local ldfl=--allow-multiple-definition
# This counts on the ser build being done
          case $bld in
            ser)
              if isCcGcc && test -n "$LIBGFORTRAN_DIR"; then
                ldfl="$ldfl -L$LIBGFORTRAN_DIR -rpath $LIBGFORTRAN_DIR"
              fi
              techo "Creating shared atlas libraries."
              cmd="cd $BUILD_DIR/atlas-${ATLAS_BLDRVERSION}/$bld/lib"
              techo "$cmd"
              $cmd
              cmd="make shared LDFLAGS='$ldfl'"
              techo "$cmd"
              eval "$cmd"
              cmd="/usr/bin/install -m 775 -d $CONTRIB_DIR/atlas-${ATLAS_BLDRVERSION}-sersh/lib"
              techo "$cmd"
              $cmd
              cmd="/usr/bin/install -m 775 *.a *.so $CONTRIB_DIR/atlas-${ATLAS_BLDRVERSION}-sersh/lib"
              techo "$cmd"
              $cmd
              cd -
              (cd $CONTRIB_DIR; rm -rf atlas-sersh; ln -sf atlas-${ATLAS_BLDRVERSION}-sersh atlas-sersh)
              ATLAS_PATCH=${ATLAS_PATCH:-"$BILDER_DIR/patches/atlas-${ATLAS_BLDRVERSION}.patch"}
              if test -n "$ATLAS_PATCH"; then
                cmd="/usr/bin/install -m 664 $ATLAS_PATCH $CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-sersh"
                techo "$cmd"
                $cmd
              else
                techo "ATLAS_PATCH not defined."
              fi
              $BILDER_DIR/setinstald.sh -i $CONTRIB_DIR atlas,sersh
              ;;
          esac
          ;;

      esac
    fi
  done
}

