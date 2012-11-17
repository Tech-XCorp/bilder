#!/bin/bash
#
# Version and build information for hdf5
#
# $Id$
#
# For mingw: http://www.swarm.org/index.php/Swarm_and_MinGW#HDF5_.28Optional.29
#
######################################################################

HDF5_UNAME=`uname`

######################################################################
#
# Version:
#
######################################################################

# ??? Problem building fortran shared libs on Linux
# for hdf5 versions 1.8.8 or 1.8.9 using cmake-2.8.8.
# CMakeFiles/hdf5_f90cstub.dir/__/H5f90i_gen.h.o: file not recognized: File format not recognized
# Need to recheck

case $HDF5_UNAME in
  CYGWIN*) if [[ "$CC" =~ mingw ]]; then
             HDF5_BLDRVERSION_STD=1.8.7
           else
             HDF5_BLDRVERSION_STD=1.8.8
           fi;;

# Failure of 1.8.8 on Lion and Snow Leopard confirmed.
# h5diff 1.8.8 and 1.8.9 seg fault on Lion consistently.
# binaries built separately (see below for 'binaries' build)
# With cmake.2.8.9 and Xcode 3.2.6 hdf5-1.8.9 works on Snowleopard
# h5diff 1.8.9 built with autotools does not seg fault on lion
# but we have seen incorrect results from it.  So, sticking with 1.8.7
  Darwin) HDF5_BLDRVERSION_STD=1.8.7;;

# Linux will utilize hdf5-1.8.9
# With cmake.2.8.9 and new Xcode (Oct 2 2012) hdf5-1.8.9 works on Lion
  *) HDF5_BLDRVERSION_STD=1.8.9;;
esac

HDF5_BLDRVERSION_EXP=1.8.10

######################################################################
#
# Other values
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

# Set the builds.
# techo "Before checking: HDF5_BUILDS = $HDF5_BUILDS."
if test -z "$HDF5_BUILDS"; then
  case $HDF5_UNAME-${BILDER_CHAIN} in
    CYGWIN*WOW64* | CYGWIN*-MinGW)
      HDF5_BUILDS="ser,par,sersh,parsh"
      if test "$VISUALSTUDIO_VERSION" = "10"; then
# Python built with VS9, so need cc4py build, which is with VS9
        HDF5_BUILDS="$HDF5_BUILDS,cc4py"
      fi
      ;;
    CYGWIN*)
      HDF5_BUILDS="ser,sersh"
# This is due to the fact that hdf5-1.8.[567] causes a crash at first dump
# in parallel on 32-bit systems.  1.8.8 does works in parallel on win32,
# so ok to add "par" and "parsh" builds.
# If you upgrade to a newer version of hdf5, first check a parallel run on
# 32-bit Windows and be sure it does not crash.
      HDF5_BUILDS="$HDF5_BUILDS,par,parsh"
      if test "$VISUALSTUDIO_VERSION" = "10"; then
# Python built with VS9, so need hdf5 build for that
        HDF5_BUILDS="$HDF5_BUILDS,cc4py"
      fi
      ;;
    Darwin*)
# cc4py is needed on Darwin for pytables as ser build of hdf5 has only
# static libs and no shared libs.
      HDF5_BUILDS="ser,par"
      if haveHdf5Fortran; then
# Since cannot build fortran and shared on Darwin, have to force a cc4py build
        addCc4pyBuild -f hdf5
      else
# If no fortran, then can build shared on Darwin.  No need for extra build.
        HDF5_BUILDS="$HDF5_BUILDS,sersh,parsh"
        addCc4pyBuild hdf5
      fi
      ;;
    *)
      HDF5_BUILDS="ser,par,sersh,parsh"
      addCc4pyBuild hdf5
      ;;
  esac
fi
# techo "HDF5_BUILDS = $HDF5_BUILDS."
# techo exit; exit
HDF5_DEPS=openmpi,zlib,cmake,bzip2
HDF5_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

case $HDF5_UNAME in
  Darwin)
    techo "Adding Mac binaries to path script"
    addtopathvar PATH $CONTRIB_DIR/hdf5-binaries/bin;;
  *)
    addtopathvar PATH $CONTRIB_DIR/hdf5/bin;;
esac


######################################################################
#
# Launch hdf5 builds.
#
######################################################################

buildHdf5() {

# Now updates on file change
  # checkHdf5

  if bilderUnpack hdf5; then

# Missing file in 1.8.7
    touch $BUILD_DIR/hdf5-$HDF5_BLDRVERSION/release_docs/INSTALL_parallel.txt

# Can we build fortran?
    if haveHdf5Fortran; then
      techo "NOTE: Building HDF5 with fortran."
      HDF5_ENABLE_FORTRAN=-DHDF5_BUILD_FORTRAN:BOOL=ON
    else
      techo "WARNING: Building HDF5 without fortran.  Some codes may require fortran."
    fi
    # techo "HDF5_ENABLE_FORTRAN = $HDF5_ENABLE_FORTRAN."

# Not adding zlib for now, as will cascade through all builds.
    if false; then
    if test -z "ZLIB_BLDRVERSION"; then
      source $BILDER_DIR/packages/zlib.sh
      case $HDF5_UNAME in
        CYGWIN*)
          local HDF5_ZLIB_CMAKE_ARG=-DZLIB_DIR:PATH=$MIXED_CONTRIB_DIR/zlib-$ZLIB_BLDRVERSION/lib
          local HDF5_ZLIB_CONFIG_ARG=--with-zlib=$MIXED_CONTRIB_DIR/zlib-$ZLIB_BLDRVERSION/lib
          ;;
      esac
    fi
    fi

# Only cmake builds, but backwards compatible
    local HDF5_ENABLE_PARALLEL="-DHDF5_ENABLE_PARALLEL:BOOL=ON"
# Remove /MD for static builds
    local HDF5_SER_STATIC_ARGS="$CMAKE_NODEFLIB_FLAGS"
    local HDF5_PAR_STATIC_ARGS="$CMAKE_NODEFLIB_FLAGS"

# Shared: For Linux, add origin to rpath, do not strip rpath
    local HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_OTHER_ARGS"
    local HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_OTHER_ARGS"
    case $HDF5_UNAME in
      Linux)
        HDF5_SERSH_ADDL_ARGS="-DCMAKE_SHARED_LINKER_FLAGS:STRING='-Wl,-rpath,\$ORIGIN' -DCMAKE_SKIP_RPATH:BOOL=ON $HDF5_SERSH_ADDL_ARGS"
        HDF5_PARSH_ADDL_ARGS="-DCMAKE_SHARED_LINKER_FLAGS:STRING='-Wl,-rpath,\$ORIGIN' -DCMAKE_SKIP_RPATH:BOOL=ON $HDF5_PARSH_ADDL_ARGS"
        ;;
    esac
# Enable fortran if flag not otherwise set
# gfortran needs to add rpath stuff in EXTRA_LDFLAGS
    if ! (echo $HDF5_SERSH_OTHER_ARGS | grep -q HDF5_BUILD_FORTRAN); then
      HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS $HDF5_ENABLE_FORTRAN"
      if test -n "$SER_EXTRA_LDFLAGS"; then
        HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING='$SER_EXTRA_LDFLAGS'"
      fi
    fi
    if ! (echo $HDF5_PARSH_OTHER_ARGS | grep -q HDF5_BUILD_FORTRAN); then
      HDF5_PARSH_ADDL_ARGS="$HDF5_ENABLE_FORTRAN $HDF5_PARSH_ADDL_ARGS"
      if test -n "$PAR_EXTRA_LDFLAGS"; then
        HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_ADDL_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING='$PAR_EXTRA_LDFLAGS'"
      fi
    fi

# Static serial
    local HDF5_SER_ADDL_ARGS="$HDF5_SER_OTHER_ARGS $HDF5_SER_CMAKE_OTHER_ARGS $HDF5_ZLIB_CMAKE_ARG"
# Enable fortran if flag not otherwise set
    if ! (echo $HDF5_SER_OTHER_ARGS | grep -q HDF5_BUILD_FORTRAN); then
      HDF5_SER_ADDL_ARGS="$HDF5_SER_ADDL_ARGS $HDF5_ENABLE_FORTRAN"
      if test -n "$SER_EXTRA_LDFLAGS"; then
        HDF5_SER_ADDL_ARGS="$HDF5_SER_ADDL_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING='$SER_EXTRA_LDFLAGS'"
      fi
    fi
# Static parallel
    local HDF5_PAR_ADDL_ARGS="$HDF5_PAR_OTHER_ARGS $HDF5_PAR_CMAKE_OTHER_ARGS $HDF5_ZLIB_CMAKE_ARG"
# Enable fortran if flag not otherwise set
    if ! (echo $HDF5_PAR_OTHER_ARGS | grep -q HDF5_BUILD_FORTRAN); then
      HDF5_PAR_ADDL_ARGS="$HDF5_PAR_ADDL_ARGS $HDF5_ENABLE_FORTRAN"
      if test -n "$PAR_EXTRA_LDFLAGS"; then
        HDF5_PAR_ADDL_ARGS="$HDF5_PAR_ADDL_ARGS -DCMAKE_EXE_LINKER_FLAGS:STRING='$PAR_EXTRA_LDFLAGS'"
      fi
    fi

# For Darwin, fortran and shared may conflict,
# so the serial build is done with fortran, but the logic above
# ensures that we also have a cc4py build that will have shared libs
#
# the _SHARED_ args are used for cmake builds.
#
# As of 1.8.6, HDF5 defines H5_BUILT_AS_DYNAMIC_LIB for dynamic
# libs, and they have a different interface, so the includes
# for static and dynamic have to be installed in different places.
# For previous versions we can use the same prefix and turn on
# legacy naming.
    local HDF5_SERSH_PREFIX_ARG=
    local HDF5_PARSH_PREFIX_ARG=
    local HDF5_LEGACY_NAMING_ARG=
    local HDF5_SER_SHARED_ARGS=
    local HDF5_PAR_SHARED_ARGS=
    case $HDF5_UNAME in
      CYGWIN* | MINGW*)
        HDF5_SER_SHARED_ARGS="-DBUILD_SHARED_LIBS:BOOL=ON"
        HDF5_PAR_SHARED_ARGS="-DBUILD_SHARED_LIBS:BOOL=ON"
        # Build tools since installed in different prefix
        HDF5_SER_ADDL_ARGS="$HDF5_SER_ADDL_ARGS -DHDF5_BUILD_TOOLS:BOOL=ON"
        HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DHDF5_BUILD_TOOLS:BOOL=ON"
        ;;
      Darwin) # Darwin shared does not work with fortran
        HDF5_SERSH_PREFIX_ARG="-p hdf5-${HDF5_BLDRVERSION}-ser"
        HDF5_PARSH_PREFIX_ARG="-p hdf5-${HDF5_BLDRVERSION}-par"
        HDF5_SER_SHARED_ARGS=""
        HDF5_PAR_SHARED_ARGS=""
        ;;
      *) # Default Linux, shared does work with fortran
        HDF5_SERSH_PREFIX_ARG="-p hdf5-${HDF5_BLDRVERSION}-ser"
        HDF5_PARSH_PREFIX_ARG="-p hdf5-${HDF5_BLDRVERSION}-par"
        HDF5_SER_SHARED_ARGS="-DBUILD_SHARED_LIBS:BOOL=ON"
        HDF5_PAR_SHARED_ARGS="-DBUILD_SHARED_LIBS:BOOL=ON"
# Make sure using shared libs from non system installation of gcc or openmpi
        HDF5_PAR_ADDL_ARGS="$HDF5_PAR_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
        HDF5_SER_ADDL_ARGS="$HDF5_SER_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
        HDF5_PARSH_ADDL_ARGS="$HDF5_PARSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
        HDF5_SERSH_ADDL_ARGS="$HDF5_SERSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
        ;;
    esac

# Shared libs: see above notes on HDF5_SERSH_PREFIX_ARG,
# HDF5_PARSH_PREFIX_ARG, and HDF5_LEGACY_NAMING_ARG.  As
# of 1.8.6, windows builds cannot go in the same directory.
    if test -n "$HDF5_SER_SHARED_ARGS"; then
      if bilderConfig -c $HDF5_SERSH_PREFIX_ARG hdf5 sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_SER_SHARED_ARGS $HDF5_SERSH_ADDL_ARGS -DHDF5_BUILD_HL_LIB:BOOL=ON $HDF5_LEGACY_NAMING_ARG"; then
        bilderBuild hdf5 sersh "$HDF5_MAKEJ_ARGS"
      fi
    fi
    if test -n "$HDF5_PAR_SHARED_ARGS"; then
      if bilderConfig -c $HDF5_PARSH_PREFIX_ARG hdf5 parsh "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR -DHDF5_ENABLE_PARALLEL:BOOL=ON $HDF5_PAR_SHARED_ARGS $HDF5_PARSH_ADDL_ARGS -DHDF5_BUILD_HL_LIB:BOOL=ON $HDF5_LEGACY_NAMING_ARG"; then
        bilderBuild hdf5 parsh "$HDF5_MAKEJ_ARGS"
      fi
    fi

#
# Now build static with fortran and tools
#

#
# ser build
# Legacy naming irrelevant for static builds
    if bilderConfig -c hdf5 ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $HDF5_SER_STATIC_ARGS -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $HDF5_SER_ADDL_ARGS"; then
      bilderBuild hdf5 ser "$HDF5_MAKEJ_ARGS"
    fi

# cc4py build is always shared
# Legacy naming irrelevant for cc4py builds
# On Windows, need $DISTUTILS_NOLV_ENV
    if bilderConfig -c hdf5 cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC -DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $HDF5_PYC_ADDL_ARGS" "" "$DISTUTILS_NOLV_ENV"; then
      bilderBuild hdf5 cc4py "$HDF5_MAKEJ_ARGS" "$DISTUTILS_NOLV_ENV"
    fi

# uedgeC.so requires shared libraries.
# Legacy naming irrelevant for static builds
    if bilderConfig -c hdf5 par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $HDF5_ENABLE_PARALLEL $HDF5_PAR_STATIC_ARGS -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_BUILD_HL_LIB:BOOL=ON $HDF5_PAR_ADDL_ARGS"; then
      bilderBuild hdf5 par "$HDF5_MAKEJ_ARGS"
    fi

#  alexanda: reverting back to 1.8.7, but leaving this section in case
#            we want to try again to get 1.8.9 to work.
#
#    #
#    # binaries build needed because
#    # cmake binary builds are broken for most(all?) versions
#    # > hdf5.1.8.7 on Mac. Using autotools build for h5dump/h5diff etc
#    #
#    case $HDF5_UNAME in
#      Darwin)
#        case `uname -r` in
#	   11.4.*)
#	    techo "Adding binaries to list of builds"
#	    HDF5_BUILDS=$HDF5_BUILDS,binaries
#            techo "Building binaries with autotools for Darwin"
#	    if bilderConfig -i hdf5 binaries; then
#		bilderBuild hdf5 binaries
#	    fi
#	;;
#	esac
#    ;;
#    esac

  fi

}

######################################################################
#
# Test hdf5
#
######################################################################

testHdf5() {
  techo "Not testing hdf5."
}

# Move the static executables up to the bin dir
#
# 1: The bin directory
#
moveHdf5Tools() {
  if test -d $1/tools; then
    cmd="mv $1/tools/* $1"
    techo "$cmd"
    $cmd
  fi
}

# Fix the HDF5 liblib problem
#
# 1: The library installation directory
#
fixHdf5StaticLibs() {
  local libdir=$1

# Fix erroneous liblib library names
  local libs=`\ls $libdir/liblib* 2>/dev/null`
  if test -n "$libs"; then
    techo "Fixing liblib problem for hdf5-$HDF5_BLDRVERSION-$bld."
    for i in $libs; do
      case $HDF5_UNAME in
        CYGWIN*)
          local newname=`echo $i | sed -e 's?/liblib?/?' -e 's/\.a$/.lib/'`
          ;;
        *)
          local newname=`echo $i | sed -e 's?/liblib?/lib?'`
          ;;
      esac
      cmd="mv $i $newname"
      techo "$cmd"
      $cmd
    done
  else
    techo "liblib problem not present for hdf5-$HDF5_BLDRVERSION-$bld."
  fi

# Fix incorrect names on Windows
  if [[ $HDF5_UNAME =~ CYGWIN ]]; then
    local libs=`(cd $libdir; \ls lib*.a) 2>/dev/null`
    if test -n "$libs"; then
      techo "Fixing Windows library names for hdf5-$HDF5_BLDRVERSION-$bld."
      for i in $libs; do
        local newname=`echo $i | sed -e 's?^lib??' -e 's/\.a$/.lib/'`
        cmd="mv $libdir/$i $libdir/$newname"
        techo "$cmd"
        $cmd
      done
    else
      techo "Library names okay for hdf5-$HDF5_BLDRVERSION-$bld."
    fi
  fi

}

# Fix up hdf5 dylibs on Darwin. As of 1.8.8, the id of the dylibs has been
# changed to the compatibility version (7.2.0), rather than the actual version,
# and this requires copying two links into any distributions, which, e.g.,
# VisIT does not do, and so breaks the VisIt package.  This function
# restores the state that VisIt expects.
#
# First we change the ID on the library, then we change the references inside
# each library.
#
fixHdf5Dylibs() {
  techo "Checking to see whether hdf5 dylibs need fixing..."
  local ver=${HDF5_BLDRVERSION}
  if cd $CONTRIB_DIR/hdf5-${ver}-cc4py/lib; then
    for lib in lib*${ver}.dylib; do
      local liblink=`echo $lib | sed -e "s/${ver}\\.//"`
      ln -sf $lib $liblink
      id=`otool -D $lib | tail -r | head -1`
      if test $id != $lib; then
        techo "Fixing internal hdf5 library names for $lib."
# Create id with just file name, no rpath
        cmd="install_name_tool -id $lib $lib"
        techo "$cmd"
        $cmd
# Fix internal references to have correct version
        olibs=`otool -L $lib | grep -v : | sed -e 's/^[[:space:]]*//' -e 's/ (.*)//'`
        for olib in $olibs; do
          case $olib in
            libhdf5*${ver}.dylib) ;;
            libhdf5*.dylib)
              fixedLib=`echo $olib |\
                     sed "s?[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.dylib?${ver}.dylib?"`
              cmd="install_name_tool -change $olib $fixedLib $lib"
              techo "$cmd"
              $cmd
              ;;
          esac
        done
      else
        techo "$lib has correct id."
      fi
    done
    for lib in lib*${ver}.dylib; do
      if test $lib = libhdf5.${ver}.dylib; then
        continue
      fi
# Fix internal reference to libhdf5 to local directory
      olibs=`otool -L $lib | grep -v : | sed -e 's/^[[:space:]]*//' -e 's/ (.*)//'`
      for olib in $olibs; do
        if test $olib = libhdf5.${ver}.dylib; then
          cmd="install_name_tool -change $olib @rpath/$olib $lib"
          techo "$cmd"
          $cmd
        fi
      done
      cmd="install_name_tool -add_rpath @loader_path/ $lib"
      techo "$cmd"
      $cmd
    done
  fi
}

# We would like this to be the Linux equivalent of fixHdf5Dylibs,
# but we cannot make it work, as there is no way to change the
# soname of a shared library post construction.  Our only choice
# would be to relink.
#
fixHdf5SharedLibs() {
# JRC: This does not help, as the encoded soname is still 7.2.0
# Need another approach
if false; then
  local ver=${HDF5_BLDRVERSION}
  if cd $CONTRIB_DIR/hdf5-${ver}-$1/lib; then
    for lib in libhdf5*.so.${ver}; do
      local baselink=`basename $lib .${ver}`
      local linkedto=`readlink $baselink`
      local linkedto=`basename $linkedto`
      if test "$linkedto" != "$lib"; then
        techo "$baselink not directly linked to $lib.  Fixing."
        cmd="ln -sf $lib $baselink"
        techo "$cmd"
        $cmd
      else
        techo "$baselink is directly linked to $lib."
      fi
    done
    cd -
  fi
fi
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
  for bld in ser par; do
    if bilderInstall -r hdf5 $bld; then
      hdf5installed=true
      instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld
      chmod -R g+w $instdir
      case $HDF5_UNAME in
# We must move the static tools to the bin dir, or the hdf5 build system
# will remove them on the shared installation.
        CYGWIN*)
          moveHdf5Tools $instdir/bin
          fixHdf5StaticLibs $instdir/lib
          ;;
        Darwin)
          moveHdf5Tools $instdir/bin
          fixHdf5StaticLibs $instdir/lib
          local hdf5cmakefile=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bld/share/cmake/hdf5-${HDF5_BLDRVERSION}/hdf5-config.cmake
          if test -f $hdf5cmakefile; then
            sed -i.bak '/SET (BUILD_SHARED_LIBS /s/^/# /' $hdf5cmakefile
          fi
          ;;
        *)
          moveHdf5Tools $instdir/bin
          fixHdf5StaticLibs $instdir/lib
          ;;
      esac
    fi
  done

# Shared installations.  Leave tools in tools dir.
  for bld in sersh parsh; do
# Cannot remove old build, as this will remove static build,
# and the shared build does not have the tools
    if bilderInstall hdf5 $bld; then
      hdf5installed=true
      bldsfx=`basename $bld sh`
      instdir=$CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-$bldsfx
      case $HDF5_UNAME in
        Linux)  fixHdf5SharedLibs $bldsfx;;
      esac
    fi
  done

# cc4py is done on Unix/Mac only
  if bilderInstall -r hdf5 cc4py; then
    hdf5installed=true
    case $HDF5_UNAME in
      Darwin)
        fixHdf5Dylibs
        sed -i.bak '/SET (HDF5_BUILD_SHARED_LIBS /s/^/# /' $CONTRIB_DIR/hdf5-${HDF5_BLDRVERSION}-cc4py/share/cmake/hdf5/hdf5-config.cmake
        ;;
      Linux)  fixHdf5SharedLibs cc4py;;
    esac
  fi

# Then refind hdf5
  if $hdf5installed; then
    findContribPackage Hdf5 hdf5 ser par
    case $HDF5_UNAME in
      CYGWIN*)
        findContribPackage Hdf5 hdf5dll sersh parsh cc4py
        ;;
      *)
        findContribPackage Hdf5 hdf5 cc4py
        ;;
    esac
    findCc4pyDir Hdf5
  fi
  # techo "WARNING: Quitting at end of installHdf5."; cleanup

# alexanda: reverting back to 1.8.7, but leaving this section
#           in case we want to try 1.8.9 again
#  #
#  # Install specially built Mac binary tools
#  # cmake binary builds are broken for most(all?) versions
#  # > hdf5.1.8.7 on Mac. Using autotools build for h5dump/h5diff etc
#  #
#  case $HDF5_UNAME in
#    Darwin)
#      techo "Installing binaries from autotools build"
#      bilderInstall hdf5 binaries hdf5-binaries
#      ;;
#  esac

}
