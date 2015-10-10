#!/bin/bash
#
# $Id$
#
# This documents the sequence of actions taken to get the packages
# needed for phonon to build at NERSC and Janus
#

CONTRIB_DIR=/global/project/projectdirs/facets/hopper/contrib-pgi-12.9
CONTRIB_DIR=/global/project/projectdirs/facets/edison/contrib-intel-13.0
CONTRIB_DIR=/global/project/projectdirs/facets/hopper/contrib-gcc-4.7
# Janus
CONTRIB_DIR=/projects/cary/contrib-gcc-4.7
CONTRIB_DIR=/global/project/projectdirs/facets/hopper/contrib-gcc-4.8
# Edison
CONTRIB_DIR=/global/project/projectdirs/vorpal/vpusers/cary/edison/contrib-gcc-4.9

exec() {
  echo $*
  $*
}

BUILD_GLIB2=false
BUILD_GLIB2=${BUILD_GLIB2:-"false"}
if $BUILD_GLIB2; then
  exec wget -N -nv http://ftp.gnome.org/pub/gnome/sources/glib/2.36/glib-2.36.4.tar.xz
  exec tar xJf glib-2.36.4.tar.xz
  exec mkdir glib-2.36.4/ser
  exec cd glib-2.36.4/ser
fi

# gstreamer
exec wget -N -nv http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-0.10.22.tar.bz2
exec tar xjf gstreamer-0.10.22.tar.bz2
exec mkdir gstreamer-0.10.22/ser
exec cd gstreamer-0.10.22/ser
exec ../configure --prefix=$CONTRIB_DIR/extras
exec make -j 4
exec make install
exec cd -
# Just in case of premature quit
chmod -R g=rwX,o=rX $CONTRIB_DIR/extras

# liboil
exec wget -N -nv http://liboil.freedesktop.org/download/liboil-0.3.14.tar.gz
exec tar xzf liboil-0.3.14.tar.gz
exec mkdir liboil-0.3.14/ser
exec cd liboil-0.3.14/ser
exec ../configure --prefix=$CONTRIB_DIR/extras
exec make -j 4
exec make install
exec cd -
# Just in case of premature quit
chmod -R g=rwX,o=rX $CONTRIB_DIR/extras

# gst-plugins-base
exec wget -N -nv http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-0.10.22.tar.bz2
exec tar xjf gst-plugins-base-0.10.22.tar.bz2
exec mkdir gst-plugins-base-0.10.22/ser
exec cd gst-plugins-base-0.10.22/ser
exec ../configure -with-pkg-config-path=$CONTRIB_DIR/extras/lib/pkgconfig --prefix=$CONTRIB_DIR/extras
exec make -j 4
exec make install
exec cd -

# Fix permissions
chmod -R g=rwX,o=rX $CONTRIB_DIR/extras

