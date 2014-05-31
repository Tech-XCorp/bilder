#!/bin/bash
#
# Build information for tables
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in tables_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/tables_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTablesNonTriggerVars() {
  :
}
setTablesNonTriggerVars

######################################################################
#
# Launch tables builds.
#
######################################################################

buildTables() {

  if ! bilderUnpack tables; then
    return
  fi

# Patch using sed, as this is a dos file and so regular patch does not work
  case $TABLES_BLDRVERSION in
    2.1.?)
      local ptchfile=$BUILD_DIR/tables-$TABLES_BLDRVERSION/tables/numexpr/missing_posix_functions.inc
      cmd="sed -i.bak -e 's/inline static/inline/g' $ptchfile"
      techo "$cmd"
      sed -i.bak -e 's/inline static/inline/g' $ptchfile
      ;;
  esac

# Look for HDF5 first by defines
  if test -z "$HDF5_CC4PY_DIR"; then
    techo "HDF5_CC4PY_DIR not set.  Cannot find hdf5.  Cannot build tables."
    return 1
  fi
  local TABLES_HDF5_DIR="$HDF5_CC4PY_DIR"
  if [[ `uname` =~ CYGWIN ]]; then
    TABLES_HDF5_DIR=`cygpath -aw $TABLES_HDF5_DIR`
  fi
  TABLES_HDF5_VERSION=`echo $HDF5_CC4PY_DIR | sed -e 's/^.*hdf5-//' -e 's/-.*$//'`
  techo "TABLES_HDF5_VERSION = $TABLES_HDF5_VERSION."

# Accumulate link flags for modules, and make ATLAS modifications.
# Darwin defines PYC_MODFLAGS = "-undefined dynamic_lookup",
#   but not PYC_LDSHARED
# Linux defines PYC_MODFLAGS = "-shared", but not PYC_LDSHARED
  local linkflags="$CC4PY_ADDL_LDFLAGS $PYC_LDSHARED $PYC_MODFLAGS"

# For Cygwin, build, install, and make packages all at once.
# For others, just build.
  case `uname`-"$CC" in
# For Cygwin builds, one has to specify the compiler during installation,
# but then one has to be building, otherwise specifying the compiler is
# an error.  So the only choice seems to be to install simultaneously
# with building.  Unfortunately, one cannot then intervene between the
# build and installation steps to remove old installations only if the
# build was successful.  One must do any removal then before starting
# the build and installation.
    CYGWIN*-*cl*)
      TABLES_ARGS="--hdf5='$TABLES_HDF5_DIR' --compiler=msvc install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
      TABLES_ENV=`echo $DISTUTILS_NOLV_ENV | sed "s@PATH=@PATH=$HDF5_SERSH_DIR/bin:@"`
      ;;
    CYGWIN*-mingw*)
      TABLES_ARGS="--hdf5='$TABLES_HDF5_DIR' --compiler=mingw32 install --prefix='$NATIVE_CONTRIB_DIR' bdist_wininst"
      TABLES_ENV="PATH=/MinGW/bin:'$PATH'"
      ;;
# For non-Cygwin builds, the build stage does not install.
    Darwin-*)
      linkflags="$linkflags ${RPATH_FLAG}$TABLES_HDF5_DIR/lib"
      TABLES_ARGS="--hdf5=$TABLES_HDF5_DIR"
      TABLES_ENV="$DISTUTILS_NOLV_ENV"
      ;;
    Linux-*)
	linkflags="$linkflags -Wl,-rpath,$TABLES_HDF5_DIR/lib"
      TABLES_ARGS="--hdf5=$TABLES_HDF5_DIR"
      TABLES_ENV="$DISTUTILS_NOLV_ENV"
      ;;
    *)
      techo "WARNING: [$FUNCNAME] uname `uname` not recognized.  Not building."
      return
      ;;
  esac
# Add env if no dll at end of hdf5 files
  case $HDF5_BLDRVERSION in
    1.8.1[1-9])
      TABLES_ENV="$TABLES_ENV HDF5_LIBNAMES_LACK_DLL=1"
      sed -i.bak -e 's/hdf5dll/hdf5/g' $BUILD_DIR/tables-$TABLES_BLDRVERSION/tables/__init__.py
      ;;
  esac
  trimvar linkflags ' '
  if test -n "$linkflags"; then
    TABLES_ARGS="$TABLES_ARGS --lflags='$linkflags'"
  fi

# For CYGWIN builds, remove any detritus lying around now.
  if [[ `uname` =~ CYGWIN ]]; then
    cmd="rmall ${PYTHON_SITEPKGSDIR}/tables*"
    techo "$cmd"
    $cmd
  fi

# Build/install
  bilderDuBuild -p tables tables "$TABLES_ARGS" "$TABLES_ENV"

}

######################################################################
#
# Test tables
#
######################################################################

testTables() {
  techo "Not testing tables."
}

######################################################################
#
# Install tables
#
######################################################################

installTables() {

# Determine installation args
  case `uname` in
    CYGWIN*) instopts=-n;;
    *) instopts="-r tables";;
  esac

# Install library if not present, make link if needed
  if bilderDuInstall $instopts tables "$TABLES_ARGS" "$TABLES_ENV"; then

# Determine libraries, compatibility name/soname
    local hdf5shlib=
    local hdf5shlink=
    local instopts=
    case `uname` in
      CYGWIN*)
        hdf5shdir=$HDF5_CC4PY_DIR/bin
        if echo $TABLES_ENV | grep HDF5_LIBNAMES_LACK_DLL; then
          hdf5shlib=hdf5.dll
        else
          hdf5shlib=hdf5dll.dll
        fi
        ;;
      Darwin)
        hdf5shdir=$HDF5_CC4PY_DIR/lib
        hdf5shlib=libhdf5.${TABLES_HDF5_VERSION}.dylib
        hdf5shname=`otool -D $hdf5shdir/$hdf5shlib | tail -1`
        ;;
      Linux)
        hdf5shdir=$HDF5_CC4PY_DIR/lib
        hdf5shlib=libhdf5.so.${TABLES_HDF5_VERSION}
        ;;
    esac

# Get shared lib installed and names changed inside it.
    local tablesinstdir=${PYTHON_SITEPKGSDIR}/tables
    installRelShlib $hdf5shlib $tablesinstdir $hdf5shdir

# Change names inside tables so's.
    if test `uname` = Darwin; then
      hdf5shlink=`basename $hdf5shname`
      local extensions=`find $tablesinstdir -name '*Extension.so' -print`
      if test -z "$extensions"; then
        extensions=`find $tablesinstdir -name '*extension.so' -print`
      fi
      for i in $extensions; do
        cmd="install_name_tool -change $hdf5shname @rpath/$hdf5shlink $i"
        techo "$cmd"
        $cmd
        cmd="install_name_tool -add_rpath @loader_path/ $i"
        techo "$cmd"
        $cmd
      done
    fi
  fi

}

