#!/bin/bash
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in lapack_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/lapack_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLapackNonTriggerVars() {
  LAPACK_UMASK=002
}
setLapackNonTriggerVars

######################################################################
#
# Launch lapack builds.
#
######################################################################

buildLapack() {

  if ! bilderUnpack lapack; then
    return
  fi

  local buildargs=
  if [[ `uname` =~ CYGWIN ]]; then
    buildargs="-m nmake"
  fi

# A. Pletzer: building the testing code fails with a seg fault on
# Linux systems running gfortran 4.4.6. Turn off BUILD_TESTING
# for these cases
  if [ `uname` = "Linux" -a "gfortran" = `basename $FC` ]; then
    version=`$FC --version | tr '\n' ' ' | awk '{print $4}'`
    if [ "4.4.6" = $version ]; then
      LAPACK_SER_OTHER_ARGS="-DBUILD_TESTING:BOOL=OFF $LAPACK_SER_OTHER_ARGS"
	LAPACK_SERSH_OTHER_ARGS="-DBUILD_TESTING:BOOL=OFF $LAPACK_SER_OTHER_ARGS"
    fi
  fi

  if bilderConfig lapack ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $LAPACK_SER_OTHER_ARGS"; then
    bilderBuild $buildargs lapack ser
  fi
  if bilderConfig lapack sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $LAPACK_SERMD_OTHER_ARGS"; then
    bilderBuild $buildargs lapack sermd
  fi
  if bilderConfig lapack sersh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $LAPACK_SERSH_OTHER_ARGS"; then
    bilderBuild $buildargs lapack sersh
  fi
  if bilderConfig lapack pycsh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $LAPACK_PYCSH_OTHER_ARGS"; then
    bilderBuild $buildargs lapack pycsh
  fi
  if bilderConfig lapack ben "$CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $LAPACK_BEN_OTHER_ARGS"; then
    bilderBuild $buildargs lapack ben
  fi

  return 0

}

######################################################################
#
# Test lapack
#
######################################################################

testLapack() {
  techo "Not testing lapack."
}

######################################################################
#
# Install lapack.
# Done manually, as make install does not work.
#
######################################################################

installLapack() {
  LAPACK_INSTALLED=false
  for bld in ser sermd sersh pycsh ben; do
    if bilderInstall lapack $bld; then
      LAPACK_INSTALLED=true
      case `uname` in
        CYGWIN*)
          libdir=$CONTRIB_DIR/lapack-${LAPACK_BLDRVERSION}-$bld/lib
          for lib in blas lapack tmglib; do
            if test -f $libdir/lib${lib}.a; then
              cmd="mv $libdir/lib${lib}.a $libdir/${lib}.lib"
              techo "$cmd"
              $cmd
            fi
# Shared not built for Windows, so no need to look for DLLs
          done
          ;;
      esac
    fi
  done
  return 0
}

