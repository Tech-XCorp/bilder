#!/bin/bash
#
# Version and build information for f2c.  The buildf2c script
# can be found at http://hpc.sourceforge.net/buildf2c.
#
# For bilder, we separate this into two parts, the first is
# creation of a completely unpacked tarball, which can then
# be put into the repo.
#
# $Id: f2c.sh 6090 2012-05-20 18:31:48Z cary $
#
######################################################################

# Separate tarball creation.  Has to be modified to work
# with case-insensitive systems.
cat >createf2ctarball.sh <<EOF
curl "http://netlib.sandia.gov/cgi-bin/netlib/netlibfiles.tar?filename=netlib/f2c" -o "f2c.tar"
tar -xvf f2c.tar
rm f2c/readme
gunzip -rf f2c/*
cd f2c
unzip libf2c.zip -d libf2c
cp libf2c/makefile.u libf2c/makefile
cp src/makefile.u src/makefile
mv libf77 libf77.sh
mv libi77 libi77.sh
# These can be unpacked or not
# sh libf77.sh
# sh libi77.sh
EOF

######################################################################
#
# Version
#
######################################################################

F2C_BLDRVERSION=${F2C_BLDRVERSION:-"0"}

######################################################################
#
# Other values
#
######################################################################

F2C_BUILDS=${F2C_BUILDS:-"NONE"}
F2C_DEPS=
F2C_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/f2c/bin

######################################################################
#
# Launch f2c builds.
#
######################################################################

buildF2c() {

# This is the script to build f2c
cat >$BUILD_DIR/f2c_install.sh <<EOF
curl "http://netlib.sandia.gov/cgi-bin/netlib/netlibfiles.tar?filename=netlib/f2c" -o "f2c.tar"
tar -xvf f2c.tar
gunzip -rf f2c/*
cd f2c
mkdir libf2c
mv libf2c.zip libf2c
cd libf2c
unzip libf2c.zip
cp makefile.u Makefile
export F2C_INSTALL_DIR=/contrib/f2c
make
cp f2c.h $F2C_INSTALL_DIR/include
cp libf2c.a $F2C_INSTALL_DIR/lib
cd ../src
cp makefile.u Makefile
make
cp f2c $F2C_INSTALL_DIR/bin
cd ..
mkdir -p $F2C_INSTALL_DIR/man/man1
cp f2c.1t $F2C_INSTALL_DIR/man/man1
cp fc $F2C_INSTALL_DIR/bin/f77
chmod +x $F2C_INSTALL_DIR/bin/f77
cd ..
rm -rf f2c
echo "==================SUMMARY=================="
echo $0 " has built and installed:"
find $F2C_INSTALL_DIR -name '*f2c*' -mmin -5
find $F2C_INSTALL_DIR -name '*f77*' -mmin -5
EOF

# If worked, prf2ced to configure and build
  if test $res = 0; then

# Configure and build
    if bilderConfig f2c ser "$F2C_ADDL_ARGS $F2C_OTHER_ARGS"; then
      bilderBuild f2c ser "" "$F2C_ENV"
    fi

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
  if bilderInstall f2c ser; then
    : # Probably need to fix up dylibs here
  fi
  # techo "WARNING: Quitting at end of f2c.sh."; cleanup
}


