#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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

setAtlasTriggerVars() {
  ATLAS_BLDRVERSION_STD=${ATLAS_BLDRVERSION_STD:-"3.10.2"}
# Atlas 3.11.17 cannot be built with gcc 4.1.2 (the default on qalinux)
# or gcc 4.2.4. Both compilers seg fault when building Atlas.
  ATLAS_BLDRVERSION_EXP=${ATLAS_BLDRVERSION_EXP:-"3.10.2"}
  if test -z "$ATLAS_BUILDS" && $BUILD_ATLAS; then
    case `uname` in
      CYGWIN*)
        if test -n "$FC"; then
          ATLAS_BUILDS=${ATLAS_BUILDS},ser
        else
          : # ATLAS_BUILDS=NONE
        fi
        if ! isCcPyc; then
# Do this way, as ser contains sersh
          ATLAS_BUILDS=${ATLAS_BUILDS},pycsh
        fi
        ATLAS_BUILDS=${ATLAS_BUILDS},clp
        ;;
      Darwin)
        ATLAS_BUILDS=NONE
        ;;
      Linux)
        ATLAS_BUILDS=ser,sersh
        addPycshBuild atlas
        # addBenBuild atlas # Have no ben build
        ;;
    esac
  fi
# Below needed for determining installations prior to bilderPreconfig
  computeVersion atlas
  trimvar ATLAS_BUILDS ','
# Atlas no longer depends on lapack or clapack, as it builds them
  # ATLAS_DEPS=lapack
}
setAtlasTriggerVars

######################################################################
#
# Find Atlas 
#
######################################################################

findAtlas() {
  if $ATLAS_INSTALLED; then
    findBlasLapack
  fi
}

