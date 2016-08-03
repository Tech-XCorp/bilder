#!/bin/bash
#
# Build information for sortedcontainers
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in sortedcontainers_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/sortedcontainers_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSortedContainersNonTriggerVars() {
  SORTEDCONTAINERS_UMASK=002
}
setSortedContainersNonTriggerVars

#####################################################################
#
# Build sortedcontainers
#
######################################################################

buildSortedContainers() {

# Check for build need
  if ! bilderUnpack sortedcontainers; then
    return 1
  fi

# Build away
  SORTEDCONTAINERS_ENV="$DISTUTILS_ENV"
  techo -2 SORTEDCONTAINERS_ENV = $SORTEDCONTAINERS_ENV
  bilderDuBuild sortedcontainers '-' "$SORTEDCONTAINERS_ENV"

}

######################################################################
#
# Test sortedcontainers
#
######################################################################

testSortedContainers() {
  techo "Not testing sortedcontainers."
}

######################################################################
#
# Install sortedcontainers
#
######################################################################

installSortedContainers() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/sortedcontainers/formats.html
# It seems that packages are using sortedcontainers which creates eggs, which
# for some reason we are not finding.  Moreover, different packages are
# installing difference eggs of their dependencies.
  local SORTEDCONTAINERS_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/sortedcontainers.files'"
  if bilderDuInstall sortedcontainers "$SORTEDCONTAINERS_INSTALL_ARGS" "$SORTEDCONTAINERS_ENV"; then
    : # chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}

