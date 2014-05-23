#!/bin/bash
#
# Build information for visit
#
# See http://portal.nersc.gov/svn/visit/branches/txc/README
# for the branch usage for Composer.
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in visit_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/visit_aux.sh

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setVisItNonTriggerVars() {
  VISIT_UMASK=002
  VISIT_TESTING=${VISIT_TESTING:-"${TESTING_BUILDS}"}
  $VISIT_TESTING && VISIT_CTEST_TARGET=${VISIT_CTEST_TARGET:-"$BILDER_CTEST_TARGET"}
}
setVisItNonTriggerVars

######################################################################
#
# Get the visit architecture variable
#
######################################################################

getVisitArch() {

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

  local visit_arch="$os-$mach"
  case `uname`  in
    CYGWIN*) visit_arch=;;
# arch not used for cygwin
  esac

# Done
  echo $visit_arch

}

######################################################################
#
# Launch builds.
#
######################################################################

buildVisit() {

# Check for svn repo or package
  if test -d $PROJECT_DIR/visit; then
# Package: so patch and preconfig

# Revert to undo previous patch.
    bilderSvn revert --recursive $PROJECT_DIR/visit
    VISIT_DISTVERSION=`cat $PROJECT_DIR/visit/VERSION`
    getVersion visit
    techo "After reverting, VISIT_BLDRVERSION = $VISIT_BLDRVERSION."

# Determine whether patch in installation matches that in bilder.
# If differs, set visit as uninstalled so it will be built.
    VISIT_PATCH=$BILDER_DIR/patches/visit.patch
    if ! isPatched -s visit-$VISIT_SER_BUILD visit-$VISIT_BLDRVERSION-$VISIT_SER_BUILD; then
      techo "Rebuilding visit as patches differ."
      for bld in `echo $VISIT_BUILDS | tr ',' ' '`; do
        cmd="$BILDER_DIR/setinstald.sh -r -i $BLDR_INSTALL_DIR visit,$bld"
        $cmd 2>&1 | tee -a $LOGFILE
      done
    else
      techo "Patch up to date.  Not a reason to rebuild."
    fi

# Patch visit
# Generate the patch via svn diff visit >numpkgs/visit-${branch}-${lbl}.patch
    if test -n "$VISIT_PATCH" -a -f "$VISIT_PATCH"; then
      cmd="(cd $PROJECT_DIR; $BILDER_DIR/patch.sh $VISIT_PATCH >$BUILD_DIR/visit-patch.txt 2>&1)"
      techo "$cmd"
      eval "$cmd"
      techo "VisIt patched. Results in $BUILD_DIR/visit-patch.txt."
      if grep -qi fail $BUILD_DIR/visit-patch.txt; then
        grep -i fail $BUILD_DIR/visit-patch.txt | sed 's/^/WARNING: /' >$BUILD_DIR/visit-patch.fail
        cat $BUILD_DIR/visit-patch.fail | tee -a $LOGFILE
      fi
    fi
    if ! bilderPreconfig -c visit; then
      return 1
    fi
  else
    if ! bilderUnpack visit; then
      return 1
    fi
  fi

# Configure and build
  local VISIT_ARCH=`getVisitArch`

# Args for make and environment, and configuration file
  local VISIT_MAKE_ARGS=
  local VISIT_ADDL_ARGS=
  local VISIT_ENV=
  local VISIT_MESA_DIR=
  case `uname` in
    CYGWIN*)
      if which jom 1>/dev/null 2>/dev/null; then
        VISIT_MAKE_ARGS="$VISIT_MAKEJ_ARGS"
      fi
# Remove cygwin paths when configuring
      PATH_CYGWIN_LAST=`echo :$PATH: | sed -e 's?:/usr/bin:?:?' -e 's?:/bin:?:?'`:/usr/bin
      VISIT_ENV="PATH='$PATH_CYGWIN_LAST'"
      ;;
    Darwin)
      VISIT_MAKE_ARGS="$VISIT_MAKEJ_ARGS"
      if ! $IS_VISIT_TRUNK && test -d $CONTRIB_DIR/mesa/lib; then
        VISIT_MESA_DIR=$CONTRIB_DIR/mesa
      fi
      ;;
    Linux)
      VISIT_MAKE_ARGS="$VISIT_MAKEJ_ARGS"
      local VISIT_LD_RUN_PATH=$PYC_LD_RUN_PATH:$LD_RUN_PATH
      VISIT_ENV="LD_RUN_PATH=$VISIT_LD_RUN_PATH"
      ;;
  esac
  if test -n "$VISIT_CTEST_TARGET"; then
    VISIT_ADDL_ARGS="-DBUILD_TESTING:BOOL=ON -DVISIT_TEST_DIR:PATH=$PROJECT_DIR/visittest/test -DCTEST_BUILD_FLAGS:STRING='$VISIT_MAKE_ARGS'"
    VISIT_MAKE_ARGS="${VISIT_CTEST_TARGET}Start ${VISIT_CTEST_TARGET}Build"
  fi

#
# VisIt needs to find hdf5 netcdf Python Qt VTK
#
# Set unix style directories
  local VISIT_HDF5_DIR="$HDF5_CC4PY_DIR"
  local VISIT_NETCDF_DIR="$NETCDF_CC4PY_DIR"
  local VISIT_PYTHON_DIR="$PYTHON_DIR"
# Find Vtk
  local VISIT_VTK_DIR=$CONTRIB_DIR/VTK-$FORPYTHON_BUILD
  techo "VISIT_VTK_DIR = $VISIT_VTK_DIR."
# Get mixed (CYGWIN) or native (OTHER) paths.
# VISIT_PYTHON_DIR is already mixed.
  if test -z "$QT_BINDIR"; then
    source $BILDER_DIR/packages/qt_aux.sh
    findQt
  fi
  VISIT_QT_BIN="$QT_BINDIR"
  for i in VISIT_HDF5_DIR VISIT_NETCDF_DIR VISIT_QT_BIN VISIT_VTK_DIR; do
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
  local VISIT_QT_ARGS="-DVISIT_QT_BIN:PATH=$VISIT_QT_BIN"
  local VISIT_PKG_ARGS="$VISIT_QT_ARGS"
  for i in HDF5 NETCDF PYTHON VTK; do
    local var=VISIT_${i}_DIR
    local val=`deref ${var}`
    if test -n "$val"; then
      local argval="-DVISIT_${i}_DIR:PATH=$val"
      eval VISIT_${i}_ARGS="$argval"
      VISIT_PKG_ARGS="$VISIT_PKG_ARGS $argval"
    fi
  done
# hdf5 remove dll from library names as of 1.8.11
  if [[ `uname` =~ CYGWIN ]]; then
    case $HDF5_BLDRVERSION in
      1.8.1[1-9])
        VISIT_PKG_ARGS="$VISIT_PKG_ARGS -DHDF5_LIBNAMES_AFFIX_DLL:BOOL=OFF"
        ;;
    esac
  fi
  techo "VISIT_PKG_ARGS = $VISIT_PKG_ARGS."

  local VISIT_OS_ARGS=
  case `uname` in

    CYGWIN*) VISIT_OS_ARGS="-DVISIT_CONFIG_SITE:FILEPATH=`cygpath -am $PROJECT_DIR/visit/config-site/windows-bilder.cmake`";;

# Brad Whitlock writes (April 17, 9:58, 2012)
#   All I\'ve ever had to pass is VISIT_PYTHON_DIR. The intent is that you
#   should only have to set VISIT_PYTHON_DIR.
# But it appears that on snowleopard with need to add the library dir?
    Darwin) VISIT_OS_ARGS="-DPYTHON_LIBRARY:FILEPATH=$PYTHON_SHLIB";;

  esac

# Build serial
  if bilderConfig -c visit $VISIT_SER_BUILD "-DIGNORE_THIRD_PARTY_LIB_PROBLEMS:BOOL=ON -DVISIT_INSTALL_THIRD_PARTY:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $VISIT_PKG_ARGS $VISIT_OS_ARGS $VISIT_ADDL_ARGS $VISIT_SERSH_OTHER_ARGS" "" "$VISIT_ENV"; then
    bilderBuild visit $VISIT_SER_BUILD "$VISIT_MAKE_ARGS" "$VISIT_ENV"
  fi

# Build parallel doing optional builds
  if bilderConfig -c visit parsh "-DVISIT_PARALLEL:BOOL=ON -DVISIT_MPI_COMPILER='$MPICXX' -DVISIT_MPI_LIBS:PATH=$MPI_LIBDIR -DIGNORE_THIRD_PARTY_LIB_PROBLEMS:BOOL=ON -DVISIT_INSTALL_THIRD_PARTY:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $VISIT_PKG_ARGS $VISIT_OS_ARGS $VISIT_ADDL_ARGS $VISIT_PARSH_OTHER_ARGS" "" "$VISIT_ENV"; then

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
        techo "WARNING: [$FUNCNAME] Cannot find the mpi library directory, so linking may fail."
      fi
    fi
# Visit uses serial hdf5 even in parallel.
    bilderBuild visit parsh "$VISIT_MAKE_ARGS" "$VISIT_ENV"
  fi

}

######################################################################
#
# Test
#
######################################################################

testVisit() {
  bilderRunTests -s visit ""
}

######################################################################
#
# Installation helpers
#
######################################################################

#
# Fix up hdf5 libraries that are copied
#
# Args
# 1: Where (unix/cygwin path) the libraries need to be installed
# 2: Root directory (unix/cygwin path) of hdf5 installation
# 3: File for redirecting any extensive output
#
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

    Darwin | Linux)
      if test `uname` = Darwin; then
        hdf5shdir=$HDF5_CC4PY_DIR/lib
        hdf5shlib=libhdf5.${HDF5_BLDRVERSION}.dylib
      else
        hdf5shdir=$HDF5_CC4PY_DIR/lib
        hdf5shlib=libhdf5.so.${HDF5_BLDRVERSION}
      fi
      installRelShlib $hdf5shlib $instdir $hdf5shdir
      ;;

  esac

}

######################################################################
#
# Install
#
######################################################################

installVisit() {

# Store and modify umask
  local umasksav=`umask`
  umask $VISIT_UMASK

# Install serial and parallel
  for bld in `echo $VISIT_BUILDS | tr ',' ' '`; do

    sfx="-$bld"

# Install
    if bilderInstall -r visit $bld; then

# Visit variables
      local VISIT_ARCH=`getVisitArch`
      techo "VISIT_DISTVERSION = $VISIT_DISTVERSION"
      local visit_uscrversion=`echo $VISIT_DISTVERSION | sed 's/\./_/g'`

# File to contain installation fixes
      local installfixfile=$BUILD_DIR/visit/$bld/installfix.out
      rm -f $installfixfile
      touch $installfixfile

# For reuse
      local visittopdir=$BLDR_INSTALL_DIR/visit-${VISIT_BLDRVERSION}-$bld

# Link to current if not done.  Darwin docs say to change -h to -L.
      if ! [[ `uname` =~ CYGWIN ]]; then
        if test -L $visittopdir/current; then
          techo "VisIt correctly created $visittopdir/current link."
        else
          techo "NOTE: current link absent in $visittopdir.  Creating." | tee -a $installfixfile
          # cmd="(cd $visittopdir; ln -s $VISIT_DISTVERSION current)"
          techo "$cmd" >>$installfixfile
          eval "$cmd"
        fi
      fi

# If parallel-Linux, pull in the mpi libraries
      if test $bld = par; then

# Determine mpi libs
        local VISIT_MPI_STUFF=`$MPICXX -show`
        local VISIT_MPI_LIBDIRS=
        local VISIT_MPI_LIBS=

# Find names of libraries and libdir
        for i in $VISIT_MPI_STUFF; do
          case $i in
            -L*)
              libdir=`echo $i | sed -e 's/^-L//'`
              VISIT_MPI_LIBDIRS="$VISIT_MPI_LIBDIRS $libdir"
              ;;
            -l*)
              libname=`echo $i | sed -e 's/^-l/lib/' -e "s/\$/${SHOBJEXT}/"`
              VISIT_MPI_LIBS="$VISIT_MPI_LIBS $libname ${libname}.0"
              ;;
          esac
        done

# Absolute paths to mpi libraries
        local VISIT_MPI_ABSLIBS
        unset VISIT_MPI_ABSLIBS
        for i in $VISIT_MPI_LIBDIRS; do
          for j in $VISIT_MPI_LIBS; do
            if test -f $i/$j; then
              VISIT_MPI_ABSLIBS="$VISIT_MPI_ABSLIBS $i/$j"
              continue
            fi
          done
        done
        techo "VISIT_MPI_ABSLIBS = $VISIT_MPI_ABSLIBS"

# Link into the libdir
        for libdir in $visittopdir/$VISIT_DISTVERSION/$VISIT_ARCH/lib $BUILD_DIR/visit/par/lib; do
          local mpilinked=
          for i in $VISIT_MPI_ABSLIBS; do
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
        parlib=$visittopdir/$VISIT_DISTVERSION/$VISIT_ARCH/lib/libengine_par${SHOBJEXT}
        if ! test -f $parlib; then
          techo "# NOTE: Installing lib, $parlib."
          cmd="install -m 775 $BUILD_DIR/visit/par/lib/libengine_par${SHOBJEXT} $parlib"
          techo "$cmd" | tee -a $installfixfile
          $cmd
        else
          techo "# NOTE: VisIt correctly installed lib, $parlib."
        fi

      fi

# Fix installation libraries
# Even parallel visit uses serial hdf5
      local hdf5dirs="hdf5-cc4py hdf5-sersh hdf5"
      local hdf5rootdir=
      for hdf5dir in $hdf5dirs; do
        if test -d $CONTRIB_DIR/$hdf5dir/lib; then
          hdf5rootdir=`(cd $CONTRIB_DIR/$hdf5dir; pwd -P)`
          break
        fi
      done
      if test -z "$hdf5rootdir"; then
        techo "WARNING: [$FUNCNAME] Shared hdf5 libs not found for build, $bld!"
      fi
      if [[ `uname` =~ CYGWIN ]]; then
# Installation directly into root dir.  Have to look for hdf5 at top.
        fixCopiedHdf5 $visittopdir "$hdf5rootdir" $installfixfile
      else
        fixCopiedHdf5 $visittopdir/$VISIT_DISTVERSION/$VISIT_ARCH/lib "$hdf5rootdir/lib" $installfixfile
      fi

# Look for stdc++
      if test `uname` = Linux; then
        local cxxstdlib=`(cd $visittopdir/$VISIT_DISTVERSION/$VISIT_ARCH/lib; ls libstdc++.so*) 2>/dev/null`
        if test -z "$cxxstdlib"; then
          techo "NOTE: libstdc++.so missing in $visittopdir/$VISIT_DISTVERSION/$VISIT_ARCH/lib.  May need to set LD_LIBRARY_PATH."
        fi
      fi

# Packaging only if creating a release
      if $IS_VISIT_TRUNK && $BUILD_INSTALLERS; then
        runnrExec "cd $BUILD_DIR/visit/$bld"
        case `uname` in
          CYGWIN*) cmd="nmake package";;
          *) cmd="make package";;
        esac
        techo "$cmd" | tee package.out
        $cmd 1>>package.out 2>&1
      fi

      techo "Post installation of visit-${VISIT_BLDRVERSION}-$bld concluded at `date`."
      local starttimeval=$VISIT_START_TIME
      local endtimeval=`date +%s`
      local buildtime=`expr $endtimeval - $starttimeval`
      techo "visit-$bld took `myTime $buildtime` to build, install, and package."
    fi

  done

# Restore umask
  umask $umasksav

}

