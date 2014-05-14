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
# Putting the version information into oce_aux.sh eliminates the
# rebuild when one changes that file.  Of course, if the actual version
# changes, or this file changes, there will be a rebuild.  But with
# this one can change the experimental version without causing a rebuild
# in a non-experimental Bilder run.  One can also change any auxiliary
# functions without sparking a build.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/cgm_aux.sh

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
  if bilderConfig -c cgm $CGM_BUILD "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CGM_ADDL_ARGS $CGM_OTHER_ARGS" "" "$CGM_ENV"; then
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
  findCgm
}

