#!/bin/bash -lxe
#
# Java needs memory setting on freedom
#
# $Id: java.sh 5268 2012-02-20 17:56:22Z cary $
#

java -Xmx1850M $*
