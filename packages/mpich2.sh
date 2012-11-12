#!/bin/bash
#
# Version and build information for mpich2
# We have not yet created the bilder package file for mpich2, so
# here we simply store some notes.
#
# $Id: mpich2.sh 6163 2012-06-01 15:28:49Z alexanda $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

if test -z "$MPICH2_BLDRVERSION"; then
  MPICH2_BLDRVERSION=1.2.1
fi

######################################################################
#
# Other values
#
######################################################################

if test -z "$MPICH2_BUILDS"; then
  if $BUILD_MPICH2; then
    MPICH2_BUILDS=static
  fi
fi
MPICH2_DEPS=
MPICH2_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/mpich2/bin

######################################################################
#
# Launch mpich2 builds.
#
######################################################################

buildMpich2() {
../configure --prefix=/usr/local/mpich2-1.2.1 \
  --enable-f77 --enable-f90 --enable-romio --enable-smpcoll \
  --with-device=ch3:ssm --with-pm=hydra--with-mpe \
  FFLAGS=-fPIC FCFLAGS=-fPIC CFLAGS=-fPIC CXXFLAGS=-fPIC
make
}

######################################################################
#
# Test mpich2
#
######################################################################

testMpich2() {
  techo "Not testing mpich2."
}

######################################################################
#
# Install mpich2
#
######################################################################

# Set umask to allow only group to use
installMpich2() {
  make install
  topdir=$PWD
  cat >mkshared.sh <<END
for dir in lib src/mpe2/lib src/openpa/src; do
  cd $topdir/\$dir
  mkdir shared
  cd shared
  for i in ../lib*.a; do
    ar x \$i
    newname='../`basename $i .a`.so'
    files='`ls *.o *.po *.no 2>/dev/null`'
    gcc -shared -o \$newname \$files
    rm *.o *.po *.no
  done
  cd ..
  /usr/bin/install -m 755 *.so /usr/local/mpich2-1.2.1/lib
  cd $topdir
done
END
  mkshared.sh
}

