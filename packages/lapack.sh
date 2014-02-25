#!/bin/bash
#
# Version and build information for lapack.
# The original tarball was obtained here:
#   http://www.netlib.org/lapack/lapack-3.4.0.tgz
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LAPACK_BLDRVERSION_STD=${LAPACK_BLDRVERSION_STD="3.4.2"}
LAPACK_BLDRVERSION_EXP=${LAPACK_BLDRVERSION_EXP="3.4.2"}
computeVersion lapack

######################################################################
#
# Other values
#
######################################################################

setLapackGlobalVars() {
# We cannot rely on system builds, as they get the PIC flags wrong.
# Need liblapack.a compiled with -fPIC so that we can get the shared
# ATLAS library, which is needed for numpy.
  if test -z "$LAPACK_BUILDS"; then
    case `uname`-$CC in
      CYGWIN*-mingw*)
        LAPACK_BUILDS=ser,sersh,sermd
        addCc4pyBuild lapack
        ;;
      CYGWIN*) # If this works, consolidate with above
        LAPACK_BUILDS=ser,sersh,sermd
        addCc4pyBuild lapack
        ;;
      Darwin-*) # Darwin has -framework Accelerate
        LAPACK_BUILDS=NONE
        ;;
      Linux-*)
        LAPACK_BUILDS=ser,sersh
        addCc4pyBuild lapack
        addBenBuild lapack
        ;;
    esac
  fi
  trimvar LAPACK_BUILDS ','
  LAPACK_DEPS=cmake
  LAPACK_UMASK=002
}
setLapackGlobalVars

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
  if bilderConfig lapack cc4py "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $LAPACK_CC4PY_OTHER_ARGS"; then
    bilderBuild $buildargs lapack cc4py
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
  local anyinstalled=false
  for bld in ser sermd sersh cc4py ben; do
    if bilderInstall lapack $bld; then
      anyinstalled=true
      case `uname` in
        CYGWIN*)
          libdir=$CONTRIB_DIR/lapack-${LAPACK_BLDRVERSION}-$bld/lib
          for lib in blas lapack tmglib; do
            if test -f $libdir/lib${lib}.a; then
              cmd="mv $libdir/lib${lib}.a $libdir/${lib}.lib"
              techo "$cmd"
              $cmd
            fi
	    # shared not built for Windows, so no need to look for DLLs
          done
          ;;
      esac
    fi
  done
  if $anyinstalled; then
    findBlasLapack
  fi
  # techo "WARNING: Quitting at end of lapack.sh."; cleanup
  return 0
}

