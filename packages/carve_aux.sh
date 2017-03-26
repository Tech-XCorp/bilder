#!/bin/sh
######################################################################
#
# @file    carve_aux.sh
#
# @brief   # Trigger vars and find information for carve.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# Cloned at 475:be054bc7ed86
# Pulled in changes via
cat >/dev/null <<EOF
hg pull -r tip https://code.google.com/p/carve
hg merge tip
hg commit -m "Commit changes from remote repo."
hg push
EOF
# Changes now in cary-carve4bilder
# Blender maintains carve in the repo
#   https://svn.blender.org/svnroot/bf-blender/trunk/blender/extern/carve
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setCarveTriggerVars() {
  CARVE_REPO_URL=https://code.google.com/r/cary-carve4bilder
  CARVE_UPSTREAM_URL=https://code.google.com/p/carve
# Carve builds only shared
  CARVE_DESIRED_BUILDS=${CARVE_DESIRED_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  computeBuilds carve
  CARVE_DEPS=cmake,mercurial
}
setCarveTriggerVars

######################################################################
#
# Find carve
#
######################################################################

findCarve() {
  :
}

