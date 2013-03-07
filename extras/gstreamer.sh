#!/bin/bash
#
# $Id$
#
# This documents the sequence of actions taken to get the packages
# needed for phonon to build at NERSC and Janus
#

CONTRIB_DIR=/global/project/projectdirs/facets/hopper/contrib-pgi-12.9
CONTRIB_DIR=/global/project/projectdirs/facets/edison/contrib-intel-13.0

exec() {
  echo $*
  $*
}

# gstreamer
exec wget http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-0.10.22.tar.bz2
exec tar xjf gstreamer-0.10.22.tar.bz2
exec mkdir gstreamer-0.10.22/ser
exec cd gstreamer-0.10.22/ser
exec ../configure --prefix=$CONTRIB_DIR/extras
exec make -j 4
exec make install
exec cd -

# liboil
exec wget http://liboil.freedesktop.org/download/liboil-0.3.14.tar.gz
exec tar xzf liboil-0.3.14.tar.gz
exec mkdir liboil-0.3.14/ser
exec cd liboil-0.3.14/ser
exec ../configure --prefix=$CONTRIB_DIR/extras
exec make -j 4
exec make install
exec cd -

# gst-plugins-base
exec wget http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-0.10.22.tar.bz2
exec tar xjf gst-plugins-base-0.10.22.tar.bz2
exec mkdir gst-plugins-base-0.10.22/ser
exec cd gst-plugins-base-0.10.22/ser
exec ../configure -with-pkg-config-path=$CONTRIB_DIR/extras/lib/pkgconfig --prefix=$CONTRIB_DIR/extras
exec make -j 4
exec make install
exec cd -

