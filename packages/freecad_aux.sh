#!/bin/sh
######################################################################
#
# @file    freecad_aux.sh
#
# @brief   Trigger vars and find information for freecad.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
  FREECAD_DEPS=${FREECAD_DEPS:-"pivy,coin,xercesc,pyside,qt,oce,eigen3,boost"}
# is installed by homebrew
# nglib is installed by homebrew
# boost-python: just install boost with python?
# coin installed --without-soqt
# pyside-tools?
# freetype installed by home brew
  FREECAD_UMASK=002
  FREECAD_REPO_URL=https://github.com/FreeCAD/FreeCAD_sf_master.git
  FREECAD_UPSTREAM_URL=https://github.com/FreeCAD/FreeCAD_sf_master.git
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

