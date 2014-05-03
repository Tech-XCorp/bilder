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
  # CGM_REPO_TAG_STD=CGM-0.14.1
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

# Find freetype
  if ! declare -f findFreetypeRootdir 1>/dev/null 2>&1; then
    source $BILDER_DIR/packages/freetype.sh
  fi
  local freetype_rootdir=`findFreetypeRootdir`

# Set other args, env
  local CGM_ADDL_ARGS=
  local ocedir=
  if ocedir=`(cd $BLDR_INSTALL_DIR/oce-sersh; pwd-P)`; then
    :
  elif ocedir=`(cd $BLDR_INSTALL_DIR/oce-sersh; pwd-P)`; then
    :
  fi
  if test -n "$ocedir"; then
    CGM_ADDL_ARGS="$CGM_ADDL_ARGS --with-occ=$ocedir"
  fi
  local CGM_ENV=
if false; then
  if test -n "$freetype_rootdir"; then
    CGM_ENV="FREETYPE_DIR=$freetype_rootdir"
  fi
fi

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$CGM_MAKEJ_ARGS"
  fi

# Configure and build
  # if bilderConfig $makerargs cgm $CGM_BUILD "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CGM_ADDL_ARGS $CGM_OTHER_ARGS" "" "$CGM_ENV"; then
  if bilderConfig $makerargs cgm $CGM_BUILD "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $CGM_ADDL_ARGS $CGM_OTHER_ARGS" "" "$CGM_ENV"; then
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

