#!/bin/sh
#
# Set the machine file for default builds
#
# $Id$
#

MACHINEFILE=
case `uname` in
  CYGWIN*) MACHINEFILE=cygwin.vs12;;
  Darwin) MACHINEFILE=darwin.clangcxx11;;
esac

