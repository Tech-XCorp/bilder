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
      Darwin | Linux) GRAPHVIZ_BUILDS=${GRAPHVIZ_BUILDS:-"${FORPYTHON_STATIC_BUILD}"};;
    esac
  fi
  GRAPHVIZ_DEPS=libgd,python,autotools
}
setGraphvizTriggerVars

######################################################################
#
# Find graphviz
#
######################################################################

findGraphviz() {
# Not needed, done at installation
if false; then
  if test -x $CONTRIB_DIR/graphviz-${FORPYTHON_STATIC_BUILD}/bin/dot; then
    (cd $CONTRIB_DIR/bin; ln -sf ../graphviz-${FORPYTHON_STATIC_BUILD}/bin/dot .)
  fi
fi
}

