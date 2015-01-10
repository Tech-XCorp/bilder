#!/bin/bash
#
# Version and build information for rpy2
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

RPY2_BLDRVERSION=${RPY2_BLDRVERSION:-"2.2.1"}

######################################################################
#
# Other values
#
######################################################################

RPY2_BUILDS=${RPY2_BUILDS:-"pycsh"}
# setuptools gets site-packages correct
RPY2_DEPS=setuptools,Python,r
RPY2_UMASK=002

#####################################################################
#
# Launch rpy2 builds.
#
######################################################################

buildRpy2() {

  if bilderUnpack rpy2; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/rpy2*"
    techo "$cmd"
    $cmd

# Build away
    techo -2 RPY2_ENV = $RPY2_ENV
    RHOME_DIR=$CONTRIB_DIR/R
#    See numpy for some of this logic
    case `uname`-$CC in
      CYGWIN*-cl)
        RPY2_ENV="$DISTUTILS_ENV"
        ;;
      CYGWIN*-*mingw*)
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        RPY2_ENV="PATH=$mingwdir:'$PATH'"
        ;;
      Darwin-1?.*)
        RHOME_DIR="$RHOME_DIR/R.framework/Versions/2.14/Resources"
        RPY2_ENV="$DISTUTILS_ENV PATH=$RHOME_DIR/bin:${PATH}"
        ;;
       *) RHOME_DIR="$RHOME_DIR"
          RPY2_ENV="$DISTUTILS_ENV PATH=$RHOME_DIR/bin:${PATH}"
          ;;
    esac

    bilderDuBuild -p rpy2 rpy2 "r-home=$RHOME_DIR" "$RPY2_ENV"
  fi

}

######################################################################
#
# Test rpy2
#
######################################################################

testRpy2() {
  techo "Not testing rpy2."
}

######################################################################
#
# Install rpy2
#
######################################################################

installRpy2() {
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p rpy2 rpy2 '-' "$RPY2_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p rpy2 rpy2 "--install-purelib=$PYTHON_SITEPKGSDIR" "$RPY2_ENV"
      ;;
  esac
}

