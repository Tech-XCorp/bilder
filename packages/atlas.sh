#!/bin/bash
#
# Version and build information for atlas
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

ATLAS_BLDRVERSION_STD=${ATLAS_BLDRVERSION_STD:-"3.10.0"}
if [[ `uname` =~ CYGWIN ]]; then
  ATLAS_BLDRVERSION_EXP=${ATLAS_BLDRVERSION_EXP:-"3.10.1"}
else
  ATLAS_BLDRVERSION_EXP=${ATLAS_BLDRVERSION_EXP:-"3.11.17"}
fi

######################################################################
#
# Builds and other values
#
######################################################################

# techo
# techo "BUILD_OPTIONAL = $BUILD_OPTIONAL."
# techo "ATLAS_BUILDS = $ATLAS_BUILDS."
if test -z "$ATLAS_BUILDS" && $BUILD_ATLAS; then
  case `uname` in
    CYGWIN*)
      # ATLAS_BUILDS=clp
      if test -n "$FC"; then
        ATLAS_BUILDS=ser
      else
        ATLAS_BUILDS=NONE
      fi
      ;;
    Darwin)
      ATLAS_BUILDS=NONE
      ;;
    Linux)
      ATLAS_BUILDS=ser,sersh
      addCc4pyBuild atlas
      addBenBuild atlas
      ;;
  esac
fi
trimvar ATLAS_BUILDS ','

ATLAS_DEPS=lapack

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
  fi
  case "$CC" in
    cl | */cl) ATLAS_C_ARGS="--cc=/usr/bin/gcc";;
    *mingw*) ATLAS_C_ARGS="--cc=/usr/bin/gcc -C ic '$ATLAS_CC'";;
    *)
      ATLAS_C_ARGS="--cflags='-fPIC -O3' -C ic '$CC'"
# CFLAGS assumed to contain PIC_FLAG as needed.
      local ATLAS_CFLAGS="$CFLAGS $O3_FLAG"
      trimvar ATLAS_CFLAGS ' '
      if test -n "$ATLAS_CFLAGS"; then
        ATLAS_C_ARGS="$ATLAS_C_ARGS -F ic '$ATLAS_CFLAGS'"
      fi
      ;;
  esac

# Fortran args
  local ATLAS_F_ARGS
# If fortran exists, use it.
  if test -n "$FC"; then
    local ATLAS_FC="$FC"
    if [[ `uname` =~ CYGWIN ]]; then
      ATLAS_FC=`cygpath -u "$ATLAS_FC"`
    fi
    ATLAS_F_ARGS="-C if '$ATLAS_FC'"
# FFLAGS assumed to contain PIC_FLAG as needed.
    local ATLAS_FFLAGS="$FFLAGS $O3_FLAG"
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
    local lapack_tarfile=`getPkg $lapack_tarfilebase`
  fi

# Lapack ser args
  for BLD in SER CC4PY CLP; do
    if grep -q with-netlib-lapack-tarfile $BUILD_DIR/atlas-$ATLAS_BLDRVERSION/configure; then
      eval ATLAS_${BLD}_LP_ARGS="--with-netlib-lapack-tarfile='${lapack_tarfile}'"
    else
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
  done

# Get load library path for ser build
  case `uname` in
    Linux)
      if test -n "$LIBFORTRAN_DIR"; then
        ATLAS_SER_ENV="LD_LIBRARY_PATH=$LIBFORTRAN_DIR:$LD_LIBRARY_PATH"
      fi
      ;;
  esac

# On multipole, atlas does not correctly detect that this is a 32 bit system
  case `uname`-`uname -m` in
    CYGWIN*WOW64-*)
      ATLAS_PTR_ARG="-b 64"
      ;;
    CYGWIN*)
      ATLAS_PTR_ARG="-b 32"
      ;;
    Linux-i?86)
      ATLAS_PTR_ARG="-b 32"
      ;;
  esac

# ser build
  if bilderConfig atlas ser "$ATLAS_C_ARGS $ATLAS_F_ARGS $ATLAS_PTR_ARG $ATLAS_SER_LP_ARGS --shared $ATLAS_SER_OTHER_ARGS" "" "$ATLAS_SER_ENV"; then
# Patch top Makefile for Darwin.
# Should do this at unpacking time, but do not know which file.
    if test -f ${BUILD_DIR}/atlas-${ATLAS_BLDRVERSION}/ser/Makefile; then
      cd ${BUILD_DIR}/atlas-${ATLAS_BLDRVERSION}/ser
# patch Makefile for Darwin
      sed -i.bak 's/rm *-f/rm -rf --/' Makefile
    fi
    if bilderBuild atlas ser "" "$ATLAS_SER_ENV"; then
# Fix any build problems
      : # fixRestartAtlasBuild ser
    fi
  fi

# Not doing sersh build, as we will get that from the ser build.

# cc4py build
#
# Find the python build of lapack
  if bilderConfig atlas cc4py "-C ic '$PYC_CC' -F ic '$PYC_CFLAGS -O3' -C if '$PYC_F77' -F if '$PYC_FFLAGS -O3' -Fa alg -fPIC --shared $ATLAS_PTR_ARG $ATLAS_CC4PY_LP_ARGS $ATLAS_CC4PY_OTHER_ARGS"; then
# Patch top Makefile for Darwin.
# Should do this at unpacking time, but do not know which file.
    if test -f ${BUILD_DIR}/atlas-${ATLAS_BLDRVERSION}/cc4py/Makefile; then
      cd  ${BUILD_DIR}/atlas-${ATLAS_BLDRVERSION}/cc4py
      sed -i.bak 's/rm *-f/rm -rf --/' Makefile
    fi
    bilderBuild atlas cc4py
  fi

# clapack build
  if bilderConfig atlas clp "$ATLAS_C_ARGS --nof77 $ATLAS_PTR_ARG $ATLAS_CLP_LP_ARGS $ATLAS_CLP_OTHER_ARGS"; then
# Patch top Makefile for Darwin.  Should do this at unpacking time.
    # techo "WARNING: Quitting after configure atlas."; exit 1
    if test -f ${BUILD_DIR}/atlas-${ATLAS_BLDRVERSION}/clp/Makefile; then
      cd ${BUILD_DIR}/atlas-${ATLAS_BLDRVERSION}/clp
# Patch top Makefile for Darwin.
# Should do this at unpacking time, but do not know which file.
      sed -i.bak 's/rm *-f/rm -rf --/' Makefile
    fi
    if bilderBuild atlas clp; then
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
  local anyinstalled=false
  rm -f $CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-ser/lib/*.so
  for bld in `echo $ATLAS_BUILDS | tr ',' ' '`; do
    if bilderInstall -r atlas $bld; then
      anyinstalled=true
      case `uname` in

        CYGWIN*)
          local instlibdir=$CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-$bld/lib
          for i in lapack cblas f77blas atlas; do
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
              cmd="cd $BUILD_DIR/atlas-$ATLAS_BLDRVERSION/$bld/lib"
              techo "$cmd"
              $cmd
              cmd="make shared LDFLAGS='$ldfl'"
              techo "$cmd"
              eval "$cmd"
              cmd="/usr/bin/install -m 775 -d $CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-sersh/lib"
              techo "$cmd"
              $cmd
              cmd="/usr/bin/install -m 775 *.a *.so $CONTRIB_DIR/atlas-$ATLAS_BLDRVERSION-sersh/lib"
              techo "$cmd"
              $cmd
              cd -
              $BILDER_DIR/setinstald.sh -i $CONTRIB_DIR atlas,sersh
              (cd $CONTRIB_DIR; ln -sf atlas-$ATLAS_BLDRVERSION-sersh atlas-sersh)
              ;;
          esac
          ;;

      esac
    fi
  done
  if $anyinstalled; then
    findBlasLapack
  fi

}

