#!/bin/bash
#
# Version and build information for blender
# Get via
# svn co https://svn.blender.org/svnroot/bf-blender/branches/carve_booleans/ bf-blender
#
# Building: http://wiki.blender.org/index.php/Dev:Doc/Building_Blender
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
  CYGWIN* | Darwin-11.*) BLENDER_BLDRVERSION_STD=1.4.0;;
  *) BLENDER_BLDRVERSION_STD=1.4.0;;
esac
BLENDER_BLDRVERSION_EXP=1.4.0

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Can add builds in package file only if no add builds defined.
BLENDER_DESIRED_BUILDS=${BLENDER_DESIRED_BUILDS:-"ser"}
# Remove builds based on OS here, as this decides what can build.
computeBuilds blender

# Add in superlu all the time.  May be needed elsewhere
BLENDER_DEPS=${BLENDER_DEPS:-"cmake"}
BLENDER_UMASK=002

######################################################################
#
# Launch blender builds.
#
######################################################################

#
# Get blender using hg
#
getBlender() {
  if ! which hg 1>/dev/null 2>&1; then
    techo "WARNING: hg not in path.  Cannot get blender."
  fi
  if ! test -d blender; then
    cmd="hg clone hg clone https://code.google.com/p/blender"
    echo $cmd
    $cmd
  else
    cmd="cd blender"
    echo $cmd
    $cmd
    cmd="hg pull"
    echo $cmd
    $cmd
    cd - 1>/dev/null 2>&1
  fi
}

#
# Build blender
#
buildBlender() {

# Try to get blender from repo
  (cd $PROJECT_DIR; getBlender)

# If no subdir, done.
  if ! test -d $PROJECT_DIR/blender; then
    return 1
  fi

# Get version and proceed
  getVersion blender

  if bilderPreconfig -c blender; then

# Need to save installation directory for post installation
    BLENDER_SER_INSTALL_DIR=$INSTALL_DIR

# Check for install_dir installation
    if test "$CONTRIB_DIR" != "$INSTALL_DIR" -a -e $INSTALL_DIR/blender; then
      techo "WARNING: blender is installed in $INSTALL_DIR."
    fi

# Build the shared libs
    if bilderConfig blender ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=TRUE $BLENDER_SER_OTHER_ARGS"; then
      bilderBuild blender ser "$BLENDER_MAKEJ_ARGS"
    fi

  fi

}

######################################################################
#
# Test blender
#
######################################################################

testBlender() {
  techo "Not testing blender."
}

######################################################################
#
# Install blender
#
######################################################################

installBlender() {
  if bilderInstall -p -r blender ser; then
    case `uname` in
      Darwin)
        cd $BLENDER_SER_INSTALL_DIR/blender-${BLENDER_BLDRVERSION}-ser/bin
        for i in *; do
# Needs to be more general by finding the name of the library
          cmd="install_name_tool -change libblender.2.0.dylib @rpath/libblender.2.0.dylib $i"
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

