#!/bin/bash
#
# Version and build information for f2c.  The buildf2c script
# can be found at http://hpc.sourceforge.net/buildf2c.
#
# For bilder, we separate this into two parts, the first is
# creation of a completely unpacked tarball, which can then
# be put into the repo.
#
# $Id$
#
######################################################################

# Separate tarball creation.  Must work on case-sensitive system
# to deal with a readme->README link.
cat >createf2ctarball.sh <<EOF
curl "http://netlib.sandia.gov/cgi-bin/netlib/netlibfiles.tar?filename=netlib/f2c" -o "f2c.tar"
tar -xvf f2c.tar
cd f2c
rm readme # Bad link on case insensitive systems
# Unpacks windows executables
for i in msdos/*.gz mswin/*.gz; do
  gunzip \$i
done
# Unzip library source.  Entire tarball will be compressed anyway.
unzip libf2c.zip -d libf2c
cp libf2c/makefile.u libf2c/makefile
cp src/makefile.u src/makefile
# These are share files
mv libf77 libf77.sh
mv libi77 libi77.sh
# These can be unpacked or not
# sh libf77.sh
# sh libi77.sh
sed -i.bak 's/ -Olimit 2000//g; s/ -lm//g; s/ -u MAIN__//g' fc
chmod 775 fc
cat >Makefile << EOF1
#
# Simple makefile for F2c
# Based on http://hpc.sourceforge.net/buildf2c
#

PREFIX = \$(HOME)/f2cinst
INCDIR = \$(PREFIX)/include
LIBDIR = \$(PREFIX)/lib
BINDIR = \$(PREFIX)/bin
MANDIR = \$(PREFIX)/man/man1

all:
	for dir in libf2c src; do (cd \$\$dir; make); done

install: all
	/usr/bin/install -m 2775 -d \$(INCDIR)
	/usr/bin/install -m 664 libf2c/f2c.h \$(INCDIR)
	/usr/bin/install -m 2775 -d \$(LIBDIR)
	/usr/bin/install -m 664 libf2c/libf2c.a \$(LIBDIR)
	/usr/bin/install -m 2775 -d \$(BINDIR)
	/usr/bin/install -m 775 src/f2c \$(BINDIR)
	sed -i.bak -e "s?/usr/local?\$(PREFIX)?g" fc
	/usr/bin/install -m 775 fc \$(BINDIR)
	/usr/bin/install -m 2775 -d \$(MANDIR)
	/usr/bin/install -m 664 f2c.1t \$(MANDIR)/f2c.1
EOF1
EOF

######################################################################
#
# Version
#
######################################################################

F2C_BLDRVERSION=${F2C_BLDRVERSION:-"1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$F2C_BUILDS"; then
  case `uname` in
    Darwin) F2C_BUILDS=ser;;
    *) F2C_BUILDS=NONE;;
  esac
fi
F2C_DEPS=
F2C_UMASK=002
addtopathvar PATH $CONTRIB_DIR/f2c/bin

######################################################################
#
# Launch f2c builds.
#
######################################################################

buildF2c() {

# If worked, proceed to configure and build
  if bilderUnpack -i f2c; then
# No configure step, so must state here where build is.
    F2C_SER_BUILD_DIR=$BUILD_DIR/f2c-${F2C_BLDRVERSION}/ser
    bilderBuild f2c ser
  fi

}

######################################################################
#
# Test f2c
#
######################################################################

testF2c() {
  techo "Not testing f2c."
}

######################################################################
#
# Install f2c
#
######################################################################

installF2c() {
  F2C_SER_INSTALL_DIR=$CONTRIB_DIR
  if bilderInstall -p f2c-${F2C_BLDRVERSION}-ser f2c ser "" "PREFIX=$CONTRIB_DIR/f2c-${F2C_BLDRVERSION}-ser"; then
    : # Probably need to fix up dylibs here
  fi
  # techo "WARNING: Quitting at end of f2c.sh."; cleanup
}


