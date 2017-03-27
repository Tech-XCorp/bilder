#!/bin/sh
######################################################################
#
# @file    sphinx_numfig_aux.sh
#
# @brief   Trigger vars and find information for sphinx_numfig.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# This package was taken from bitbucket and put into sourceforge:
# https://svn.code.sf.net/p/numfig/code-0/trunk
#
# Create the tarball by running tarup.sh in the checked out repo.
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

setSphinx_numfigTriggerVars() {
  SPHINX_NUMFIG_BLDRVERSION=${SPHINX_NUMFIG_BLDRVERSION:-"r13"}
  SPHINX_NUMFIG_BUILDS=${SPHINX_NUMFIG_BUILDS:-"pycsh"}
  SPHINX_NUMFIG_DEPS=Sphinx
}
setSphinx_numfigTriggerVars

######################################################################
#
# Find xz
#
######################################################################

findSphinx_numfig() {
  :
}

