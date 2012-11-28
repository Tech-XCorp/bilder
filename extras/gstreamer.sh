#!/bin/bash
#
# $Id$
#
# This documents the sequence of actions taken to get the packages
# needed for phonon to build at NERSC and Janus
#

CONTRIB_DIR=/global/project/projectdirs/facets/hopper/contrib-pgi-12.5

# gstreamer
wget http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-0.10.22.tar.bz2
tar xjf gstreamer-0.10.22.tar.bz2
mkdir gstreamer-0.10.22/ser && cd gstreamer-0.10.22/ser
../configure --prefix=$CONTRIB_DIR/extras
make -j 4 && make install
cd -

# liboil
wget http://liboil.freedesktop.org/download/liboil-0.3.14.tar.gz
tar xzf liboil-0.3.14.tar.gz
mkdir liboil-0.3.14/ser && cd liboil-0.3.14/ser
../configure --prefix=$CONTRIB_DIR/extras
make -j 4 && make install
cd -

# gst-plugins-base
wget http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-0.10.22.tar.bz2
tar xjf gst-plugins-base-0.10.22.tar.bz2
mkdir gst-plugins-base-0.10.22/ser && cd gst-plugins-base-0.10.22/ser
../configure -with-pkg-config-path=$CONTRIB_DIR/extras/lib/pkgconfig --prefix=$CONTRIB_DIR/extras
make -j 4 && make install
cd -

