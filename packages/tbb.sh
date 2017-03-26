#!/bin/sh
######################################################################
#
# @file    tbb.sh
#
# @brief   Build information for tbb.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# From http://software.intel.com/en-us/intel-tbb
# tar xzf tbb43_20140724oss_src.tgz
# mv tbb41_20140724oss tbb-41_20140724oss
# COPY_EXTENDED_ATTRIBUTES_DISABLE=1 tar czf tbb-43_20140724oss.tar.gz tbb-43_20140724oss
#
######################################################################

######################################################################
#
# Trigger variables set in tbb_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/tbb_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTbbNonTriggerVars() {
  : # TBB_UMASK=002 # Not needed as using install
}
setTbbNonTriggerVars

######################################################################
#
# Launch tbb builds.
#
######################################################################

buildTbb() {

  if ! bilderUnpack -i tbb; then
    return
  fi

# tbb has no build/configure system
  TBB_CONFIG_METHOD=NONE

# Other args
  local TBB_ADDL_ARGS=
  case `uname` in
    Darwin)
      if echo $CXXFLAGS | grep -q 'libstdc\+\+'; then
        TBB_ADDL_ARGS="$TBB_ADDL_ARGS stdlib=libstdc++"
      fi
      ;;
  esac

  TBB_SERSH_BUILD_DIR=$BUILD_DIR/tbb-$TBB_BLDRVERSION/sersh
  bilderBuild tbb sersh "$TBB_ADDL_ARGS $TBB_SERSH_OTHER_ARGS"

}

######################################################################
#
# Test tbb
#
######################################################################

testTbb() {
  techo "Not testing tbb."
}

######################################################################
#
# Install tbb
#
######################################################################

installTbb() {
  TBB_SERSH_INSTALL_DIR=$CONTRIB_DIR
  instdir=$TBB_SERSH_INSTALL_DIR/tbb-$TBB_BLDRVERSION-sersh
  cmd="/usr/bin/install -d -m 775 $instdir"
  techo "$cmd"
  eval "$cmd"
  if bilderInstall -m : tbb sersh; then
    cd $TBB_SERSH_BUILD_DIR
    cmd="/usr/bin/install -d -m 775 $instdir/{include,lib,bin}"
    techo "$cmd"
    eval "$cmd"
    hdrs=`ls src/tbb*/*.h | tr '\n' ' '`
    cmd="/usr/bin/install -m 664 $hdrs $instdir/include"
    techo "$cmd"
    eval "$cmd"
    local bldlibdir=`ls -d build/*_release`
    local ver=
    local libs=
    case `uname` in
      CYGWIN*)
        libs=`ls $bldlibdir/{*.lib} 2>/dev/null | tr '\n' ' '`
        ;;
      Darwin)
        libs=`ls $bldlibdir/{lib*} 2>/dev/null | tr '\n' ' '`
        ;;
      Linux)
        ver=`(cd $bldlibdir; ls libtbb.so.* | sed 's/libtbb.so.//')`
        libnames=`(cd $bldlibdir; ls lib* | sed 's/\.so.*//' | uniq | tr '\n' ' ')`
        for l in $libnames; do
          libs="$libs $bldlibdir/${l}.so.$ver"
        done
        ;;
    esac
    cmd="/usr/bin/install -m 775 $libs $instdir/lib"
    techo "$cmd"
    eval "$cmd"
    case `uname` in
      Linux)
        techo "Making links to shared libs."
        for l in $libnames; do
          (cd $instdir/lib; ln -sf ${l}.so.$ver ${l}.so)
        done
        ;;
    esac
  else
    cmd="rm -rf $instdir $CONTRIB_DIR/tbb-sersh"
    techo "$cmd"
    eval "$cmd"
  fi
}

