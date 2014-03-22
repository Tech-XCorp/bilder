#!/bin/bash
#
# Version and build information for oce
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# OCE_BLDRVERSION=${OCE_BLDRVERSION:-"0.10.1-r747"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setOceGlobalVars() {
# Only the python build needed.
  OCE_BUILD=$FORPYTHON_BUILD
  OCE_BUILDS=${OCE_BUILDS:-"$FORPYTHON_BUILD"}
  OCE_DEPS=freetype,cmake
  OCE_UMASK=002
  OCE_REPO_URL=git://github.com/tpaviot/oce.git
  OCE_UPSTREAM_URL=git://github.com/tpaviot/oce.git
  OCE_REPO_TAG_STD=OCE-0.14.1
  OCE_REPO_TAG_EXP=master
  # addtopathvar PATH $CONTRIB_DIR/oce/bin
}
setOceGlobalVars

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
    local patchfile=
    if $BUILD_EXPERIMENTAL; then
      patchfile=$BILDER_DIR/patches/oce-exp.patch
    else
      patchfile=$BILDER_DIR/patches/oce-${OCE_BLDRVERSION}.patch
    fi
    if test -e $patchfile; then
      OCE_PATCH=$patchfile
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
  OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$OCE_INSTALL_DIR -DCMAKE_INSTALL_NAME_DIR:PATH=$OCE_INSTALL_DIR/lib -DOCE_MULTITHREADED_BUILD:BOOL=FALSE"

# Find freetype
  if ! declare -f findFreetypeRootdir 1>/dev/null 2>&1; then
    source $BILDER_DIR/packages/freetype.sh
  fi
  local freetype_rootdir=`findFreetypeRootdir`

# Set other args, env
  local OCE_ENV=
  if test -n "$freetype_rootdir"; then
    OCE_ENV="FREETYPE_DIR=$freetype_rootdir"
  fi
# Disabling X11 prevents build of TKMeshVS, needed for salomesh in freecad.
  # OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DISABLE_X11:BOOL=TRUE"
  case `uname` in
    Darwin)
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS'"
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
  if bilderConfig $makerargs oce $OCE_BUILD "-DOCE_INSTALL_INCLUDE_DIR:STRING=include $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $OCE_ADDL_ARGS $OCE_OTHER_ARGS" "" "$OCE_ENV"; then
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
}

