#!/bin/bash
#
# Version and build information for tables
#
# $Id: tables.sh 6982 2012-11-10 14:21:48Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

if test -z "$TABLES_BLDRVERSION"; then
  TABLES_BLDRVERSION=2.3.1
fi

######################################################################
#
# Builds and deps
#
######################################################################

TABLES_BUILDS=${TABLES_BUILDS:-"cc4py"}
TABLES_DEPS=hdf5,Cython,numexpr,numpy

######################################################################
#
# Launch tables builds.
#
######################################################################

buildTables() {

  if bilderUnpack tables; then

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
        techo "WARNING: [tables.sh] uname `uname` not recognized.  Not building."
        return
        ;;
    esac
    trimvar linkflags ' '
    # techo "linkflags = $linkflags."
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

  fi

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
# Function to put rpath in front of a library name in a dylib
# and add . to the rpath.  This will likely be generalized.
#
######################################################################

addDarwinRpathToExtensions() {
# Get the directory
  local dir=$1
  local extensions=`find $dir -name '*Extension.so' -print`
  for i in $extensions; do
    cmd="install_name_tool -change libhdf5.${TABLES_HDF5_VERSION}.dylib @rpath/libhdf5.${TABLES_HDF5_VERSION}.dylib $i"
    techo "$cmd"
    $cmd
    cmd="install_name_tool -add_rpath . $i"
    techo "$cmd"
    $cmd
  done
}

######################################################################
#
# Install tables
#
######################################################################

installTables() {

# On CYGWIN, no installation to do, just mark
  case `uname`-`uname -r` in

    CYGWIN*)
      if bilderDuInstall -n tables; then
        local tablesinstdir=${PYTHON_SITEPKGSDIR}/tables
        local hdf5sershdll=${HDF5_SERSH_DIR}/bin/hdf5dll.dll
        if test -f $hdf5sershdll; then
          cp $hdf5sershdll $tablesinstdir
        else
          techo "WARNING tables could not find hdf5dll.dll"
        fi
      fi
      ;;

    Darwin-1?.*)
# On Darwin, add the rpaths so that hdf5 is found
      if bilderDuInstall -r tables tables "$TABLES_ARGS" "$TABLES_ENV"; then
        addDarwinRpathToExtensions $PYTHON_SITEPKGSDIR/tables
        if ! test -f $PYTHON_SITEPKGSDIR/tables/libhdf5.${TABLES_HDF5_VERSION}.dylib; then
          techo "$PYTHON_SITEPKGSDIR/tables/libhdf5.${TABLES_HDF5_VERSION}.dylib missing.  Will install."
          /usr/bin/install -m 775 $HDF5_CC4PY_DIR/lib/libhdf5.${TABLES_HDF5_VERSION}.dylib $PYTHON_SITEPKGSDIR/tables
        fi
      fi
      ;;

    *) bilderDuInstall -r tables tables "$TABLES_ARGS" "$TABLES_ENV";;

  esac
  # techo "Quitting at the end of tables.sh"; exit

}

