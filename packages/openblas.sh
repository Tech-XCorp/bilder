#!/bin/sh
######################################################################
#
# @file    openblas.sh
#
# @brief   Build information for openblas.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in openblas_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/openblas_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOpenblasNonTriggerVars() {
  OPENBLAS_UMASK=002
}
setOpenblasNonTriggerVars

######################################################################
#
# Launch openblas builds.
#
######################################################################

buildOpenblas() {

  if ! bilderUnpack -i openblas; then
    return
  fi

# Compilers
  case `uname` in
    CYGWIN*)
      gccver=`x86_64-w64-mingw32-gcc.exe  --version | head -1 | sed -e 's/^.*) //'`
      OPENBLAS_ENV="PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/bin:'$PATH'"
      OPENBLAS_ARGS="CC=x86_64-w64-mingw32-gcc.exe FC=x86_64-w64-mingw32-gfortran.exe LDFLAGS=-L/usr/lib/gcc/x86_64-w64-mingw32/$gccver DYNAMIC_ARCH=1 USE_THREAD=0 NO_PARALLEL_MAKE=0"
      ;;
    *)
      OPENBLAS_ARGS="CC=$CC FC=$FC DYNAMIC_ARCH=1 USE_THREAD=0"
      ;;
  esac

# OpenBLAS builds ser and sersh by default
  if bilderConfig -i -C : openblas sersh; then
    bilderBuild -m make openblas sersh "$OPENBLAS_ARGS" "$OPENBLAS_ENV"
  fi

}

######################################################################
#
# Test
#
######################################################################

testOpenblas() {
  techo "Not testing openblas."
}

######################################################################
#
# Install openblas
#
######################################################################

installOpenblas() {

  for bld in `echo $OPENBLAS_BUILDS | tr ',' ' '`; do
    if bilderInstall -m make -p open openblas $bld "" "" "PREFIX=${CONTRIB_DIR}/openblas-${OPENBLAS_BLDRVERSION}-$bld"; then
      :
    fi
  done

}

