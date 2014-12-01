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

setAutotoolsTriggerVars() {

  # Convenience package so that the components packages do not have to be
  # explicitly named.

  AUTOTOOLS_DEPS=libtool,automake,autoconf,m4

  # There are no actual builds, but we need to put something here to bilder
  # will follow the dependencies and build them.
  AUTOTOOLS_BUILDS=fake

  # If tools not installed under the libtool version, it needs rebuilding
  # to get them all installed in the same directory.
  # Libtool determines the installation prefix
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
  for adep in m4 autoconf automake; do
    if ! test -x $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/$adep; then
      $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR $adep,ser
    fi
  done
}
setAutotoolsTriggerVars

######################################################################
#
# Find autotools 
#
######################################################################

findAutotools() {
  :
}

