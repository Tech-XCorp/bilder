#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
# Repackage for bilder (do on Linux to avoid resource files):
#   tar xzf MesaLib-7.10.2.tar.gz
#   mv Mesa-7.10.2 mesa-7.10.2
#   tar czf mesa-7.10.2.tar.gz mesa-7.10.2
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

setMesaTriggerVars() {
  MESA_BLDRVERSION_STD=${MESA_BLDRVERSION_STD:-"7.8.2"}
  MESA_BLDRVERSION_EXP=${MESA_BLDRVERSION_EXP:-"7.8.2"}
  if test -z "$MESA_DESIRED_BUILDS"; then
    case `uname`-`uname -r` in
      CYGWIN* | Darwin-12*) ;;
      *) MESA_DESIRED_BUILDS=mgl,os;;
    esac
  fi
  computeBuilds mesa
  MESA_DEPS=
  MESA_UMASK=002
}
setMesaTriggerVars

######################################################################
#
# Find mesa
#
######################################################################

findMesa() {
  :
}

