#!/bin/bash
#
# Version and build information for autotools
#
# $Id$
#
######################################################################

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

buildAutotools() {
  :
}

testAutotools() {
  echo "Not testing autotools."
}

installAutotools() {
  :
  # techo "WARNING: Quitting at end of installAutotools."; cleanup
}


