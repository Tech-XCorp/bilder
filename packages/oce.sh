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

OCE_BLDRVERSION=${OCE_BLDRVERSION:-"0.10.1-r747"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Only the python build needed.
OCE_BUILD=$FORPYTHON_BUILD
OCE_BUILDS=${OCE_BUILDS:-"$FORPYTHON_BUILD"}
OCE_DEPS=ftgl
OCE_UMASK=002
addtopathvar PATH $CONTRIB_DIR/oce/bin

######################################################################
#
# Launch oce builds.
#
######################################################################

#
# Get oce using git.
# This gives a version that does not build on Windows.
#
getGitOce() {
  if ! which git 1>/dev/null 2>&1; then
    techo "WARNING: git not in path.  Cannot get oce."
    return
  fi
  if test -z "$PROJECT_DIR"; then
    local bldrdir=`dirname $BASH_SOURCE`
    bldrdir=`dirname $bldrdir`
    PROJECT_DIR=`dirname $bldrdir`
  fi
  cd $PROJECT_DIR
  if test -d oce/.git; then
    if $SVN_UP || test -n "$JENKINS_FSROOT"; then
      cmd="(cd oce; git pull)"
      techo "$cmd"
      eval "$cmd"
    fi
  else
    techo "$PWD/oce/.git does not exist.  No git checkout of oce."
    if test -d oce; then rm -rf oce.sav; mv oce oce.sav; fi
    cmd="git clone git://github.com/tpaviot/oce.git"
    techo "$cmd"
    $cmd
  fi
}

#
# Get OCE, in this case by git
#
getOce() {
  getGitOce
}

#
# Build OCE
#
buildOce() {

# Get oce from repo
  (cd $PROJECT_DIR; getOce)

# If no subdir, done.
  if ! test -d $PROJECT_DIR/oce; then
    techo "WARNING: oce dir not found. Building from package."
  fi

# Get oce
  cd $PROJECT_DIR
  local OCE_ADDL_ARGS=
  if test -d oce; then
    getVersion oce
    if ! bilderPreconfig oce; then
      return 1
    fi
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$BLDR_INSTALL_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD"
    techo "NOTE: Building oce from the git repo."
  else
    if ! bilderUnpack oce; then
      return 1
    fi
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD"
  fi

# Determine other configure args
  local ftgl_rootdir=`findFtglRootdir`
  if test -n "$ftgl_rootdir"; then
    OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_INCLUDE_DIR:PATH=$ftgl_rootdir/include"
  fi
  local freetype_rootdir=`findFreetypeRootdir`
  local OCE_ENV=
  if test -n "$freetype_rootdir"; then
    OCE_ENV="FREETYPE_DIR=$freetype_rootdir"
  fi
  case `uname` in
    CYGWIN*)
      if test -n "$ftgl_rootdir"; then
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_LIBRARY:FILEPATH=$ftgl_rootdir/lib/libftgl.lib"
      fi
      ;;
    Darwin)
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS -I/opt/X11/include'"
      if test -n "$ftgl_rootdir"; then
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_LIBRARY:FILEPATH=$ftgl_rootdir/lib/libftgl.dylib"
      fi
      ;;
    Linux)
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DRAW:BOOL=ON"
      if test -n "$ftgl_rootdir"; then
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_LIBRARY:FILEPATH=$ftgl_rootdir/lib/libftgl.so"
        OCE_ENV="$OCE_ENV LD_RUN_PATH=$ftgl_rootdir/lib"
      fi
      ;;
  esac
# Cannot disable X11 or will not build TKMeshVS, which is needed
# for salomesh in freecad.
if false; then
  case `uname` in
    Darwin) OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DISABLE_X11:BOOL=TRUE";;
  esac
fi

# OCE does not have all dependencies right, so needs nmake
  local buildargs=
  if [[ `uname` =~ CYGWIN ]]; then
     buildargs="-m nmake"
  fi

# Configure and build
  if bilderConfig oce $OCE_BUILD "-DOCE_INSTALL_INCLUDE_DIR:STRING=include $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $OCE_ADDL_ARGS $OCE_OTHER_ARGS" "" "$OCE_ENV"; then
    bilderBuild $buildargs oce $OCE_BUILD "$OCE_MAKEJ_ARGS" "$OCE_ENV"
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

