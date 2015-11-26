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

setOpensslTriggerVars() {
  # OPENSSL_BLDRVERSION_STD=${OPENSSL_BLDRVERSION_STD:-"1.0.1c"}
  OPENSSL_BLDRVERSION_STD=${OPENSSL_BLDRVERSION_STD:-"1.0.2d"}
  OPENSSL_BLDRVERSION_EXP=${OPENSSL_BLDRVERSION_EXP:-"1.0.2d"}
  case `uname` in
    Darwin)
      case `uname -r` in
        1[5-9]*)
# OpenSSL disappeared in El Capitan
          OPENSSL_BUILDS=ser
          ;;
      esac
    ;;
  esac
  computeBuilds openssl
  OPENSSL_BUILDS=${OPENSSL_BUILDS:-"NONE"}
  OPENSSL_DEPS=
}
setOpensslTriggerVars

######################################################################
#
# Find oce
#
######################################################################

findOpenssl() {
  :
}

