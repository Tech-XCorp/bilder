#!/bin/bash
#
# Version and build information for tables
#
# $Id$
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
# Install tables
#
######################################################################

installTables() {

# Determine libraries, compatibility name/soname
  local hdf5shlib=
  local hdf5shlink=
  local instopts=
  case `uname` in
    CYGWIN*)
      hdf5shdir=$HDF5_CC4PY_DIR/bin
      hdf5shlib=hdf5dll.dll
      instopts=-n
      ;;
    Darwin)
      hdf5shdir=$HDF5_CC4PY_DIR/lib
      hdf5shlib=libhdf5.${TABLES_HDF5_VERSION}.dylib
      hdf5shlink=`otool -D $hdf5shdir/$hdf5shlib | tail -1`
      instopts="-r tables"
      ;;
    Linux)
      hdf5shdir=$HDF5_CC4PY_DIR/lib
      hdf5shlib=libhdf5.so.${TABLES_HDF5_VERSION}
      # hdf5shlink=`objdump -p $hdf5shdir/$hdf5shlib | grep SONAME | sed 's/^.*SONAME *//'`
      instopts="-r tables"
      ;;
  esac

# Install library if not present, make link if needed
  if bilderDuInstall $instopts tables "$TABLES_ARGS" "$TABLES_ENV"; then
    local tablesinstdir=${PYTHON_SITEPKGSDIR}/tables
    if ! test -f $tablesinstdir/$hdf5shlib; then
      techo "$tablesinstdir/$hdf5shlib missing.  Will install."
      /usr/bin/install -m 775 $hdf5shdir/$hdf5shlib $tablesinstdir
    fi
    if test -n "$hdf5shlink"; then
      cmd="(cd $tablesinstdir; ln -sf $hdf5shlib $hdf5shlink)"
      techo "$cmd"
      eval "$cmd"
    fi
    if test `uname` = Darwin; then
      local extensions=`find $dir -name '*Extension.so' -print`
      for i in $extensions; do
        cmd="install_name_tool -change $hdf5shlink @rpath/$hdf5shlink $i"
        techo "$cmd"
        $cmd
        cmd="install_name_tool -add_rpath @loader_path/ $i"
        techo "$cmd"
        $cmd
      done
    fi
  fi

}

