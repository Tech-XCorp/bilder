#!/bin/sh
######################################################################
#
# @file    gotoblas2.sh
#
# @brief   Version and build information for gotoblas2.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# Notes on building gotoblas2 are at
# http://www.pgroup.com/resources/gotoblas/gotoblas_pgi2011.htm
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GOTOBLAS2_BLDRVERSION=${gotoblas2_BLDRVERSION:-"1.13"}

######################################################################
#
# Builds and other values
#
######################################################################

GOTOBLAS2_BUILDS=ser
GOTOBLAS2_DEPS=clapack_cmake,lapack,Python

######################################################################
#
# Launch gotoblas2 builds.
#
######################################################################

buildGotoblas2() {

# All builds and deps now taken from global variables
  if bilderUnpack gotoblas2; then

# ser build.  No configuration needed
    if bilderConfig gotoblas2 ser; then
# If on AVX processor, need to add TARGET=BARCELONA or similar to downgrade
# to a latest supported processor.
# Need to add env LD_LIBRARY_PATH=/usr/local/contrib/gcc-4.6.3/lib64 to env
# Remove '-l -l' from Makefile.conf
      if bilderBuild gotoblas2 ser "CC=$CC FC=$FC"; then
# Fix any build problems
        :
      fi
    fi

  fi

}

######################################################################
#
# Test gotoblas2
#
######################################################################

testGotoblas2() {
  techo "Not testing gotoblas2."
}

######################################################################
#
# Install gotoblas2, look for it again.
#
######################################################################

installgotoblas2() {
  local anyinstalled=false
  rm -f $CONTRIB_DIR/gotoblas2-$gotoblas2_BLDRVERSION-ser/lib/*.so
  for bld in `echo $gotoblas2_BUILDS | tr ',' ' '`; do
    if bilderInstall -r gotoblas2 $bld; then
      anyinstalled=true
      case `uname` in
        CYGWIN*)
          local instlibdir=$CONTRIB_DIR/gotoblas2-$gotoblas2_BLDRVERSION-$bld/lib
          for i in lapack cblas f77blas gotoblas2; do
            if test -f $instlibdir/lib${i}.a; then
              cmd="mv $instlibdir/lib${i}.a $instlibdir/${i}.lib"
              techo "$cmd"
              $cmd
            fi
          done
          case $bld in
            clp)
# Copy the f2clib over
              cp $CLAPACK_CMAKE_SER_LIBDIR/f2c.lib $CONTRIB_DIR/gotoblas2-$gotoblas2_BLDRVERSION-$bld/lib
              ;;
          esac
          ;;
        Linux)
# If built static, then it seems numpy cannot find gotoblas2?
# If build shared, then cannot import numpy, unless it gets an rpath flag
          local ldfl=--allow-multiple-definition
# This counts on the ser build being done
          case $bld in
            ser)
              if isCcGcc && test -n "$LIBGFORTRAN_DIR"; then
                ldfl="$ldfl -L$LIBGFORTRAN_DIR -rpath $LIBGFORTRAN_DIR"
              fi
              cmd="cd $BUILD_DIR/gotoblas2-$gotoblas2_BLDRVERSION/$bld/lib"
              techo "$cmd"
              $cmd
              cmd="make shared LDFLAGS='$ldfl'"
              techo "$cmd"
              eval "$cmd"
              cmd="/usr/bin/install -m 775 -d $CONTRIB_DIR/gotoblas2-$gotoblas2_BLDRVERSION-sersh/lib"
              techo "$cmd"
              $cmd
              cmd="/usr/bin/install -m 775 *.a *.so $CONTRIB_DIR/gotoblas2-$gotoblas2_BLDRVERSION-sersh/lib"
              techo "$cmd"
              $cmd
              cd -
              $BILDER_DIR/setinstald.sh -i $CONTRIB_DIR gotoblas2,sersh
              ;;
          esac
          ;;
      esac
    fi
  done

  if $anyinstalled; then
    findBlasLapack
  fi
  # techo "WARNING: Quitting at end of gotoblas2.sh."; exit
}

