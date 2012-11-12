#!/bin/bash
#
# Version and build information for oce
#
# $Id: oce.sh 6594 2012-09-01 15:12:46Z cary $
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

buildOce() {

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
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$BLDR_INSTALL_DIR/oce-$OCE_BLDRVERSION-ser"
    techo "WARNING: Building oce from the git repo."
  else
    bilderUnpack oce
    res=$?
    OCE_ADDL_ARGS="-DOCE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/oce-$OCE_BLDRVERSION-ser"
  fi

# If worked, proceed to configure and build
  if test $res = 0; then

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

# Configure and build
    if bilderConfig oce ser "-DOCE_INSTALL_INCLUDE_DIR:STRING=include $OCE_ADDL_ARGS $OCE_OTHER_ARGS"; then
      bilderBuild oce ser "$JMAKEARGS" "$OCE_ENV"
    fi

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

