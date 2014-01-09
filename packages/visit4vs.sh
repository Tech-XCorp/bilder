#!/bin/bash
#
# Version and build information for visit4vs.
#
# See http://portal.nersc.gov/svn/visit4vs/branches/txc/README
# for the branch usage for Composer.
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

VISIT4VS_BLDRVERSION=${VISIT4VS_BLDRVERSION:-"2.6.0b"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# VisIt is built the way python is built.
if test -z "$VISIT4VS_DESIRED_BUILDS"; then
  VISIT4VS_DESIRED_BUILDS=$FORPYTHON_BUILD
  if isCcCc4py; then
    if ! [[ `uname` =~ CYGWIN ]] && $BUILD_OPTIONAL; then
      VISIT4VS_DESIRED_BUILDS=$VISIT4VS_DESIRED_BUILDS,parsh
    fi
  fi
fi
computeBuilds visit4vs
VISIT4VS_SER_BUILD=$FORPYTHON_BUILD
VISIT4VS_DEPS=Imaging,hdf5,VTK,qt,cmake
VISIT4VS_UMASK=002

######################################################################
#
# Get the visit4vs architecture variable
#
######################################################################

getVisit4vsArch() {

# jrc 20apr10: I think the following works? If you change, please leave a note.
  local os=`uname | tr '[A-Z]' '[a-z]'`
  local mach=`uname -m`

# It is not just uname -m, so need to fix this up.
  case $os in
    darwin)
      case $mach in
        Power*) mach=ppc;;
        *)
          case `uname -r` in
            1*) mach=x86_64;; # This is what VisIt does in CMake
          esac
          ;;
      esac
      ;;
    linux)
      case $mach in
        i[3-6]86) mach=intel;;
      esac
      ;;
  esac

  local visit4vs_arch="$os-$mach"
  case `uname`  in
    CYGWIN*) visit4vs_arch=;;
# arch not used for cygwin
  esac

# Done
  echo $visit4vs_arch

}

######################################################################
#
# Launch builds.
#
######################################################################

buildVisit4vs() {

# Check for svn repo or package
  if test -d $PROJECT_DIR/visit4vs; then
# Package: so patch and preconfig

# Revert to undo previous patch.
    bilderSvn revert --recursive $PROJECT_DIR/visit4vs
    VISIT4VS_DISTVERSION=`cat $PROJECT_DIR/visit4vs/VERSION`
    getVersion visit4vs
    techo "After reverting, VISIT4VS_BLDRVERSION = $VISIT4VS_BLDRVERSION."

# Determine whether patch in installation matches that in bilder.
# If differs, set visit4vs as uninstalled so it will be built.
    VISIT4VS_PATCH=$BILDER_DIR/patches/visit4vs.patch
    if ! isPatched -s visit4vs-$VISIT4VS_SER_BUILD visit4vs-$VISIT4VS_BLDRVERSION-$VISIT4VS_SER_BUILD; then
      techo "Rebuilding visit4vs as patches differ."
      for bld in `echo $VISIT4VS_BUILDS | tr ',' ' '`; do
        cmd="$BILDER_DIR/setinstald.sh -r -i $BLDR_INSTALL_DIR visit4vs,$bld"
        $cmd 2>&1 | tee -a $LOGFILE
      done
    else
      techo "Patch up to date.  Not a reason to rebuild."
    fi

# Patch visit4vs
# Generate the patch via svn diff visit4vs >numpkgs/visit4vs-${branch}-${lbl}.patch
    if test -n "$VISIT4VS_PATCH" -a -f "$VISIT4VS_PATCH"; then
      cmd="(cd $PROJECT_DIR; patch -p0 <$VISIT4VS_PATCH >$BUILD_DIR/visit4vs-patch.txt 2>&1)"
      techo "$cmd"
      eval "$cmd"
      techo "VisIt patched. Results in $BUILD_DIR/visit4vs-patch.txt."
      if grep -qi fail $BUILD_DIR/visit4vs-patch.txt; then
        grep -i fail $BUILD_DIR/visit4vs-patch.txt | sed 's/^/WARNING: /' >$BUILD_DIR/visit4vs-patch.fail
        cat $BUILD_DIR/visit4vs-patch.fail | tee -a $LOGFILE
      fi
    fi
    if ! bilderPreconfig -c visit4vs; then
      return 1
    fi
  else
    if ! bilderUnpack visit4vs; then
      return 1
    fi
  fi

# Configure and build
  local VISIT4VS_ARCH=`getVisit4vsArch`

# Args for make and environment, and configuration file
  local VISIT4VS_MAKEARGS=       # This to be set as needed, since can fail
  local VISIT4VS_ENV=
  local VISIT4VS_MESA_DIR=
  case `uname` in
    CYGWIN*)
      if which jom 1>/dev/null 2>/dev/null; then
        VISIT4VS_MAKEARGS="$VISIT4VS_MAKEJ_ARGS"
      fi
# Remove cygwin paths when configuring
      PATH_CYGWIN_LAST=`echo :$PATH: | sed -e 's?:/usr/bin:?:?' -e 's?:/bin:?:?'`:/usr/bin
      VISIT4VS_ENV="PATH='$PATH_CYGWIN_LAST'"
      ;;
    Darwin)
      VISIT4VS_MAKEARGS="$VISIT4VS_MAKEJ_ARGS"
      if ! $IS_VISIT4VS_TRUNK && test -d $CONTRIB_DIR/mesa/lib; then
        VISIT4VS_MESA_DIR=$CONTRIB_DIR/mesa
      fi
      ;;
    Linux)
      VISIT4VS_MAKEARGS="$VISIT4VS_MAKEJ_ARGS"
      local VISIT4VS_LD_RUN_PATH=$PYC_LD_RUN_PATH:$LD_RUN_PATH
      VISIT4VS_ENV="LD_RUN_PATH=$VISIT4VS_LD_RUN_PATH"
      # if test -d $CONTRIB_DIR/mesa/lib; then
        # VISIT4VS_MESA_DIR=$CONTRIB_DIR/mesa
      # fi
      ;;
  esac

#
# VisIt needs to find hdf5 netcdf Python Qt VTK
#
# Set unix style directories
  VISIT4VS_HDF5_DIR="$HDF5_CC4PY_DIR"
  local VISIT4VS_NETCDF_DIR=
  if test -d $CONTRIB_DIR/netcdf/lib; then
    VISIT4VS_NETCDF_DIR=$CONTRIB_DIR/netcdf
  fi
  local VISIT4VS_PYTHON_DIR="$PYTHON_DIR"
# Find location of QT in unix file system
  findQt
# Find Vtk
  local VISIT4VS_VTK_DIR=$CONTRIB_DIR/VTK-$FORPYTHON_BUILD
  techo "VISIT4VS_VTK_DIR = $VISIT4VS_VTK_DIR."

# Get mixed (CYGWIN) or native (OTHER) paths.
# VISIT4VS_PYTHON_DIR is already mixed.
  VISIT4VS_QT_BIN="$QT_BINDIR"
  for i in VISIT4VS_HDF5_DIR VISIT4VS_NETCDF_DIR VISIT4VS_QT_BIN VISIT4VS_VTK_DIR; do
    local val=`deref $i`
    if test -n "$val"; then
      val=`(cd $val; pwd -P)`
      # eval UNIX_${i}_REAL="$val"
      if [[ `uname` =~ CYGWIN ]]; then
        val=`cygpath -am $val`
      fi
      eval $i="$val"
    fi
    techo "$i = $val"
  done

# Set cmake args for packages
  local VISIT4VS_QT_ARGS="-DVISIT4VS_QT_BIN:PATH=$VISIT4VS_QT_BIN"
  local VISIT4VS_PKG_ARGS="$VISIT4VS_QT_ARGS"
  for i in HDF5 NETCDF PYTHON VTK; do
    local var=VISIT4VS_${i}_DIR
    local val=`deref ${var}`
    if test -n "$val"; then
      local argval="-DVISIT4VS_${i}_DIR:PATH=$val"
      eval VISIT4VS_${i}_ARGS="$argval"
      VISIT4VS_PKG_ARGS="$VISIT4VS_PKG_ARGS $argval"
    fi
  done
# hdf5 remove dll from library names as of 1.8.11
  if [[ `uname` =~ CYGWIN ]]; then
    case $HDF5_BLDRVERSION in
      1.8.1[1-9])
        VISIT4VS_PKG_ARGS="$VISIT4VS_PKG_ARGS -DHDF5_LIBNAMES_AFFIX_DLL:BOOL=OFF"
        ;;
    esac
  fi
  techo "VISIT4VS_PKG_ARGS = $VISIT4VS_PKG_ARGS."

  local VISIT4VS_OS_ARGS=
  case `uname` in

    CYGWIN*) VISIT4VS_OS_ARGS="-DVISIT4VS_CONFIG_SITE:FILEPATH=`cygpath -am $PROJECT_DIR/visit4vs/config-site/windows-bilder.cmake`";;

# Brad Whitlock writes (April 17, 9:58, 2012)
#   All I\'ve ever had to pass is VISIT4VS_PYTHON_DIR. The intent is that you
#   should only have to set VISIT4VS_PYTHON_DIR.
# But it appears that on snowleopard with need to add the library dir?
    Darwin) VISIT4VS_OS_ARGS="-DPYTHON_LIBRARY:FILEPATH=$PYTHON_SHLIB";;

  esac

# Build serial
  if bilderConfig -c visit4vs $VISIT4VS_SER_BUILD "-DIGNORE_THIRD_PARTY_LIB_PROBLEMS:BOOL=ON -DVISIT4VS_INSTALL_THIRD_PARTY:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $VISIT4VS_PKG_ARGS $VISIT4VS_OS_ARGS $VISIT4VS_SERSH_OTHER_ARGS" "" "$VISIT4VS_ENV"; then
    bilderBuild visit4vs $VISIT4VS_SER_BUILD "$VISIT4VS_MAKEARGS" "$VISIT4VS_ENV"
  fi

# Build parallel doing optional builds
  if bilderConfig -c visit4vs parsh "-DVISIT4VS_PARALLEL:BOOL=ON -DVISIT4VS_MPI_COMPILER='$MPICXX' -DVISIT4VS_MPI_LIBS:PATH=$MPI_LIBDIR -DIGNORE_THIRD_PARTY_LIB_PROBLEMS:BOOL=ON -DVISIT4VS_INSTALL_THIRD_PARTY:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $VISIT4VS_PKG_ARGS $VISIT4VS_OS_ARGS $VISIT4VS_PARSH_OTHER_ARGS" "" "$VISIT4VS_ENV"; then

# Find the mpi c++ library
    local MPI_LIBDIR
    if ! [[ `uname` =~ CYGWIN ]]; then
      for i in `$MPICXX -show`; do
        case $i in
          -L*)
            local libdir=`echo $i | sed 's/^-L//'`
            for sfx in a so dylib; do
              if test -f $libdir/libmpi_cxx.$sfx -o -f $libdir/libmpichcxx.$sfx; then
                MPI_LIBDIR=$libdir
                break
              fi
            done
            ;;
        esac
        if test -n "$MPI_LIBDIR"; then
          break
        fi
      done
      techo -2 "MPI_LIBDIR = $MPI_LIBDIR."
      if test -z "$MPI_LIBDIR"; then
        techo "WARNING: Cannot find the mpi library directory, so linking may fail."
      fi
    fi
# Visit4vs uses serial hdf5 even in parallel.
    bilderBuild visit4vs parsh "$VISIT4VS_MAKEARGS" "$VISIT4VS_ENV"
  fi

}

######################################################################
#
# Test
#
######################################################################

testVisit4vs() {
  techo "Not testing visit4vs."
}

######################################################################
#
# Fix up hdf5 libraries that are copied
#
# Args
# 1: Where (unix/cygwin path) the libraries need to be installed
# 2: Root directory (unix/cygwin path) of hdf5 installation
# 3: File for redirecting any extensive output
#
######################################################################

fixCopiedHdf5() {

  local instdir=$1
  local hdf5rootdir=$2
  local installfixfile=$3

  case `uname` in

    CYGWIN*)
      if test -f $instdir/hdf5dll.dll; then
        techo "VisIt correctly installed $instdir/hdf5dll.dll."
        return
      elif test -f $instdir/hdf5.dll; then
        techo "VisIt correctly installed $instdir/hdf5.dll."
        return
      fi
      techo "NOTE: VisIt did not install $instdir/hdf5dll.dll or $instdir/hdf5.dll.  Copying from $hdf5rootdir."
      local cmd=
# This is what hdf5-1.8.11 needs
      if test -f $hdf5rootdir/bin/hdf5.dll; then
        cmd="cp $hdf5rootdir/bin/hdf5.dll $instdir/"
      elif test -f $hdf5rootdir/bin/hdf5dll.dll; then
        cmd="cp $hdf5rootdir/bin/hdf5dll.dll $instdir/"
      elif test -f $hdf5rootdir/dll/hdf5dll.dll; then
        techo "$hdf5rootdir/bin/hdf5dll.dll not present."
        cmd="cp $hdf5rootdir/dll/hdf5dll.dll $instdir/"
      else
        techo "Catastrophic error.  Neither hdf5dll.dll nor hdf5.dll found under $hdf5rootdir."
        techo "Quitting."
        exit 1
      fi
      techo "$cmd"
      eval "$cmd"
      ;;

    Darwin)
# If link to install name of hdf5 not installed, make link
      local hdf5libbase=libhdf5.${HDF5_BLDRVERSION}.dylib
      local hdf5libname=$instdir/$hdf5libbase
      if ! test -f $hdf5libname; then
        techo "ERROR: $hdf5libname missing."
        return
      fi
      techo "Extracting compatibility name from $hdf5libname."
      local hdf5shlink=`otool -D $hdf5libname | tail -1`
      if test -f $instdir/$hdf5shlink; then
        techo "VisIt correctly created $instdir/$hdf5shlink link."
        return
      fi
      techo "NOTE: $hdf5shlink link absent in $instdir.  Creating."
      cmd="(cd $instdir; ln -s $hdf5libbase $hdf5shlink)"
      techo "$cmd"
      eval "$cmd"
      ;;

    Linux)
# If link to soname of hdf5 not installed, make link
# JRC: still necessary as of visit4vs-r19672
      local hdf5libbase=libhdf5.so.${HDF5_BLDRVERSION}
      local hdf5libname=$instdir/$hdf5libbase
      if ! test -f $hdf5libname; then
        techo "ERROR: $hdf5libname missing."
        return
      fi
      techo "Extracting soname from $hdf5libname."
      local hdf5soname=`objdump -p $hdf5libname | grep SONAME | sed -e 's/ *SONAME *//'`
      if test -f $instdir/$hdf5soname; then
        techo "VisIt correctly created $instdir/$hdf5soname link."
        return
      fi
      techo "NOTE: $hdf5soname link absent in $instdir.  Creating."
      cmd="(cd $instdir; ln -s $hdf5libbase $hdf5soname)"
      techo "$cmd"
      eval "$cmd"
      ;;

  esac

}

######################################################################
#
# Install
#
######################################################################

installVisit4vs() {

# Store and modify umask
  local umasksav=`umask`
  umask $VISIT4VS_UMASK

# Install serial and parallel
  for bld in `echo $VISIT4VS_BUILDS | tr ',' ' '`; do

    sfx="-$bld"

# Install
    if bilderInstall -r visit4vs $bld; then

# Visit4vs variables
      local VISIT4VS_ARCH=`getVisit4vsArch`
      techo "VISIT4VS_DISTVERSION = $VISIT4VS_DISTVERSION"
      local visit4vs_uscrversion=`echo $VISIT4VS_DISTVERSION | sed 's/\./_/g'`

# File to contain installation fixes
      local installfixfile=$BUILD_DIR/visit4vs/$bld/installfix.out
      rm -f $installfixfile
      touch $installfixfile

# For reuse
      local visit4vstopdir=$BLDR_INSTALL_DIR/visit4vs-${VISIT4VS_BLDRVERSION}-$bld

# Link to current if not done.  Darwin docs say to change -h to -L.
      if ! [[ `uname` =~ CYGWIN ]]; then
        if test -L $visit4vstopdir/current; then
          techo "VisIt correctly created $visit4vstopdir/current link."
        else
          techo "NOTE: current link absent in $visit4vstopdir.  Creating." | tee -a $installfixfile
          cmd="(cd $visit4vstopdir; ln -s $VISIT4VS_DISTVERSION current)"
          techo "$cmd" >>$installfixfile
          eval "$cmd"
        fi
      fi

# If parallel-Linux, pull in the mpi libraries
      if test $bld = par; then

# Determine mpi libs
        local VISIT4VS_MPI_STUFF=`$MPICXX -show`
        local VISIT4VS_MPI_LIBDIRS=
        local VISIT4VS_MPI_LIBS=

# Find names of libraries and libdir
        for i in $VISIT4VS_MPI_STUFF; do
          case $i in
            -L*)
              libdir=`echo $i | sed -e 's/^-L//'`
              VISIT4VS_MPI_LIBDIRS="$VISIT4VS_MPI_LIBDIRS $libdir"
              ;;
            -l*)
              libname=`echo $i | sed -e 's/^-l/lib/' -e "s/\$/${SHOBJEXT}/"`
              VISIT4VS_MPI_LIBS="$VISIT4VS_MPI_LIBS $libname ${libname}.0"
              ;;
          esac
        done

# Absolute paths to mpi libraries
        local VISIT4VS_MPI_ABSLIBS
        unset VISIT4VS_MPI_ABSLIBS
        for i in $VISIT4VS_MPI_LIBDIRS; do
          for j in $VISIT4VS_MPI_LIBS; do
            if test -f $i/$j; then
              VISIT4VS_MPI_ABSLIBS="$VISIT4VS_MPI_ABSLIBS $i/$j"
              continue
            fi
          done
        done
        techo "VISIT4VS_MPI_ABSLIBS = $VISIT4VS_MPI_ABSLIBS"

# Link into the libdir
        for libdir in $visit4vstopdir/$VISIT4VS_DISTVERSION/$VISIT4VS_ARCH/lib $BUILD_DIR/visit4vs/par/lib; do
          local mpilinked=
          for i in $VISIT4VS_MPI_ABSLIBS; do
            local libname=`basename $i`
            if test ! -h $libdir/$libname -a ! -f $libdir/$libname; then
              mpilinked="$mpilinked $libname"
              cmd="ln -s $i $libdir/$libname"
              echo "$cmd" >>$installfixfile
              $cmd
            fi
          done
          if test -n "$mpilinked"; then
            trimvar mpilinked ' '
            techo "# NOTE: Had to link the following MPI libraries into $libdir: $mpilinked." | tee -a $installfixfile
          else
            techo "# NOTE: Did not have to link any MPI libraries into $libdir." | tee -a $installfixfile
          fi
        done

# Copy the parallel engine into the installation directory
        parlib=$visit4vstopdir/$VISIT4VS_DISTVERSION/$VISIT4VS_ARCH/lib/libengine_par${SHOBJEXT}
        if ! test -f $parlib; then
          techo "# NOTE: Installing lib, $parlib."
          cmd="install -m 775 $BUILD_DIR/visit4vs/par/lib/libengine_par${SHOBJEXT} $parlib"
          techo "$cmd" | tee -a $installfixfile
          $cmd
        else
          techo "# NOTE: VisIt correctly installed lib, $parlib."
        fi

      fi

# Fix installation libraries
# Fix hdf5
      local hdf5dirs=
      if [[ $bld =~ ^ser ]]; then
        hdf5dirs="hdf5-cc4py hdf5-sersh hdf5"
      else
        hdf5dirs="hdf5-parsh"
      fi
      local hdf5rootdir=
      for hdf5dir in $hdf5dirs; do
        if test -d $CONTRIB_DIR/$hdf5dir/lib; then
          hdf5rootdir=`(cd $CONTRIB_DIR/$hdf5dir; pwd -P)`
          break
        fi
      done
      if test -z $hdf5rootdir; then
        techo "WARNING: Shared hdf5 libs not found for build, $bld!"
      elif [[ `uname` =~ CYGWIN ]]; then
# Installation directly into root dir.  Have to look for hdf5 at top.
        fixCopiedHdf5 $visit4vstopdir $hdf5rootdir $installfixfile
      else
        fixCopiedHdf5 $visit4vstopdir/$VISIT4VS_DISTVERSION/$VISIT4VS_ARCH/lib $hdf5rootdir/lib $installfixfile
      fi

# Look for stdc++
      if test `uname` = Linux; then
        local cxxstdlib=`(cd $visit4vstopdir/$VISIT4VS_DISTVERSION/$VISIT4VS_ARCH/lib; ls libstdc++.so*) 2>/dev/null`
        if test -z "$cxxstdlib"; then
          techo "NOTE: libstdc++.so missing in $visit4vstopdir/$VISIT4VS_DISTVERSION/$VISIT4VS_ARCH/lib.  May need to set LD_LIBRARY_PATH."
        fi
      fi

# Packaging only if creating a release
      if $IS_VISIT4VS_TRUNK && $BUILD_INSTALLERS; then
        runnrExec "cd $BUILD_DIR/visit4vs/$bld"
        case `uname` in
          CYGWIN*) cmd="nmake package";;
          *) cmd="make package";;
        esac
        techo "$cmd" | tee package.out
        $cmd 1>>package.out 2>&1
      fi

      techo "Post installation of visit4vs-${VISIT4VS_BLDRVERSION}-$bld concluded at `date`."
      local starttimeval=$VISIT4VS_START_TIME
      local endtimeval=`date +%s`
      local buildtime=`expr $endtimeval - $starttimeval`
      techo "visit4vs-$bld took `myTime $buildtime` to build, install, and package."
    fi

  done

# Restore umask
  umask $umasksav

}

