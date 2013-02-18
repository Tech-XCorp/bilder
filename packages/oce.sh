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

# OCE_DESIRED_BUILDS=${OCE_DESIRED_BUILDS:-"sersh"}
computeBuilds oce
addCc4pyBuild oce
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
  cd $PROJECT_DIR
  if test -d oce/.git; then
    if $SVN_UP || test -n "$JENKINS_FSROOT"; then
      cmd="cd oce"
      techo "$cmd"
      $cmd
      cmd="git pull"
      techo "$cmd"
      $cmd
    fi
  else
    cd - 1>/dev/null 2>&1
    techo "No git checkout of oce."
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
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$BLDR_INSTALL_DIR/oce-$OCE_BLDRVERSION-sersh"
    techo "NOTE: Building oce from the git repo."
  else
    if ! bilderUnpack oce; then
      return 1
    fi
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/oce-$OCE_BLDRVERSION-sersh"
  fi

# Determine other configure args
  local FTGL_DIR=
  if test -e $CONTRIB_DIR/ftgl-sersh; then
    FTGL_DIR=`(cd $CONTRIB_DIR/ftgl-sersh; pwd -P)`
  fi
  if test -n "$FTGL_DIR"; then
    OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_INCLUDE_DIR:PATH=$FTGL_DIR/include"
  fi
  local x11dir=
  for dir in /opt/X11 /usr/X11R6; do
    if test -d $dir; then
      x11dir=$dir
      break
    fi
  done
  local OCE_ENV=
  case `uname` in
    Darwin)
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS -I/opt/X11/include'"
      if test -n "$FTGL_DIR"; then
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_LIBRARY:FILEPATH=$FTGL_DIR/lib/libftgl.dylib"
      fi
      if test -n "$x11dir"; then
        OCE_ENV="FREETYPE_DIR=$x11dir"
      fi
      ;;
    Linux)
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DRAW:BOOL=ON"
      if test -n "$FTGL_DIR"; then
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_LIBRARY:FILEPATH=$FTGL_DIR/lib/libftgl.so"
        OCE_ENV="LD_RUN_PATH=$FTGL_DIR/lib"
      fi
      ;;
  esac
# Cannot disable X11 or will not get TKMeshVS built,
# which is needed for salomesh in freecad.
if false; then
  case `uname` in
    Darwin) OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DISABLE_X11:BOOL=TRUE";;
  esac
fi

# Configure and build
  if bilderConfig oce sersh "-DOCE_INSTALL_INCLUDE_DIR:STRING=include $CMAKE_COMPILERS_PYC $OCE_ADDL_ARGS $OCE_OTHER_ARGS" "" "$OCE_ENV"; then
    bilderBuild oce sersh "$OCE_MAKEJ_ARGS" "$OCE_ENV"
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
  if bilderInstall oce sersh; then
    : # Probably need to fix up dylibs here
  fi
  # techo "WARNING: Quitting at end of oce.sh."; cleanup
}

