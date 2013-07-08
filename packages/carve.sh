#!/bin/bash
#
# Version and build information for carve
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

case `uname`-`uname -r` in
  CYGWIN* | Darwin-11.*) CARVE_BLDRVERSION_STD=1.4.0;;
  *) CARVE_BLDRVERSION_STD=1.4.0;;
esac
CARVE_BLDRVERSION_EXP=1.4.0

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Carve builds only shared
CARVE_DESIRED_BUILDS=${CARVE_DESIRED_BUILDS:-"sersh"}
computeBuilds carve
CARVE_DEPS=cmake,mercurial
CARVE_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

#
# Move old carve aside.
#
# Args
# 1: the repo to look for
#
mvOldCarveDir() {
  if test -d carve; then
    techo "Moving aside old carve directory."
    if test -n "$1" -a -d carve/.${1}; then
      olddir=carve-$1
    else
      olddir=carve-old
    fi
    cmd="rm -rf $olddir"
    techo "$cmd"
    $cmd
    cmd="mv carve $olddir"
    techo "$cmd"
    $cmd
  fi
}

#
# Get carve using hg.  This gives a version that does not
# build on Windows.
#
getHgCarve() {
  local HG=`which hg`
  if test -z "$HG"; then
    techo "WARNING: hg not in path.  Cannot get carve."
    return 1
  else
    techo "HG = $HG."
  fi
  local origdir=`pwd -P`
  if ! test -d carve/.hg; then
    techo "No mercurial checkout of carve."
    mvOldCarveDir svn
    cmd="hg clone https://code.google.com/p/carve"
    techo "$cmd"
    $cmd 2>&1 | tee -a $LOGFILE
  else
    cmd="cd carve"
    techo "$cmd"
    $cmd
    cmd="hg revert -a"
    techo "$cmd"
    $cmd
    if $SVNUP || test -n "$JENKINS_FSROOT"; then
      cmd="hg pull"
      techo "$cmd"
      $cmd
    fi
  fi
  cd $origdir
  return 0
}

#
# A window compatible Carve is in the blender trunk at
# trunk/blender/extern/carve.  Will figure out how to
# obtain with svn.
#
getSvnCarve() {
  if ! test -d carve/.svn; then
    techo "No subversion checkout of carve."
    mvOldCarveDir hg
    cmd="svn co https://svn.blender.org/svnroot/bf-blender/trunk/blender/extern/carve"
    techo "$cmd"
    $cmd
  fi
}

#
# Get carve.  Delegate to git or hg.
#
getCarve() {
  getHgCarve
  return $?
}

#
# Build carve
#
buildCarve() {

# Try to get carve from repo
  if ! (cd $PROJECT_DIR; getCarve); then
    echo "WARNING: Problem in getting carve."
  fi

# If no subdir, done.
  if ! test -d $PROJECT_DIR/carve; then
    techo "WARNING: Carve not found."
    return 1
  fi

# Get version
  getVersion carve
# Patch
  cd $PROJECT_DIR
  if test -f $BILDER_DIR/patches/carve.patch; then
    cmd="(cd carve; patch -p1 <$BILDER_DIR/patches/carve.patch)"
    techo "$cmd"
    eval "$cmd"
  fi

# Preconfig
  if ! bilderPreconfig -c carve; then
    return 1
  fi

# Build the shared libs
  if bilderConfig carve sersh "-DBUILD_SHARED_LIBS:BOOL=TRUE -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SERSH $CMAKE_COMPFLAGS_SERSH -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=TRUE $CARVE_SERSH_OTHER_ARGS"; then
    bilderBuild carve sersh "$CARVE_MAKEJ_ARGS"
  fi

}

######################################################################
#
# Test
#
######################################################################

testCarve() {
  techo "Not testing carve."
}

######################################################################
#
# Install
#
######################################################################

installCarve() {
  if bilderInstall -p -r carve sersh; then
    case `uname` in
      Darwin)
        cd $CARVE_SERSH_INSTALL_DIR/carve-${CARVE_BLDRVERSION}-sersh/bin
        for i in *; do
# Needs to be more general by finding the name of the library
          cmd="install_name_tool -change libcarve.2.0.dylib @rpath/libcarve.2.0.dylib $i"
          techo "$cmd"
          $cmd
          cmd="install_name_tool -add_rpath @executable_path/../lib $i"
          techo "$cmd"
          $cmd
        done
        ;;
    esac
  fi
}

