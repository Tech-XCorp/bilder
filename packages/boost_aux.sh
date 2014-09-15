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

getBoostTriggerVars() {
  BOOST_BLDRVERSION_STD=1_53_0
# 1_55_0 must be patched to build with NO_COMPRESSION:
#   https://svn.boost.org/trac/boost/ticket/9156
# Boost 1_55_0 does not build using gcc 4.1.2, nor does it seem to build
# on Lion and Snow Leopard.
# For now we're sticking with boost 1_53_0.
  BOOST_BLDRVERSION_EXP=1_53_0
  # BOOST_BLDRVERSION_EXP=1_55_0
  if test -z "$BOOST_BUILDS"; then
    if test -z "$BOOST_DESIRED_BUILDS"; then
      BOOST_DESIRED_BUILDS=ser,sersh
    fi
    if [[ `uname` =~ CYGWIN ]]; then
      BOOST_DESIRED_BUILDS=$BOOST_DESIRED_BUILDS,sermd
    fi
    computeBuilds boost
    addCc4pyBuild boost
  fi
# It does not hurt to add deps that do not get built
# (e.g., Python on Darwin and CYGWIN).
# Only certain builds depend on Python.
  BOOST_DEPS=Python,bzip2
}
getBoostTriggerVars

######################################################################
#
# Find boost
#
######################################################################

findBoost() {
  local boost_lib_prefix=boost
  if [[ `uname` =~ CYGWIN ]] && [[ "$BOOST_BUILD" == sersh ]]; then
    boost_lib_prefix=libboost
  fi 
  findContribPackage Boost ${boost_lib_prefix}_math_tr1;;
}

