#!/bin/bash -lxe
######################################################################
#
# @file    java.sh
#
# @brief   Java needs memory setting on freedom
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

java -Xmx1850M $*
