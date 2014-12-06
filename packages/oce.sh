#!/bin/bash
#
# Build information for oce
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in oce_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/oce_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOceNonTriggerVars() {
  OCE_UMASK=002
}
setOceNonTriggerVars

######################################################################
#
# Launch oce builds.
#
######################################################################

#
# Build OCE
#
buildOce() {

# Get oce from repo and remove any detritus
  updateRepo oce
  rm -f $PROJECT_DIR/oce/CMakeLists.txt.{orig,rej}

# If no subdir, done.
  if ! test -d $PROJECT_DIR/oce; then
    techo "WARNING: oce dir not found. Building from package."
  fi

# Get oce
  cd $PROJECT_DIR
  local OCE_ADDL_ARGS=
  local OCE_INSTALL_DIR=
  if test -d oce; then
    getVersion oce
    local patchfile=$BILDER_DIR/patches/oce-${OCE_BLDRVERSION}.patch
    if ! test -e $patchfile && $BUILD_EXPERIMENTAL; then
      patchfile=$BILDER_DIR/patches/oce-exp.patch
    fi
    if test -e $patchfile; then
      cmd="(cd $PROJECT_DIR/oce; patch -N -p1 <$patchfile)"
      techo "$cmd"
      eval "$cmd"
    fi
    if ! bilderPreconfig oce; then
      return 1
    fi
    OCE_INSTALL_DIR="$BLDR_INSTALL_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD"
    techo "NOTE: oce git repo found."
  else
    if ! bilderUnpack oce; then
      return 1
    fi
    OCE_INSTALL_DIR="$CONTRIB_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD"
  fi
  OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$OCE_INSTALL_DIR -DCMAKE_INSTALL_NAME_DIR:PATH=$OCE_INSTALL_DIR/lib -DOCE_MULTITHREADED_BUILD:BOOL=FALSE -DOCE_TESTING:BOOL=FALSE"

# Find freetype
  if test -z "$FREETYPE_PYCSH_DIR"; then
    source $BILDER_DIR/packages/freetype_aux.sh
    findFreetype
  fi

# Set other args, env
  local OCE_ENV=
  if test -n "$FREETYPE_PYCSH_DIR"; then
    OCE_ENV="FREETYPE_DIR=$FREETYPE_PYCSH_DIR"
  fi
# Disabling X11 prevents build of TKMeshVS, needed for salomesh in freecad.
  # OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DISABLE_X11:BOOL=TRUE"
  case `uname` in
    Darwin)
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS'"
      ;;
    Linux)
      if test -n "$FREETYPE_PYCSH_DIR"; then
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS  -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,'$FREETYPE_PYCSH_DIR/lib'"
      fi
      ;;
  esac

# OCE does not have all dependencies right on Windows, so needs nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$OCE_MAKEJ_ARGS"
  fi

# Configure and build
  local otherargsvar=`genbashvar OCE_${QT_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`
  if bilderConfig $makerargs oce $OCE_BUILD "-DOCE_INSTALL_INCLUDE_DIR:STRING=include $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $OCE_ADDL_ARGS $otherargsval" "" "$OCE_ENV"; then
    bilderBuild $makerargs oce $OCE_BUILD "$makejargs" "$OCE_ENV"
  fi

}

######################################################################
#
# Test oce
#
######################################################################

testOce() {
  techo "Not testing oce."
}

######################################################################
#
# Install oce
#
######################################################################

installOce() {
  bilderInstallAll oce

  # Fixup library references removing references to full paths
  # to install directory for both OCE libs and the freetype lib.
  # Also install freetype lib with OCE.
  local ocelibdir="$CONTRIB_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD/lib"
  case `uname` in
    CYGWIN*)
      ;;
    Darwin)
      ocelibs=`ls  $ocelibdir/*.dylib`
      for ocelib in $ocelibs; do
        # Fix all refs to other OCE libs in this OCE library
        for refocelib in $ocelibs; do
          install_name_tool -change  $ocelibdir/$refocelib $refocelib $ocelib
        done
        hasft=`otool -L $ocelib | grep freetype`
        if test -n "$hasft"; then
          libname=`echo $hasft | sed 's/^.*libfreetype/libfreetype/' | sed 's/dylib.*$/dylib/'`
          fullpath=`echo $hasft | sed 's/^	//' | sed 's/dylib.*$/dylib/'`
          install_name_tool -change $fullpath $libname $ocelib
        fi
      done
      # Installing the freetype lib so that it is there in case OCE
      # library is copied into a distribution later.
      freetypeshdir=$FREETYPE_PYCSH_DIR/lib
      freetypeshlib=libfreetype.6.dylib
      installRelShlib $freetypeshlib $ocelibdir $freetypeshdir 
      ;;
    Linux)
      ;;
  esac  


}

