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

setGraphvizTriggerVars() {
  GRAPHVIZ_BLDRVERSION_STD=${GRAPHVIZ_BLDRVERSION_STD:-"2.38.0"}
  GRAPHVIZ_BLDRVERSION_EXP=${GRAPHVIZ_BLDRVERSION_EXP:-"2.38.0"}
  if test -z "$GRAPHVIZ_BUILDS"; then
    case `uname` in
      CYGWIN*) ;;
      Darwin) GRAPHVIZ_BUILDS="ser";;
      Linux) GRAPHVIZ_BUILDS="ser";;
    esac
  fi
  GRAPHVIZ_DEPS=libgd,libtool
}
setGraphvizTriggerVars

######################################################################
#
# Find graphviz
#
######################################################################

findGraphviz() {
  if test -x $CONTRIB_DIR/graphviz/bin/dot; then
    (cd $CONTRIB_DIR/bin; ln -sf ../graphviz/bin/dot .)
  fi
}

