#!/bin/bash
#
# Version and build information for hdf5
#
# $Id$
#
# For mingw: http://www.swarm.org/index.php/Swarm_and_MinGW#HDF5_.28Optional.29
#
######################################################################

######################################################################
#
# Version:
#
######################################################################

case `uname` in
  CYGWIN*)
# If you upgrade to a newer version of hdf5, first check a parallel run on
# 32-bit Windows and be sure it does not crash.
    if [[ "$CC" =~ mingw ]]; then
      HDF5_BLDRVERSION_STD=1.8.10
    else
      HDF5_BLDRVERSION_STD=1.8.12
    fi
    ;;

  Darwin)
    case `uname -r` in
      13.*) HDF5_BLDRVERSION_STD=1.8.9;;	# Mavericks
         *) HDF5_BLDRVERSION_STD=1.8.12;;	# Everything else
    esac
    ;;

  Linux) HDF5_BLDRVERSION_STD=1.8.12;;
esac

HDF5_BLDRVERSION_EXP=1.8.12

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setHdf5GlobalVars() {
# Set the builds.
  if test -z "$HDF5_DESIRED_BUILDS"; then
    HDF5_DESIRED_BUILDS=ser,par,sersh
# No need for parallel shared, as MPI executables are built static.
    case `uname`-${BILDER_CHAIN} in
      CYGWIN*)
        HDF5_DESIRED_BUILDS="$HDF5_DESIRED_BUILDS,sermd"
        if test "$VISUALSTUDIO_VERSION" = "10"; then
# Python built with VS9, so need hdf5 build for that
          HDF5_DESIRED_BUILDS="$HDF5_DESIRED_BUILDS,cc4py"
        fi
        ;;
    esac
  fi
  computeBuilds hdf5
  addCc4pyBuild hdf5
  HDF5_DEPS=openmpi,zlib,cmake,bzip2
  HDF5_UMASK=002
  addtopathvar PATH $CONTRIB_DIR/hdf5/bin
}
setHdf5GlobalVars

######################################################################
#
# Launch hdf5 builds.
#
######################################################################

# Helper method to determine whether Fortran can compile hdf5
haveHdf5Fortran() {
# Check ability of compiler to compile hdf5
  if $HAVE_SER_FORTRAN; then
    case "$FC" in
      *gfortran*)
        vertmp=`$FC --version | sed -e 's/^GNU Fortran ([^)]*)//'`
        gfortranversion=`echo $vertmp | sed 's/ .*//'`
        case "$gfortranversion" in
          4.3.2)
            techo "gfortran cannot compile hdf5."
            techo "See http://gcc.gnu.org/ml/gcc-bugs/2008-11/msg01510.html."
            return 1
            ;;
          4.3.* | 4.4.* | 4.5.* | 4.6.* )
            #techo "gfortran can compile hdf5."
            return 0
            ;;
        esac
        ;;
    esac
    return 0
  fi
  return 1
}

buildHdf5() {

  if ! bilderUnpack hdf5; then
    return
  fi

# Missing file in 1.8.7
  touch $BUILD_DIR/hdf5-$HDF5_BLDRVERSION/release_docs/INSTALL_parallel.txt

# Can we build fortran?
  local HDF5_STATIC_ENABLE_FORTRAN=
  local HDF5_SHARED_ENABLE_FORTRAN=
  if haveHdf5Fortran; then
    HDF5_STATIC_ENABLE_FORTRAN=-DHDF5_BUILD_FORTRAN:BOOL=ON
  fi
# Not with Darwin
  if test `uname` != Darwin; then
    HDF5_SHARED_ENABLE_FORTRAN=$HDF5_STATIC_ENABLE_FORTRAN
  fi

# Shared: For Linux, add origin to rpath, do not strip rpath
  local HDF5_SER_ADDL_ARGS=
  local HDF5_PAR_ADDL_ARGS=
  local HDF5_SERSH_ADDL_ARGS="-DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
  local HDF5_PARSH_ADDL_ARGS="-DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
  case `uname` in
    Linux)
      # HDF5_SER_ADDL_ARGS="$HDF5_SER_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
      # HDF5_PAR_ADDL_ARGS="$HDF5_PAR_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
      HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_SHARED_LINKER_FLAGS:STRING='-Wl,-rpath,\$ORIGIN' -DCMAKE_SKIP_RPATH:BOOL=ON -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
      HDF5_PARSH_ADDL_ARGS="-DCMAKE_SHARED_LINKER_FLAGS:STRING='-Wl,-rpath,\$ORIGIN' -DCMAKE_SKIP_RPATH:BOOL=ON $HDF5_PARSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
      ;;
  esac

# gfortran needs to add rpath stuff in EXTRA_LDFLAGS
  for BLD in SER PAR SERSH PARSH; do
    xval=`deref ${BLD}_EXTRA_LDFLAGS`
    if test -n "$xval"; then
      aval=`deref HDF5_${BLD}_ADDL_ARGS`
      eval HDF5_${BLD}_ADDL_ARGS="\"$aval -DCMAKE_EXE_LINKER_FLAGS:STRING='$xval'\""
    fi
  done

# Separating builds for all platforms as required on Windows and this
# gives simplification
  if bilderConfig -c hdf5 sersh "-DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_SHARED_ENABLE_FORTRAN $HDF5_SERSH_ADDL_ARGS $HDF5_SERSH_OTHER_ARGS"; then
    bilderBuild hdf5 sersh "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 parsh "-DHDF5_ENABLE_PARALLEL:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $HDF5_SHARED_ENABLE_FORTRAN $HDF5_PARSH_ADDL_ARGS $HDF5_PARSH_OTHER_ARGS"; then
    bilderBuild hdf5 parsh "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 ser "$TARBALL_NODEFLIB_FLAGS -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_STATIC_ENABLE_FORTRAN $HDF5_SER_ADDL_ARGS $HDF5_SER_OTHER_ARGS"; then
    bilderBuild hdf5 ser "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 par "-DHDF5_ENABLE_PARALLEL:BOOL=ON $TARBALL_NODEFLIB_FLAGS -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $HDF5_STATIC_ENABLE_FORTRAN $HDF5_PAR_ADDL_ARGS $HDF5_PAR_OTHER_ARGS"; then
    bilderBuild hdf5 par "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_STATIC_ENABLE_FORTRAN $HDF5_SER_ADDL_ARGS $HDF5_SER_OTHER_ARGS"; then
    bilderBuild hdf5 sermd "$HDF5_MAKEJ_ARGS"
  fi
  if bilderConfig -c hdf5 cc4py "-DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $HDF5_CC4PY_ADDL_ARGS $HDF5_SHARED_ENABLE_FORTRAN $HDF5_CC4PY_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
    bilderBuild hdf5 cc4py "$HDF5_MAKEJ_ARGS" "$DISTUTILS_NOLV_ENV"
  fi

}

######################################################################
#
# Test
#
######################################################################

testHdf5() {
  techo "Not testing hdf5."
}

######################################################################
#
# Install
#
######################################################################

# Move the static executables up to the bin dir
#
# 1: The bin directory
#
moveHdf5Tools() {
  if test -d $1/tools; then
    cmd="mv $1/tools/* $1"
    techo "$cmd"
    $cmd
  else
    techo "NOTE [moveHdf5Tools]: Tools already directly under $1."
  fi
}

# Fix the HDF5 liblib problem
#
# 1: The build
#
fixHdf5StaticLibs() {

  bld=$1
  local instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld
  local libdir=$instdir/lib

# Fix erroneous library names
  local libs=`\ls $libdir/* 2>/dev/null`
  techo "Examining library names for hdf5-$HDF5_BLDRVERSION-$bld."
  for i in $libs; do
# The liblib error occurs in some versions between 1.8.7 and 1.8.9
    local newname=`echo $i | sed -e 's?/liblibhdf5?/libhdf5?'`
    case `uname` in
      CYGWIN*)
# As of 1.8.11, static libs have prepended lib on Windows.
        local newname=`echo $newname | sed -e 's?/libhdf5?/hdf5?' -e 's/\.a$/.lib/'`
        ;;
    esac
    if test "$i" != "$newname"; then
      cmd="mv $i $newname"
      techo "$cmd"
      $cmd
    else
      techo "NOTE [fixHdf5StaticLibs]: Library, $i, has correct name."
    fi
  done

}

#
# Fix hdf5 libraries by build
#
# Args
# 1: the name of the build
#
fixHdf5Libs() {
  bld=$1
  case $bld in
    ser | par | sermd) fixHdf5StaticLibs $bld;;
  esac
}

######################################################################
#
# Install hdf5
#
######################################################################

# Move the shared hdf5 libraries to their legacy names.
# Allows shared and static to be installed in same place.
#
# 1: The installation directory
#
installHdf5() {

# Install one by one and correct
  local instdir
  local hdf5installed=false

# Static installations first, so static tools can be moved up and saved
# just under bin.
# Remove (-r) old installations.  This assumee that the shared libs
# will subsequently be reinstalled if needed.
  for bld in ser par sersh parsh sermd cc4py; do
    if bilderInstall -p open -r hdf5 $bld; then
      hdf5installed=true
      instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld
      chmod -R g+w $instdir
      moveHdf5Tools $instdir/bin
      fixHdf5Libs $bld
      case `uname` in
        Darwin)
          local hdf5cmakefile=$instdir/share/cmake/hdf5-${HDF5_BLDRVERSION}/hdf5-config.cmake
          if test -f $hdf5cmakefile; then
            sed -i.bak -e '/SET (BUILD_SHARED_LIBS /s/^/# /' -e '/SET (HDF5_BUILD_SHARED_LIBS /s/^/# /' $hdf5cmakefile
          fi
          ;;
      esac
    fi
  done

# Then refind hdf5
  if $hdf5installed; then
    findContribPackage Hdf5 hdf5 ser par
    case `uname` in
      CYGWIN*)
        findContribPackage Hdf5 hdf5dll sersh parsh sermd cc4py
        ;;
      *)
        findContribPackage Hdf5 hdf5 sersh parsh cc4py
        ;;
    esac
    findCc4pyDir Hdf5
  fi

}
