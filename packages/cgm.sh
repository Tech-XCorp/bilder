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

setCgmVersion() {
  CGM_REPO_URL=https://bitbucket.org/cadg4/cgm.git
  CGM_UPSTREAM_URL=https://bitbucket.org/fathomteam/cgm.git
  CGM_REPO_TAG_STD=master
  CGM_REPO_TAG_EXP=master
}
setCgmVersion

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
}
setCgmGlobalVars

######################################################################
#
# Launch cgm builds.
#
######################################################################

#
# Build CGM
#
buildCgm() {

# Get cgm from repo and remove any detritus
  updateRepo cgm
  # rm -f $PROJECT_DIR/cgm/CMakeLists.txt.{orig,rej}

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
    if ! bilderPreconfig -c cgm; then
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

# Set other args, env
  local CGM_ADDL_ARGS="$OCE_CC4PY_CMAKE_DIR_ARG"

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$CGM_MAKEJ_ARGS"
  fi

# Configure and build
  if bilderConfig $makerargs -c cgm $CGM_BUILD "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CGM_ADDL_ARGS $CGM_OTHER_ARGS" "" "$CGM_ENV"; then
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

