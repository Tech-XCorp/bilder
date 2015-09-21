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
      Darwin)
        if grep -q '"SV' /System/Library/Perl/5.18/darwin-thread-multi-2level/CORE/perl.h; then
          techo "WARNING: [$FUNCNAME] /System/Library/Perl/5.18/darwin-thread-multi-2level needs to be patched with bilder/extras/osxperl.patch."
        else
          GRAPHVIZ_BUILDS=${GRAPHVIZ_BUILDS:-"${FORPYTHON_STATIC_BUILD}"}
        fi
        ;;
      Linux) GRAPHVIZ_BUILDS=${GRAPHVIZ_BUILDS:-"${FORPYTHON_STATIC_BUILD}"};;
    esac
  fi
  computeBuilds graphviz
  if test -n "$GRAPHVIZ_BUILDS"; then
    case `uname` in
      Linux)
        if ! perl -e 'use ExtUtils::Embed' 2>/dev/null; then
          echo "WARNING: [$FUNCNAME] Perl module, ExtUtils::Embed, may not be installed."
        fi    
        ;;
    esac
  fi
# pkgconfig is needed to get pkg.m4, which is needed upon autoreconf.
  GRAPHVIZ_DEPS=libgd,Python,pkgconfig,autotools
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

