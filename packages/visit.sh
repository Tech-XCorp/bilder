#!/bin/bash
#
# Version and build information for visit.
#
# See http://portal.nersc.gov/svn/visit/branches/txc/README
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

VISIT_BLDRVERSION=${VISIT_BLDRVERSION:-"2.6.0b"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$VISIT_DESIRED_BUILDS"; then
  VISIT_DESIRED_BUILDS=sersh
  if ! [[ `uname` =~ CYGWIN ]] && $BUILD_OPTIONAL; then
    VISIT_DESIRED_BUILDS=$VISIT_DESIRED_BUILDS,parsh
  fi
fi
computeBuilds visit

VISIT_DEPS=Imaging,hdf5,visit_vtk,qt,cmake
VISIT_UMASK=002

addtopathvar PATH $BLDR_INSTALL_DIR/visit2/bin

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

setVisitRepoPatch() {

# Look for predefined patch
  if test -n "$VISIT_PATCH" -a ! -f "$VISIT_PATCH"; then
    techo "$VISIT_PATCH not found. Catastrophic error.  Quitting."
    VISIT_PATCH=
  fi

# Determine the branch to find the patch.
  local branchurl=`bilderSvn info $PROJECT_DIR/visit | grep ^URL: | sed -e 's/^URL: *//' -e 's?/src$??'`
  local branch=`echo $branchurl | sed 's?^https*://portal.nersc.gov/svn/visit/??' | tr '/' '_'`
  local svnrev=`bilderSvnversion -c $PROJECT_DIR/visit | sed 's/^.*-//'`

# Set is-trunk variable for later use
  case $branch in
    trunk) IS_VISIT_TRUNK=true;;
    *) IS_VISIT_TRUNK=false;;
  esac

# Determine the visit patch.
# svn up if allowed, as the patch may have changed.
  local lbl
  for lbl in r${svnrev}-${BILDER_CHAIN} r${svnrev} rHEAD-${BILDER_CHAIN} rHEAD; do
    VISIT_PATCH=$BILDER_DIR/patches/visit-${branch}-${lbl}.patch
    techo "Looking for $VISIT_PATCH."
    if test -f "$VISIT_PATCH"; then
      techo "$VISIT_PATCH found."
      break
    else
      techo "$VISIT_PATCH not found."
      VISIT_PATCH=
    fi
  done
# Final check
  if test -z "$VISIT_PATCH"; then
    techo "No patch for VisIt found."
  fi

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
# With the correct handling of svn, this can go away?
if false; then
    case $VISIT_BLDRVERSION in
      *M)
        techo "VisIT modified: VISIT_BLDRVERSION = $VISIT_BLDRVERSION."
        if test -n "$JENKINS_FSROOT"; then
if false; then
          techo "WARNING: Trying to get visit again."
          cmd="rmall $PROJECT_DIR/visit/*"
          techo "$cmd"
          if ! $cmd; then
            techo "$cmd"
            if ! $cmd; then
              techo "WARNING: Removal of visit failed."
            fi
          fi
fi
          cmd="bilderSvn up"
          techo "Executing '$cmd' in $PROJECT_DIR/visit."
          (cd $PROJECT_DIR/visit; $cmd 1>/dev/null)
          cmd="bilderSvn revert --recursive ."
          techo "Executing '$cmd' in $PROJECT_DIR/visit."
          (cd $PROJECT_DIR/visit; $cmd 1>/dev/null)
          getVersion visit
          techo "After update: VISIT_BLDRVERSION = $VISIT_BLDRVERSION."
        fi
        ;;
      *)
        # techo "VisIT is not modified: VISIT_BLDRVERSION = $VISIT_BLDRVERSION."
        ;;
    esac
fi

# Determine the visit patch for repo
    setVisitRepoPatch
    if $IS_VISIT_TRUNK; then
# Trunk and branch are put into different places
      VISIT_SUBDIR_BASE=visit_trunk
    else
      VISIT_SUBDIR_BASE=visit
    fi
# Determine whether patch in installation matches that in bilder.
# If differs, set visit as uninstalled so it will be built.
    if ! isPatched -s $VISIT_SUBDIR_BASE visit-$VISIT_BLDRVERSION-ser; then
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
      techo "patch -p0 <$VISIT_PATCH"
      (cd $PROJECT_DIR; patch -p0 <$VISIT_PATCH >$BUILD_DIR/visit-patch.txt 2>&1)
      techo "VisIt patched. Results in $BUILD_DIR/visit-patch.txt."
      if grep -qi fail $BUILD_DIR/visit-patch.txt; then
        grep -i fail $BUILD_DIR/visit-patch.txt | sed 's/^/WARNING: /' >$BUILD_DIR/visit-patch.fail
        cat $BUILD_DIR/visit-patch.fail | tee -a $LOGFILE
      fi
    fi
    bilderPreconfig -c visit
    res=$?
  else
    bilderUnpack visit
    res=$?
  fi

  if test $res = 0; then

    local VISIT_ARCH=`getVisitArch`

# Set prefix args to allow trunk and branch builds to coexist
    VISIT_SERSH_PREFIX_ARGS="-p $VISIT_SUBDIR_BASE-$VISIT_BLDRVERSION-sersh"
    VISIT_PARSH_PREFIX_ARGS="-p $VISIT_SUBDIR_BASE-$VISIT_BLDRVERSION-parsh"

# Args for make and environment, and configuration file
    local VISIT_MAKEARGS       # This to be set as needed, since can fail
    local VISIT_ENV
    case `uname` in
      CYGWIN*)
        if which jom 1>/dev/null 2>/dev/null; then
          VISIT_MAKEARGS="$VISIT_MAKEJ_ARGS"
        fi
# Remove cygwin paths when configuring
        PATH_CYGWIN_LAST=`echo :$PATH: | sed -e 's?:/usr/bin:?:?' -e 's?:/bin:?:?'`:/usr/bin
        VISIT_ENV="PATH='$PATH_CYGWIN_LAST'"
        ;;
      Darwin)
        VISIT_MAKEARGS="$VISIT_MAKEJ_ARGS"
        ;;
      Linux)
        VISIT_MAKEARGS="$VISIT_MAKEJ_ARGS"
        local VISIT_LD_RUN_PATH=$CONTRIB_DIR/mesa-mgl/lib:$PYC_LD_RUN_PATH:$LD_RUN_PATH
        VISIT_ENV="LD_RUN_PATH=$VISIT_LD_RUN_PATH"
        ;;
    esac

#
# VisIt needs to find hdf5 mesa netcdf Python Qt VTK
#
# Set unix style directories
    VISIT_HDF5_DIR="$HDF5_CC4PY_DIR"
    local VISIT_MESA_DIR=
    if test -d $CONTRIB_DIR/mesa/lib; then
      VISIT_MESA_DIR=$CONTRIB_DIR/mesa
    fi
    local VISIT_NETCDF_DIR=
    if test -d $CONTRIB_DIR/netcdf/lib; then
      VISIT_NETCDF_DIR=$CONTRIB_DIR/netcdf
    fi
    local VISIT_PYTHON_DIR="$PYTHON_DIR"
# Find location of QT in unix file system
    findQt
# Find Vtk (5.8 for ALL VisIt builds)
    local VISIT_VTK_DIR=$CONTRIB_DIR/visit_vtk-sersh
    techo "VISIT_VTK_DIR = $VISIT_VTK_DIR."

# Get mixed (CYGWIN) or native (OTHER) paths.
# VISIT_PYTHON_DIR is already mixed.
    VISIT_QT_BIN="$QT_BINDIR"
    for i in VISIT_HDF5_DIR VISIT_MESA_DIR VISIT_NETCDF_DIR VISIT_QT_BIN VISIT_VTK_DIR; do
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
    for i in HDF5 MESA NETCDF PYTHON VTK; do
      local var=VISIT_${i}_DIR
      local val=`deref ${var}`
      if test -n "$val"; then
        local argval="-DVISIT_${i}_DIR:PATH=$val"
        eval VISIT_${i}_ARGS="$argval"
        VISIT_PKG_ARGS="$VISIT_PKG_ARGS $argval"
      fi
    done
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
    if bilderConfig $VISIT_SERSH_PREFIX_ARGS -c visit sersh "$VISIT_OS_ARGS -DIGNORE_THIRD_PARTY_LIB_PROBLEMS:BOOL=ON -DVISIT_INSTALL_THIRD_PARTY:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $VISIT_PKG_ARGS $VISIT_OS_ARGS $VISIT_SERSH_OTHER_ARGS" "" "$VISIT_ENV"; then
      bilderBuild visit sersh "$VISIT_MAKEARGS" "$VISIT_ENV"
    fi

# Build parallel doing optional builds
    if bilderConfig $VISIT_PARSH_PREFIX_ARGS -c visit parsh "-DVISIT_PARALLEL:BOOL=ON -DVISIT_MPI_COMPILER='$MPICXX' -DVISIT_MPI_LIBS:PATH=$MPI_LIBDIR -DIGNORE_THIRD_PARTY_LIB_PROBLEMS:BOOL=ON -DVISIT_INSTALL_THIRD_PARTY:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $VISIT_PKG_ARGS $VISIT_OS_ARGS $VISIT_PARSH_OTHER_ARGS" "" "$VISIT_ENV"; then

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
# Visit uses serial hdf5 even in parallel.
      bilderBuild visit parsh "$VISIT_MAKEARGS" "$VISIT_ENV"
    fi

  fi

}

######################################################################
#
# Test
#
######################################################################

testVisit() {
  techo "Not testing visit."
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
        techo "VisIt correctly installed hdf5dll.dll."
      fi
      techo "VisIt did not install hdf5dll.dll.  Copying from $hdf5rootdir."
      local cmd=
      if test -f $hdf5rootdir/bin/hdf5dll.dll; then
        cmd="cp $hdf5rootdir/bin/hdf5dll.dll $instdir/"
      elif test -f $hdf5rootdir/dll/hdf5dll.dll; then
        techo "$hdf5rootdir/bin/hdf5dll.dll not present."
        cmd="cp $hdf5rootdir/dll/hdf5dll.dll $instdir/"
      else
        techo "$hdf5rootdir/dll/hdf5dll.dll not present."
        techo "Catastrophic error.  hdf5dll.dll not found in $hdf5rootdir."
        techo "Quitting."
        exit 1
      fi
      techo "$cmd"
      eval "$cmd"
      ;;

    Darwin)
# If link to install name of hdf5 not installed, make link
      local hdf5libname=$instdir/libhdf5.${HDF5_BLDRVERSION}.dylib
      if ! test -f $hdf5libname; then
        techo "ERROR: $hdf5libname missing."
        return
      fi
      techo "Extracting compatibility name from $hdf5libname."
      local hdf5compatname=`otool -L $hdf5libname | sed -n 2p | sed -e 's/^.*libhdf5/libhdf5/' -e 's/ .*$//'`
      if test -f $instdir/$hdf5compatname; then
        techo "VisIt correctly installed $hdf5compatname."
        return
      fi
      techo "$hdf5compatname absent in $instdir.  Will make link."
      cmd="(cd $instdir; ln -s libhdf5.${HDF5_BLDRVERSION}.dylib $hdf5compatname)"
      techo "$cmd"
      eval "$cmd"
      ;;

    *)
# If link to soname of hdf5 not installed, make link
# JRC: still necessary as of visit-r19672
      if ! test -f $instdir/libhdf5.so.${HDF5_BLDRVERSION}; then
        techo "ERROR: $instdir/libhdf5.so.${HDF5_BLDRVERSION} missing."
        return
      fi
      techo "Extracting soname from $instdir/libhdf5.so.${HDF5_BLDRVERSION}."
      local hdf5soname=`objdump -p $instdir/libhdf5.so.${HDF5_BLDRVERSION} | grep SONAME | sed -e 's/ *SONAME *//'`
      if test -f $instdir/$hdf5soname; then
        techo "VisIt correctly installed $hdf5soname."
        return
      fi
      techo "$hdf5soname absent in $instdir.  Will make link."
      cmd="(cd $instdir; ln -s libhdf5.so.${HDF5_BLDRVERSION} $hdf5soname)"
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

installVisit() {

# Store and modify umask
  local umasksav=`umask`
  umask $VISIT_UMASK

# Install serial and parallel
  for bld in `echo $VISIT_BUILDS | tr ',' ' '`; do

    sfx="-$bld"

# Install
    if bilderInstall -r visit $bld; then

# Remove old links
      rmall ${BLDR_INSTALL_DIR}/visit2*

# Visit variables
      local VISIT_ARCH=`getVisitArch`
      techo "VISIT_DISTVERSION = $VISIT_DISTVERSION"
      local visit_uscrversion=`echo $VISIT_DISTVERSION | sed 's/\./_/g'`

# File to contain installation fixes
      local installfixfile=$BUILD_DIR/visit/$bld/installfix.out
      rm -f $installfixfile
      touch $installfixfile

# Link to current if not done.  Darwin docs say to change -h to -L.
      case `uname` in
        CYGWIN*)
          ;;
        *)
          if ! test -L $BLDR_INSTALL_DIR/${VISIT_SUBDIR_BASE}-${VISIT_BLDRVERSION}-$bld/current; then
            techo "# NOTE: Creating 'current' link." | tee -a $installfixfile
            cmd="cd $BLDR_INSTALL_DIR/${VISIT_SUBDIR_BASE}-${VISIT_BLDRVERSION}-$bld; ln -s $VISIT_DISTVERSION current"
            techo "$cmd" >>$installfixfile
            eval $cmd
 	    cd -
          else
            techo "# NOTE: VisIt correctly creating current link again."
          fi
          ;;
      esac

# If parallel-Linux, link in the mpi libraries
      case $bld in
        par)
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
          for libdir in $BLDR_INSTALL_DIR/${VISIT_SUBDIR_BASE}-${VISIT_BLDRVERSION}-par/$VISIT_DISTVERSION/$VISIT_ARCH/lib $BUILD_DIR/visit/par/lib; do
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
          parlib=$BLDR_INSTALL_DIR/${VISIT_SUBDIR_BASE}-${VISIT_BLDRVERSION}-par/$VISIT_DISTVERSION/$VISIT_ARCH/lib/libengine_par${SHOBJEXT}
          if ! test -f $parlib; then
            techo "# NOTE: Installing lib, $parlib."
            cmd="install -m 775 $BUILD_DIR/visit/par/lib/libengine_par${SHOBJEXT} $parlib"
            techo "$cmd" | tee -a $installfixfile
            $cmd
          else
             techo "# NOTE: VisIt correctly installed lib, $parlib."
          fi
          ;;

      esac

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
        fixCopiedHdf5 $BLDR_INSTALL_DIR/${VISIT_SUBDIR_BASE}-${VISIT_BLDRVERSION}-$bld $hdf5rootdir $installfixfile
      else
        fixCopiedHdf5 $BLDR_INSTALL_DIR/${VISIT_SUBDIR_BASE}-${VISIT_BLDRVERSION}-$bld/$VISIT_DISTVERSION/$VISIT_ARCH/lib $hdf5rootdir/lib $installfixfile
      fi

# Packaging only if creating a release
      if $IS_VISIT_TRUNK && $BUILD_INSTALLERS; then
# Create the package
        runnrExec "cd $BUILD_DIR/visit/$bld"
        case `uname` in
          CYGWIN*) cmd="nmake package";;
          *) cmd="make package";;
        esac
        techo "$cmd" | tee package.out
        $cmd 1>>package.out 2>&1
# Install the package.
# JRC 20121119: need to do something that works with Windows.
# At least post as in bilderInstall, look for POST2DEPOT
if false; then
        cmd="rmall $BLDR_INSTALL_DIR/visitpkg$sfx"
        techo "$cmd" | tee installpkg.out
        $cmd
        cmd="$PROJECT_DIR/visit/svn_bin/visit-install -c none -b bvidp $VISIT_DISTVERSION $VISIT_ARCH $BLDR_INSTALL_DIR/visitpkg$sfx"
        techo "$cmd" | tee -a installpkg.out
        $cmd 1>>installpkg.out 2>&1
fi
      fi

      techo "Post installation of ${VISIT_SUBDIR_BASE}-${VISIT_BLDRVERSION}-$bld concluded at `date`."
      local starttimeval=$VISIT_START_TIME
      local endtimeval=`date +%s`
      local buildtime=`expr $endtimeval - $starttimeval`
      techo "visit-$bld took `myTime $buildtime` to build, install, and package."
    fi

  done

# Restore umask
  umask $umasksav

}

