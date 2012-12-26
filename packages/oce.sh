#!/bin/bash
#
# Version and build information for oce
#
# $Id$
#
######################################################################

# For now, just recording what to get here
cat >/dev/null <<EOF
The OCE project is at https://github.com/tpaviot/oce

To get ftgl, build composerall with "-E FTGL_BUILDS=ser"

More packages:

yum install tcl-devel
yum install tk-devel

git clone git://github.com/tpaviot/oce.git
cd oce
mkdir ser && cd ser
cmake \
  -DOCE_INSTALL_PREFIX:PATH=/contrib/oce \
  -DFTGL_INCLUDE_DIR:PATH=/contrib/ftgl/include \
  -DFTGL_LIBRARY:FILEPATH=/contrib/ftgl/lib/libftgl.so \
  -DOCE_DRAW:BOOL=ON \
  -DOCE_INSTALL_INCLUDE_DIR:STRING=include \
  ..
EOF

######################################################################
#
# Version
#
######################################################################

OCE_BLDRVERSION=${OCE_BLDRVERSION:-"0.10.1-r747"}

######################################################################
#
# Other values
#
######################################################################

OCE_BUILDS=${OCE_BUILDS:-"NONE"}
OCE_DEPS=ftgl
OCE_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/oce/bin

######################################################################
#
# Launch oce builds.
#
######################################################################

#
# Get oce using git.  This gives a version that does not
# build on Windows.
#
getGitOce() {
  if ! which git 1>/dev/null 2>&1; then
    techo "WARNING: git not in path.  Cannot get oce."
    return
  fi
  cd $PROJECT_DIR
  if ! test -d oce/.git; then
    techo "No git checkout of oce."
    if test -d oce; then rm -rf oce.sav; mv oce oce.sav; fi
    cmd="git clone git://github.com/tpaviot/oce.git"
    techo "$cmd"
    $cmd
  else
    cmd="cd oce"
    techo "$cmd"
    $cmd
    cmd="git pull"
    techo "$cmd"
    $cmd
    cd - 1>/dev/null 2>&1
  fi
}

buildOce() {

# Try to get oce from repo
  (cd $PROJECT_DIR; getGitOce)

# If no subdir, done.
  if ! test -d $PROJECT_DIR/oce; then
    techo "WARNING: oce dir not found. Building from package."
  fi

# Get oce
  cd $PROJECT_DIR
  local res=
  local OCE_ADDL_ARGS=
  if test -d oce; then
    if $SVNUP; then
      (cd oce; git pull)
    fi
    getVersion oce
    bilderPreconfig oce
    res=$?
    if test $res != 0; then
      return 1
    fi
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$BLDR_INSTALL_DIR/oce-$OCE_BLDRVERSION-ser"
    techo "NOTE: Building oce from the git repo."
  else
    bilderUnpack oce
    res=$?
    if test $res != 0; then
      return 1
    fi
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/oce-$OCE_BLDRVERSION-ser"
  fi

# Determine other configure args
  local FTGL_DIR=
  if test -e $CONTRIB_DIR/ftgl; then
    FTGL_DIR=`(cd $CONTRIB_DIR/ftgl; pwd -P)`
  fi
  local OCE_ENV=
  if test -n "$FTGL_DIR"; then
    OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_INCLUDE_DIR:PATH=$FTGL_DIR/include"
    case `uname` in
      Darwin)
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_LIBRARY:FILEPATH=$FTGL_DIR/lib/libftgl.dylib"
        ;;
      Linux)
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DFTGL_LIBRARY:FILEPATH=$FTGL_DIR/lib/libftgl.so -DOCE_DRAW:BOOL=ON"
        OCE_ENV="LD_RUN_PATH=$FTGL_DIR/lib"
        ;;
    esac
  fi
  case `uname` in
    Darwin) OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DISABLE_X11:BOOL=TRUE";;
  esac

# Configure and build
  if bilderConfig oce ser "-DOCE_INSTALL_INCLUDE_DIR:STRING=include $OCE_ADDL_ARGS $OCE_OTHER_ARGS"; then
    bilderBuild oce ser "$OCE_MAKEJ_ARGS" "$OCE_ENV"
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
  if bilderInstall oce ser; then
    : # Probably need to fix up dylibs here
  fi
  # techo "WARNING: Quitting at end of oce.sh."; cleanup
}

