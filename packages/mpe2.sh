#!/bin/bash
#
# Version and build information for mpe2
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

if test -z "$MPE2_BLDRVERSION"; then
  MPE2_BLDRVERSION=1.3.0
fi

######################################################################
#
# Other values
#
######################################################################

if test -z "$MPE2_BUILDS"; then
  if $BUILD_MPIS && ! [[ `uname` =~ CYGWIN ]]; then
    MPE2_BUILDS=nodl
  fi
fi
MPE2_DEPS=$MPI_BUILD,valgrind,doxygen
MPE2_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/mpe2/bin

######################################################################
#
# Launch mpe2 builds.
#
######################################################################

buildMpe2() {
  if bilderUnpack mpe2; then
# Determine directories for mpicc and java
    if test -z "$OPENMPI_BLDRVERSION"; then
      source $BILDER_DIR/packages/openmpi.sh
    fi
    # local absmpicc=`which mpicc`
    # local mpibindir=`dirname $absmpicc`
    # mpibindir=`(cd $mpibindir; pwd -P)`
    local mpibindir=$CONTRIB_DIR/openmpi-$OPENMPI_BLDRVERSION-nodl/bin
# Assume path java is correct java
    local javaexe=`which java`
    javaexe=`readlink -f $javaexe`
    local javadir=`dirname $javaexe`
    javadir=`dirname $javadir`
# Do it
    if bilderConfig mpe2 nodl "MPI_CC='$mpibindir/mpicc' CC='$CC' MPI_F77='$mpibindir/mpif77' F77='$F77' --with-java2=$javadir"; then
      bilderBuild mpe2 nodl "$MPE2_MAKEJ_ARGS"
    fi
  fi
}

######################################################################
#
# Test mpe2
#
######################################################################

testMpe2() {
  techo "Not testing mpe2."
}

######################################################################
#
# Install mpe2
#
######################################################################

# Set umask to allow only group to use
installMpe2() {
  if bilderInstall mpe2 nodl mpe2; then
    :
  fi
  # techo "WARNING. Quitting at end of mpe2.sh."; exit
}

