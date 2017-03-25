#!/bin/sh
######################################################################
#
# @file    cxx11def.sh
#
# @brief   Set the machine file for default builds
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

MACHINEFILE=
case `uname` in
  CYGWIN*) MACHINEFILE=cygwin.vs12;;
  Darwin) MACHINEFILE=darwin.clangcxx11;;
esac

