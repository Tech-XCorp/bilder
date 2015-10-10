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
# Trigger variables set in hdf5_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/hdf5_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setHdf5NonTriggerVars() {
  HDF5_UMASK=002
}
setHdf5NonTriggerVars

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
  local HDF5_SERSH_ADDL_ARGS=
  local HDF5_PAR_ADDL_ARGS= 
  local HDF5_SERSH_ADDL_ARGS=
  local HDF5_PARSH_ADDL_ARGS=
  local HDF5_PYCSH_ADDL_ARGS=
  case `uname` in
    Darwin)
# Shared libs to know their installation names so that builds of
# dependents link to this for installation to work without DYLD_LIBRARY_PATH
      HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_ADDL_ARGS -DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      HDF5_PYCSH_ADDL_ARGS="$HDF5_PYCSH_ADDL_ARGS -DHDF5_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      ;;
    Linux)
      # HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS
# Hasry: Above gets RPATH=/scr_hasry/contrib/lib on libhdf5.so.1.8.13 only
      # HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
# Hasry: above gets RPATH=/scr_hasry/contrib/lib on libhdf5.so.1.8.13 only
      # HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING='$SER_EXTRA_LDFLAGS"
# Hasry: above gets RPATH=/scr_hasry/contrib/lib on libhdf5.so.1.8.13 only
      # HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING='$SERSH_EXTRA_LDFLAGS -Wl,-rpath,XORIGIN:XORIGIN/../lib'"
# Hasry: above gets RPATH=/scr_hasry/contrib/lib on libhdf5.so.1.8.13 only
      # HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib"
# Hasry: Works!  Ivy fails because non system compiler.
      HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH"
# Ivy: Works!
      HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH"
      HDF5_PYCSH_ADDL_ARGS="$HDF5_PYCSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH"
      ;;
    CYGWIN*)
      echo "HDF5 cygwin case"
# For icl we have to explicitly tell cmake that, no, we *really* don't want the shared runtime.
      if echo "$CMAKE_COMPILERS_SER" | grep -q "icl"; then
           echo "HDF5 Cygwin ICL ser compiler"
	   HDF5_SER_ADDL_ARGS="-DCMAKE_STATIC_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt' -DCMAKE_EXE_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt'"
      fi
# HDF5 CMake is unable to properly parse return codes from Intel MPI wrappers, so we have to use the compiler directly
      if echo "$CMAKE_COMPILERS_PAR" | grep -q "mpiicc"; then
          echo "HDF5 Cygwin ICL par compiler"
	  HDF5_PAR_ADDL_ARGS="-DCMAKE_STATIC_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt' -DCMAKE_EXE_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt' -DMPI_HEADER_PATH:PATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/include'  -DMPI_DIR:PATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/'  -DMPI_INCLUDE_PATH:PATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/include' -DMPI_LIBRARY:FILEPATH:FILEPATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/lib/release_mt/impi.lib'";
      fi
  esac

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
  if bilderConfig -c hdf5 pycst "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $HDF5_SHARED_ENABLE_FORTRAN $HDF5_PYCST_ADDL_ARGS $HDF5_PYCST_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
    bilderBuild hdf5 pycst "$HDF5_MAKEJ_ARGS" "$DISTUTILS_NOLV_ENV"
  fi
  if bilderConfig -c hdf5 pycsh "-DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $HDF5_SHARED_ENABLE_FORTRAN $HDF5_PYCSH_ADDL_ARGS $HDF5_PYCSH_OTHER_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
    bilderBuild hdf5 pycsh "$HDF5_MAKEJ_ARGS" "$DISTUTILS_NOLV_ENV"
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

# Fix the shared installations rpaths
#
# 1: The build
#
fixHdf5SharedInst() {

  bld=$1
  local instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld
  local libdir=$instdir/lib
  local bindir=$instdir/bin

# Fix the libraries
  if declare -f bilderFixRpath 1>/dev/null 2>&1; then
    bilderFixRpath $libdir
    for exe in `\ls $bindir | tr '\n' ' '`; do
      if test -x $bindir/$exe; then
        bilderFixRpath $bindir/$exe
      fi
    done
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
    *sh) fixHdf5SharedInst $bld;;
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
  for bld in `echo $HDF5_BUILDS | tr ',' ' '`; do
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

}

