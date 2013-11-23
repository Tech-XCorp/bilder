#!/bin/bash
#
# Version and build information for cmake
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

case `uname` in
  CYGWIN*)
    # fortran binding issues with 2.8.10.1 on windows
    CMAKE_BLDRVERSION_STD=2.8.9
    CMAKE_BLDRVERSION_EXP=2.8.12.1
    ;;
  *)
    CMAKE_BLDRVERSION_STD=2.8.10.1
    CMAKE_BLDRVERSION_EXP=2.8.12.1
    ;;
esac


######################################################################
#
# Other values
#
######################################################################

CMAKE_BUILDS=${CMAKE_BUILDS:-"ser"}
CMAKE_DEPS=${CMAKE_DEPS:-""}
CMAKE_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/cmake/bin

######################################################################
#
# Launch cmake builds.
#
######################################################################

buildCmake() {

# Configure and build
  if bilderUnpack cmake; then

# Build cmake with cmake if present
    local CMAKE_CONFIG_ARGS=
    local CONFIGURE_ARGS=
    CMAKE_BILDER_ENV=
    if cmakepath=`which cmake 2>/dev/null`; then
      local cmakever=`"$cmakepath" --version | sed 's/^cmake version //'`
      techo "$cmakepath is version $cmakever."
      case "$cmakever" in
        2.8.[2-9] | 2.8.[1-9][0-9] | 2.8.1?.?)
          CMAKE_CONFIG_ARGS=-c
          CONFIGURE_ARGS="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
          ;;
        *)
          techo "$cmakepath version, $cmakever, not recent enough to configure cmake.  Using the cmake's configure."
          CMAKE_BILDER_ENV="$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC"
          ;;
      esac
    else
      CMAKE_BILDER_ENV="$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC"
    fi
    techo "cmake = $cmakepath."

# Determine cmake args
# This variable needs to be namespaced
    local CMAKE_CONFIG_ADDL_ARGS=
    case `uname` in
      CYGWIN*)
        if test -z "$CMAKE_CONFIG_ARGS"; then
          techo "WARNING: cmake of sufficient version not found in your path."
          techo "WARNING: Update cmake.sh for allowed versions or install cmake from KitWare and make sure it is found in your path before the cygwin version."
          return 1
        fi
        if [[ $cmakepath =~ "^/usr/" ]]; then
          techo "WARNING: Cannot use CYGWIN's cmake, $cmakepath, to build cmake."
          techo "WARNING: Install cmake from KitWare and make sure it is found in your path before the cygwin version."
          techo "WARNING: Will try to move bad cmake aside."
          local cmd="mv '$cmakepath.exe' '$cmakepath.exe.cygwin'"
          techo "$cmd"
          eval "$cmd"
          return 1
        fi
# On CYGWIN, need to specify cl compilers so that the built cmake can
# make windows generators.
        # CMAKE_CONFIG_ADDL_ARGS="$CMAKE_COMPILERS_SER"
        local pycomp=`cygpath -am "$PYC_CC"`
        pycomp="${pycomp%.exe}".exe
        CMAKE_CONFIG_ADDL_ARGS="-DCMAKE_C_COMPILER:FILEPATH='$pycomp'"
        pycomp=`cygpath -am "$PYC_CXX"`
        pycomp="${pycomp%.exe}".exe
        CMAKE_CONFIG_ADDL_ARGS="$CMAKE_CONFIG_ADDL_ARGS -DCMAKE_CXX_COMPILER:FILEPATH='$pycomp'"
        ;;
      Darwin)
        ;;
      *)
# Below needed to get intermediate (bootstrap) cmake to work with
# non-system compilers
        if test -n "$PYC_LD_LIBRARY_PATH" && ! echo $LD_LIBRARY_PATH | egrep -q "(^|:)$PYC_LD_LIBRARY_PATH($|:)"; then
          CMAKE_LD_LIBRARY_PATH="$PYC_LD_LIBRARY_PATH:$LD_LIBRARY_PATH"
          trimvar CMAKE_LD_LIBRARY_PATH ':'
          if test -n "$CMAKE_LD_LIBRARY_PATH"; then
            CMAKE_BILDER_ENV="$CMAKE_BILDER_ENV LD_LIBRARY_PATH=$CMAKE_LD_LIBRARY_PATH"
          fi
        fi
        if test -n "$PYC_LD_RUN_PATH" && ! echo $LD_RUN_PATH | egrep -q "(^|:)$PYC_LD_RUN_PATH($|:)"; then
          CMAKE_LD_RUN_PATH="$PYC_LD_RUN_PATH:$LD_RUN_PATH"
          trimvar CMAKE_LD_RUN_PATH ':'
          if test -n "$CMAKE_LD_RUN_PATH"; then
            CMAKE_BILDER_ENV="$CMAKE_BILDER_ENV LD_RUN_PATH=$CMAKE_LD_RUN_PATH"
          fi
        fi
        trimvar CMAKE_BILDER_ENV ' '
        ;;
    esac
    trimvar CMAKE_CONFIG_ARGS ' '
    trimvar CMAKE_MAKE_ARGS ' '

# Configure and build
    if bilderConfig $CMAKE_CONFIG_ARGS cmake ser "$CONFIGURE_ARGS $CMAKE_CONFIG_ADDL_ARGS $CMAKE_CONFIG_OTHER_ARGS" "" "$CMAKE_BILDER_ENV"; then
      bilderBuild cmake ser "$CMAKE_MAKE_ARGS $CMAKE_BILDER_ENV"
    else
      res=$?
      if test $res != 99; then
        techo "WARNING: $cmakepath cannot configure cmake."
        if [[ $cmakepath =~ "$CONTRIB_DIR" ]]; then
          techo "WARNING: Will remove old and exit."
          cmd="rm -rf $CONTRIB_DIR/cmake* $CONTRIB_DIR/bin/cmake"
          techo "$cmd"
          $cmd
          cmd="$BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR cmake,ser"
          techo "$cmd"
          $cmd
        else
          techo "WARNING: $cmakepath does not match $CONTRIB_DIR."
        fi
        techo "Quitting."; cleanup
      fi
    fi
  fi

}

######################################################################
#
# Test cmake
#
######################################################################

testCmake() {
  techo "Not testing cmake."
}

######################################################################
#
# Install cmake
#
######################################################################

installCmake() {

# When a second installer overinstalls another's installation, we get
# errors of the form,
#   file INSTALL cannot set permissions on
#   "/usr/local/contrib/cmake-2.8.6-ser/share/cmake-2.8/Modules"
# because the second installer cannot set the permissions of the directories
# created by the first installer.  We cannot use '-r' to blow away the
# installation to fix this, as then there is no cmake available to do the
# installation.  We have to wait on the build, then create a directory
# owned by the builder, then continue with the installation.
  local cmakesharedir=$CONTRIB_DIR/cmake-$CMAKE_BLDRVERSION-ser/share
  rm -rf $cmakesharedir.bak  # Possibly there from previous attempt.
  local res=
  if test -d $cmakesharedir; then
    waitAction cmake-ser
    res=$?
    if test "$res" = 0; then
      local cmd="mv $cmakesharedir $cmakesharedir.bak"
      techo "$cmd"
      $cmd
      local cmd="cp -R $cmakesharedir.bak $cmakesharedir"
      techo "$cmd"
      $cmd
    fi
  fi

  local noarg=
# Try command.  If fails, restore as best as possible
  cmd="bilderInstall cmake ser '' '' '$CMAKE_BILDER_ENV'"
  techo "$cmd"
  if eval "$cmd"; then
# Worked.  Remove detritus
    cmd="rm -rf $cmakesharedir.bak"
    techo "$cmd"
    $cmd
    setOpenPerms $CONTRIB_DIR/cmake-$CMAKE_BLDRVERSION-ser
  elif test -d $cmakesharedir -a -d $cmakesharedir.bak; then
# Share dir installed, but not all.
    techo "WARNING: partial installation of cmake.  Old share dir in $cmakesharedir.bak."
  elif test -d $cmakesharedir.bak; then
# Share dir not installed, so restore
    cmd="rm -rf $cmakesharedir"
    techo "$cmd"
    $cmd
    cmd="mv $cmakesharedir.bak $cmakesharedir"
    techo "$cmd"
    $cmd
  fi

# Recompute cmake
  CMAKE=`which cmake`
  # techo "WARNING: Quitting at end of cmake.sh."; cleanup

}

