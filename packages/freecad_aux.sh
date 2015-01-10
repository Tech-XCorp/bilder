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

getFreecadTriggerVars() {
  FREECAD_BLDRVERSION=${FREECAD_BLDRVERSION:-"0.13.5443"}
  FREECAD_BUILDS=${FREECAD_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  FREECAD_BUILD=$FORPYTHON_SHARED_BUILD
  FREECAD_DEPS=pyside,shiboken,soqt,coin,pyqt,xercesc,eigen3,oce,boost,f2c
  FREECAD_UMASK=002
  FREECAD_REPO_URL=git://free-cad.git.sourceforge.net/gitroot/free-cad/free-cad
  FREECAD_UPSTREAM_URL=git://free-cad.git.sourceforge.net/gitroot/free-cad/free-cad
  FREECAD_WEBSITE_URL=http://www.freecadweb.org/
}
getFreecadTriggerVars

######################################################################
#
# No need to find freecad
#
######################################################################

findFreecad() {
  addtopathvar PATH $BLDR_INSTALL_DIR/freecad/bin
}

