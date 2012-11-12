#!/bin/bash
#
# Version and build information for a python tutorial
#
# $Id: tutorial_python.sh 4901 2012-01-14 13:34:01Z cary $
#
######################################################################

######################################################################
#
# Python tutorial -- modeled after jsMath but fixes all of the annoyances.
#
######################################################################

TUTORIAL_PYTHON_BLDRVERSION=${TUTORIAL_PYTHON_BLDRVERSION:-"0.0.1"}

######################################################################
#
# Other values
#
######################################################################

TUTORIAL_PYTHON_BUILDS=${TUTORIAL_PYTHON_BUILDS:-"cc4py"}
TUTORIAL_PYTHON_DEPS=

#####################################################################
#
# Copy a Python tutorial build into place
#
# Args
# 1: build
#
# return 0 if successfully installed
# return 1 if not installed
#
######################################################################

copyTutorialpython() {
  local bld=$1
  if shouldInstall -i $CONTRIB_DIR tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION} $bld; then
# Try twice for cygwin
    cmd="rmall $CONTRIB_DIR/tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION}-$bld"
    techo "$cmd"
    if ! $cmd; then
      techo "$cmd"
      $cmd
    fi
# Copy to get group correct, as top dir is setgid
    cmd="cp -R $BUILD_DIR/tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION} $CONTRIB_DIR/tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION}-$bld"
    techo "$cmd"
# Copy and fix any perms
    if $cmd && setOpenPerms $CONTRIB_DIR/tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION}-$bld; then
      mkLink $CONTRIB_DIR tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION}-$bld tutorial_python-$bld
      ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR tutorial_python,$bld
      techo "tutorial_python-$bld installed."
      installations="$installations tutorial_python-$bld"
      return 0
    fi
    techo "tutorial_python-$bld failed to install."
    installFailures="$installFailures tutorial_python-$bld"
  fi
  return 1
}

#####################################################################
#
# Launch tutorial_python builds.
#
######################################################################

buildTutorialpython() {
  if bilderUnpack tutorial_python; then

# cc4py build
    if copyTutorialpython cc4py; then
# Remove old-style installation
      cmd="rmall $CONTRIB_DIR/tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION}"
      techo "$cmd"
      if ! $cmd; then
        techo "$cmd"
        $cmd
      fi
# Make link to default
      mkLink $CONTRIB_DIR tutorial_python-${TUTORIAL_PYTHON_BLDRVERSION}-cc4py tutorial_python
    fi

  fi
  # techo exit; exit
}

######################################################################
#
# Test tutorial_python
#
######################################################################

testTutorialpython() {
  techo "Not testing TUTORIAL_PYTHON."
}

######################################################################
#
# Install Tutorialpython
#
######################################################################

installTutorialpython() {
# JRC: This will do nothing as no build was launched
  : # bilderInstall Tutorialpython
}


