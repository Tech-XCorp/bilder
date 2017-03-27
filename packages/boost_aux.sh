#!/bin/sh
######################################################################
#
# @file    boost_aux.sh
#
# @brief   Trigger vars and find information for boost.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# Make tarball:
# tar xf boost_1_63_0.tar.bz2
# mv boost_1_63_0 boost-1_63_0
# env COPYFILE_DISABLE=true tar cjf boost-1_63_0.tar.bz2 boost-1_63_0
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
  BOOST_BLDRVERSION_STD=${BOOST_BLDRVERSION_STD:-"1_62_0"}
  BOOST_BLDRVERSION_EXP=${BOOST_BLDRVERSION_EXP:-"1_62_0"}
  if test -z "$BOOST_BUILDS"; then
    if test -z "$BOOST_DESIRED_BUILDS"; then
      BOOST_DESIRED_BUILDS=ser,sersh
    fi
    if [[ `uname` =~ CYGWIN ]]; then
      BOOST_DESIRED_BUILDS=$BOOST_DESIRED_BUILDS,sermd
    fi
    computeBuilds boost
    addPycstBuild boost
    addPycshBuild boost
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
  findContribPackage Boost ${boost_lib_prefix}_math_tr1
}

