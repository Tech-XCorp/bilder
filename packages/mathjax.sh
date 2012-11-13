#!/bin/bash
#
# Version and build information for MathJax
#
# $Id$
#
######################################################################

######################################################################
#
# MathJax -- modeled after jsMath but fixes all of the annoyances.
#
######################################################################

MATHJAX_BLDRVERSION=${MATHJAX_BLDRVERSION:-"1.0.1a"}

######################################################################
#
# Other values
#
######################################################################

MATHJAX_BUILDS=${MATHJAX_BUILDS:-"full,lite"}
MATHJAX_DEPS=

#####################################################################
#
# Copy a MathJax build into place
#
# Args
# 1: build   (should be lite or full)
#
# return 0 if successfully installed
# return 1 if not installed
#
######################################################################

copyMathjax() {
  umasksav=`umask`
  umask 002
  local bld=$1
# Set defaults for full version
  local idir=$BLDR_INSTALL_DIR
  local mjsub=userdocs/MathJax
  if test "$1" == "lite"; then
    idir=$CONTRIB_DIR
    mjsub=MathJax-${MATHJAX_BLDRVERSION}-$bld
  else 
    mkdir -p $idir/userdocs
  fi 
  if shouldInstall -i $CONTRIB_DIR MathJax-${MATHJAX_BLDRVERSION} $bld; then
# Try twice for cygwin
    cmd="rmall $idir/$mjsub"
    techo "$cmd"
    if ! $cmd; then
      techo "$cmd"
      if ! $cmd; then
        techo "Unable to remove $idir/$mjsub.  Check permissions?"
      fi
    fi
# Copy to get group correct, as top dir is setgid
    local res=
    cmd="cp -R $BUILD_DIR/MathJax-${MATHJAX_BLDRVERSION} $idir/$mjsub"
    techo "$cmd"
# Copy and fix any perms
    if $cmd && setOpenPerms $idir/$mjsub; then
      if test "$1" == "lite"; then 
        mkLink $idir $mjsub MathJax-$bld
      fi
      ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR MathJax,$bld
      techo "MathJax-$bld installed."
      installations="$installations MathJax-$bld"
      res=0
    else
      techo "MathJax-$bld failed to install."
      installFailures="$installFailures MathJax-$bld"
      res=1
    fi
  else
    res=1
  fi
  umask $umasksav
  return $res
}

#####################################################################
#
# Launch MathJax builds.
#
######################################################################

buildMathjax() {
  if bilderUnpack MathJax; then

#  "build" full version (really just a copy)
    copyMathjax full

# lite "build"
    if copyMathjax lite; then
      cmd="rmall $CONTRIB_DIR/MathJax-${MATHJAX_BLDRVERSION}-lite/fonts/HTML-CSS/TeX/png"
      techo "$cmd"
      if ! $cmd; then
        techo "$cmd"
      fi
      if ! $cmd; then
        techo "Failed to clean out MathJax-lite.  Check permissions."
        installFailures="$installFailures MathJax-lite"
      fi
# Fix up font size on windows
      case `uname` in
        CYGWIN*)
          techo "MathJax-lite: Changing scale to 120 on windows to boost size of equations."
          sed 's/scale: 100,/scale: 120,/' -i $CONTRIB_DIR/MathJax-lite/config/MathJax.js
          ;;
      esac
      mkLink $CONTRIB_DIR MathJax-${MATHJAX_BLDRVERSION}-lite MathJax-lite
    fi

  fi
  # techo exit; exit
}

######################################################################
#
# Test MathJax
#
######################################################################

testMathjax() {
  techo "Not testing MATHJAX."
}

######################################################################
#
# Install MathJax
#
######################################################################

installMathjax() {
  MATHJAX_LITE_INSTALL_DIR=$CONTRIB_DIR/MathJax-lite
  MATHJAX_FULL_INSTALL_DIR=$BLDR_INSTALL_DIR/userdocs/MathJax

  # techo "Quitting at end of mathjax.sh."; exit
}


