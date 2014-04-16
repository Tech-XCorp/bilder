#!/bin/bash
#
# Version and build information for cgm
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# CGM_BLDRVERSION=${CGM_BLDRVERSION:-"0.10.1-r747"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setCgmGlobalVars() {
# Only the python build needed.
  CGM_BUILD=$FORPYTHON_BUILD
  CGM_BUILDS=${CGM_BUILDS:-"$FORPYTHON_BUILD"}
  CGM_DEPS=oce,cmake
  CGM_UMASK=002
  CGM_REPO_URL=https://bitbucket.org/fathomteam/cgm.git
  CGM_UPSTREAM_URL=https://bitbucket.org/fathomteam/cgm.git
  # CGM_REPO_TAG_STD=OCE-0.14.1
  CGM_REPO_TAG_EXP=master
  # addtopathvar PATH $CONTRIB_DIR/cgm/bin
}
setCgmGlobalVars

######################################################################
#
# Launch cgm builds.
#
######################################################################

#
# Build OCE
#
buildCgm() {

# Get cgm from repo and remove any detritus
  updateRepo cgm
  rm -f $PROJECT_DIR/cgm/CMakeLists.txt.{orig,rej}

# If no subdir, done.
  if ! test -d $PROJECT_DIR/cgm; then
    techo "WARNING: cgm dir not found. Building from package."
  fi

# Get cgm
  cd $PROJECT_DIR
  local CGM_ADDL_ARGS=
  local CGM_INSTALL_DIR=
  if test -d cgm; then
    getVersion cgm
    local patchfile=
    if $BUILD_EXPERIMENTAL; then
      patchfile=$BILDER_DIR/patches/cgm-exp.patch
    else
      patchfile=$BILDER_DIR/patches/cgm-${CGM_BLDRVERSION}.patch
    fi
    if test -e $patchfile; then
      CGM_PATCH=$patchfile
      cmd="(cd $PROJECT_DIR/cgm; patch -N -p1 <$patchfile)"
      techo "$cmd"
      eval "$cmd"
    fi
    if ! bilderPreconfig cgm; then
      return 1
    fi
    CGM_INSTALL_DIR="$BLDR_INSTALL_DIR/cgm-$CGM_BLDRVERSION-$CGM_BUILD"
    techo "NOTE: cgm git repo found."
  else
    if ! bilderUnpack cgm; then
      return 1
    fi
    CGM_INSTALL_DIR="$CONTRIB_DIR/cgm-$CGM_BLDRVERSION-$CGM_BUILD"
  fi
  CGM_ADDL_ARGS="-DCGM_INSTALL_PREFIX:PATH=$CGM_INSTALL_DIR -DCMAKE_INSTALL_NAME_DIR:PATH=$CGM_INSTALL_DIR/lib -DCGM_MULTITHREADED_BUILD:BOOL=FALSE"

# Find freetype
  if ! declare -f findFreetypeRootdir 1>/dev/null 2>&1; then
    source $BILDER_DIR/packages/freetype.sh
  fi
  local freetype_rootdir=`findFreetypeRootdir`

# Set other args, env
  local CGM_ENV=
  if test -n "$freetype_rootdir"; then
    CGM_ENV="FREETYPE_DIR=$freetype_rootdir"
  fi
# Disabling X11 prevents build of TKMeshVS, needed for salomesh in freecad.
  # CGM_ADDL_ARGS="$CGM_ADDL_ARGS -DCGM_DISABLE_X11:BOOL=TRUE"
  case `uname` in
    Darwin)
      CGM_ADDL_ARGS="$CGM_ADDL_ARGS -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS'"
      ;;
  esac

# OCE does not have all dependencies right on Windows, so needs nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$CGM_MAKEJ_ARGS"
  fi

# Configure and build
  if bilderConfig $makerargs cgm $CGM_BUILD "-DCGM_INSTALL_INCLUDE_DIR:STRING=include $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CGM_ADDL_ARGS $CGM_OTHER_ARGS" "" "$CGM_ENV"; then
    bilderBuild $makerargs cgm $CGM_BUILD "$makejargs" "$CGM_ENV"
  fi

}

######################################################################
#
# Test cgm
#
######################################################################

testCgm() {
  techo "Not testing cgm."
}

######################################################################
#
# Install cgm
#
######################################################################

installCgm() {
  bilderInstallAll cgm
}

