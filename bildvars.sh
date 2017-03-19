#!/bin/bash
#
# $Id$
#
# There are three parts to this file
# 1. Get per-machine parameters
# 2. Set default parameters per OS (if not set)
# 3. Set derived parameters
#
######################################################################

######################################################################
#
# Posting to the depot means copying installers to a predetermined
# host. Thus there are some addition requirements for doing this.
#
######################################################################

if $POST2DEPOT; then
  if test -z "$INSTALLER_HOST" -o -z "$INSTALLER_ROOTDIR"; then
    techo "No INSTALLER_HOST or INSTALLER_ROOTDIR specified."
    POST2DEPOT=false
    techo "Turning off post to depot: POST2DEPOT=$POST2DEPOT."
  else
    # One needs installers to post to depot, so ensure they are built
    BUILD_INSTALLERS=true
  fi
fi

if $BUILD_INSTALLERS; then
  techo "Will build installers."
else
  techo "Will not build installers."
fi

######################################################################
#
# This is available for package scripts to use if they want.
#
######################################################################

DEFAULT_SUPRA_SEARCH_PATH=$HOME/software:$HOME:/internal:/contrib:/usr/local:/opt/usr

######################################################################
#
# Add our bin paths
#
######################################################################

# Add successively to the FRONT of the path
techo "Adding to the PATH."
addtopathvar PATH $CONTRIB_DIR/bin
addtopathvar PATH $BLDR_INSTALL_DIR/bin
addtopathvar PATH $CONTRIB_DIR/cmake/bin
# One of these should add the path to texlive if not in path
case `uname` in
  Linux)
    addtopathvar PATH $CONTRIB_DIR/texlive/bin/x86_64-linux
    addtopathvar PATH /contrib/texlive/bin/x86_64-linux
    ;;
  Darwin)
    addtopathvar PATH /usr/local/texlive/2014/bin/x86_64-darwin
    addtopathvar PATH /usr/local/texlive/2015/bin/x86_64-darwin
    addtopathvar PATH /usr/local/texlive/2016/bin/x86_64-darwin
    ;;
esac
# Add parallel path now before absolute paths determined by getCombinedCompVars
if $BUILD_MPIS; then
  addtopathvar PATH $CONTRIB_DIR/$USE_MPI/bin
fi
techo "PATH = $PATH"

######################################################################
# OS can set any unset flags
######################################################################

NUM_PHYS_CORES=`getNumPhysCores`

######################################################################
#
# OS can set any unset flags
#
######################################################################

techo "Setting per-system variables."
case `uname` in

  AIX)
    ARCHIVER=ar
    BLAS_LIB=${BLAS_LIB:-"-lessl"}
    CC=${CC:-"xlc_r"}
    CXX=${CXX:-"xlC_r"}
    FC=${FC:-"xlf95_r"}
    F77=${F77:-"xlf_r"}
    LIBEXT=.a
    LIBPREFIX=lib
    MPICC=${MPICC:-"mpcc_r"}
    MPICXX=${MPICXX:-"mpCC_r"}
    MPIFC=${MPIFC:-"mpxlf95_r"}
    MPIF77=${MPIF77:-"mpxlf_r"}
    RPATH_FLAG=${RPATH_FLAG:-"-blibpath:"}
    READLINK=readlink
    SHOBJEXT=.a
    # SHOBJFLAGS=${SHOBJFLAGS:-""}
    ;;

  CYGWIN*)
    if ! which reg 1>/dev/null 2>&1; then
      techo "Cannot find reg.  Sanity test failed.  Quitting."
      return 1
    fi
    ARCHIVER=lib
    ARCHIVER_EXTRACT="lib /extract:"
    ARCHIVER_CREATE="lib /def:"
    CYGWIN_ROOT=${CYGWIN_ROOT:-"/cygwin"}
    CC=${CC:-"cl"}
    CXX=${CXX:-"cl"}
# http://www.windows-commandline.com/get-cpu-processor-information-command/
    CPUINFO=`wmic cpu get caption | tail -1`
    LIBEXT=.lib
    unset LIBPREFIX
    techo "Getting number of cores."
# BLDR_BUILD_NUMPY: whether numpy is built (versus installed from a whl)
    BLDR_BUILD_NUMPY=${BLDR_BUILD_NUMPY:-"false"}
    NUM_PHYS_CORES=${NUMBER_OF_PROCESSORS}
    MPICC=${MPICC:-"cl"}
    MPICXX=${MPICXX:-"cl"}
    PREFER_CMAKE=${PREFER_CMAKE:-"true"}
    SHOBJEXT=.dll
    if which blat 1>/dev/null 2>&1; then
      SENDMAIL=blat
    fi
    mylink=$(which link)
    if test "$mylink" = /usr/bin/link; then
      techo "WARNING: [bildvars.sh] Wrong link (/usr/bin/link) in path on cygwin."
      techo "WARNING: [bildvars.sh] Cannot build some packages."
      techo "WARNING: [bildvars.sh] 'which link' must return the link executable from Visual Studio."
      return 1
    else
      techo "Correct link, $mylink, found."
    fi
    mysort=$(which sort)
    if test "$mysort" != /usr/bin/sort; then
      techo "WARNING: [bildvars.sh] Not using /usr/bin/sort from cygwin (found $mysort)."
      return 1
    else
      techo "Correct sort, $mysort, found."
    fi
    case $CC in
      *cl)
# Less efficient, but records these flags
        COMP_FLAGS_RELEASE="/O2 /Ob2 /D NDEBUG"
        COMP_FLAGS_RELWITHDEBINFO="/O2 /Zi /Ob1 /D NDEBUG"
        COMP_FLAGS_MINSIZEREL="/O1 /Ob1 /D NDEBUG"
        COMP_FLAGS_DEBUG="/D_DEBUG /Zi /Ob0 /Od /RTC1"
        for i in RELEASE RELWITHDEBINFO MINSIZEREL DEBUG; do
          cflags=`deref COMP_FLAGS_$i`
          eval "CMAKE_NODEFLIB_FLAGS_$i=\"-DCMAKE_C_FLAGS_$i:STRING='$cflags' -DCMAKE_CXX_FLAGS_$i:STRING='$cflags'\""
          val=`deref CMAKE_NODEFLIB_FLAGS_$i`
          techo -2 "CMAKE_NODEFLIB_FLAGS_$i = $val"
        done
        REPO_NODEFLIB_FLAGS=`deref CMAKE_NODEFLIB_FLAGS_$REPO_BUILD_TYPE_UC`
        techo -2 "REPO_NODEFLIB_FLAGS = $REPO_NODEFLIB_FLAGS"
        TARBALL_NODEFLIB_FLAGS=`deref CMAKE_NODEFLIB_FLAGS_$TARBALL_BUILD_TYPE_UC`
        techo -2 "TARBALL_NODEFLIB_FLAGS = $TARBALL_NODEFLIB_FLAGS"
        ;;
      *mingw32*)
        ;;
    esac
    ;;

  Darwin)
    ATLAS_BUILDS=NONE   # Since using framework Accelerate
    if test -n "$ARCHFLAGS"; then
      techo "WARNING: [bildvars.sh] ARCHFLAGS = $ARCHFLAGS.  Potential Python package build problems."
    fi
    ARCHIVER=ar
    CPUINFO=`sysctl -n machdep.cpu.brand_string`
    SYSTEM_BLAS_SER_LIB="-framework Accelerate"
    SYSTEM_LAPACK_SER_LIB="-framework Accelerate"
    LIBEXT=.a
    LIBPREFIX=lib
    NUM_LOG_CORES=`sysctl -n hw.logicalcpu`
    if ! NUM_PHYS_CORES=`hwprefs cpu_count 2>/dev/null`; then
      NUM_PHYS_CORES=`sysctl -n hw.physicalcpu`
    fi
    OSVER=`uname -r`
# On Darwin, jenkins is not getting /usr/local/bin or /opt/homebrew/bin
    xdirs="/usr/local/bin /opt/homebrew/bin"
    for dir in $xdirs; do
      if ! echo $PATH | egrep -q "(^|:)$dir($|:)"; then
        PATH="$PATH":$dir
      fi
    done
    PYC_MODFLAGS=${PYC_MODFLAGS:-"-undefined dynamic_lookup"}
    case "$OSVER" in
      9.[4-8].*)
        READLINK=stat
        PYC_CC=${PYC_CC:-"gcc-4.0"}
        PYC_CXX=${PYC_CXX:-"g++-4.0"}
        PYC_LDSHARED=${PYC_LDSHARED:-"gcc-4.0"}
        ;;
      10.[0-4].*)
        READLINK=readlink
        ;;
      10.[5-9].*)
        READLINK=readlink
        ;;
      11.* | 12.*)
        READLINK=readlink
        ;;
      1[3-9].*)
        CC=${CC:-"clang"}
        CXX=${CXX:-"clang++"}
        if which gfortran 1>/dev/null 2>&1; then
          FC=${FC:-"gfortran"}
          F77=${F77:-"gfortran"}
        elif which gfortran-4.9 1>/dev/null 2>&1; then
          FC=${FC:-"gfortran-4.9"}
          F77=${F77:-"gfortran-4.9"}
        fi
# -stdlib=libc++ is the default since Mavericks and gives c++11 support.
# http://stackoverflow.com/questions/19774778/when-is-it-necessary-to-use-use-the-flag-stdlib-libstdc
# But tests show still needed at link.
        CXXFLAGS=${CXXFLAGS:-"-std=c++11 -stdlib=libc++"}
        PYC_CC=${PYC_CC:-"clang"}
        PYC_CXX=${PYC_CXX:-"clang++"}
# txbase must have -std=c++11 to compile as it uses C++11 extensions
# txbase fails linking to self:
# txbase links to self, so -stdlib=libc++ is NOT a default at link:
        PYC_CXXFLAGS=${PYC_CXXFLAGS:-"-std=c++11 -stdlib=libc++"}
        PYC_FC=${PYC_FC:-"$FC"}
        PYC_F77=${PYC_F77:-"$F77"}
        ;;
    esac
    RPATH_FLAG=${RPATH_FLAG:-"-Wl,-rpath,"}     # For 10.5 and higher
    SHOBJEXT=.dylib
    SHOBJFLAGS=${SHOBJFLAGS:-"-dynamic -flat_namespace -undefined suppress"}
    ;;

  Linux)
    ARCHIVER=ar
    # CXXFLAGS=${CXXFLAGS:-"-std=c++11"}
    # PYC_CXXFLAGS=${PYC_CXXFLAGS:-"-std=c++11"}
    CPUINFO=`grep "model name" /proc/cpuinfo | head -1 | sed 's/^.*:  *//'`
    GLIBC_VERSION=`ldd --version | head -1 | sed 's/^.* //'`
    LIBEXT=.a
    LIBPREFIX=lib
    NUM_LOG_CORES=`grep ^processor /proc/cpuinfo | wc -l`
    NUM_PHYS_CPUS=`grep "physical id" /proc/cpuinfo | sort -u | wc -l`
    NUM_PHYS_CORES_PER_CPU=`grep "cpu cores" /proc/cpuinfo | head -1 | sed 's/^.* //'`
    NUM_PHYS_CORES=`expr $NUM_PHYS_CPUS \* $NUM_PHYS_CORES_PER_CPU`
    case `uname -m` in
      x86_64)
# CMAKE_LIBRARY_PATH_ARG is needed by cmake on ubuntu, where libraries
# are put into different places
        if test -d /usr/lib/x86_64-linux-gnu; then
          SYS_LIBSUBDIRS="lib/x86_64-linux-gnu lib64"
          CMAKE_LIBRARY_PATH_ARG="-DCMAKE_LIBRARY_PATH:PATH='/usr/lib/x86_64-linux-gnu;/usr/lib64'"
        else
          SYS_LIBSUBDIRS=lib64
          CMAKE_LIBRARY_PATH_ARG=
        fi
        sfxorder="so"   # Need shared libs for uedge
        ;;
      i?86)
        SYS_LIBSUBDIRS=lib
        sfxorder="so a"
        ;;
    esac
# Looks like they moved this directory in recent distros
    if test -d /usr/lib64/pkgconfig; then
      addtopathvar PKG_CONFIG_PATH /usr/lib64/pkgconfig
    fi
    PYC_MODFLAGS=${PYC_MODFLAGS:-"-shared"}
    READLINK=readlink
    RPATH_FLAG=${RPATH_FLAG:-"-Wl,-rpath,"}
    SHOBJEXT=.so
    SHOBJFLAGS=${SHOBJFLAGS:-"-shared"}
    # warnMissingLinuxPkgs # This is the responsibility of packages
    ;;

esac
techo "Found $NUM_LOG_CORES logical cores."
techo "Found $NUM_PHYS_CORES physical cores."
MAKEJ_TOTAL=$NUM_PHYS_CORES
IS_MINGW=${IS_MINGW:-"false"}
BLDR_BUILD_NUMPY=${BLDR_BUILD_NUMPY:-"true"}
export BLDR_BUILD_NUMPY

######################################################################
#
# Set the unset compilers to gcc, mpicc collections, tar.
#
######################################################################

# Serial compilers:
CC=${CC:-"gcc"}
CXX=${CXX:-"g++"}
# If HAVE_SER_FORTRAN is unset, try to set it by looking for
# default fortran compilers.
if test -z "$HAVE_SER_FORTRAN"; then
  case `uname` in
    CYGWIN*)
      if $IS_MINGW && test -n "$FC"; then
        HAVE_SER_FORTRAN=true
      fi
      ;;
    *)
      FC=${FC:-`which gfortran`}
      F77=${F77:-`which gfortran`}
      if test -n "$FC"; then
        HAVE_SER_FORTRAN=true
      fi
      ;;
  esac
fi
# Giving up
HAVE_SER_FORTRAN=${HAVE_SER_FORTRAN:-"false"}
# Needed for setinstald.sh for numpy
export HAVE_SER_FORTRAN

# Backend node serial compilers:
BENCC=${BENCC:-"$CC"}
BENCXX=${BENCXX:-"$CXX"}
BENFC=${BENFC:-"$FC"}
BENF77=${BENF77:-"$F77"}

# PYC compilers:
PYC_CC=${PYC_CC:-"gcc"}
PYC_CXX=${PYC_CXX:-"g++"}
if ! [[ `uname` =~ CYGWIN ]]; then
  if test -z "$PYC_FC" && which gfortran 1>/dev/null 2>&1; then
    PYC_FC=gfortran
  fi
  if test -z "$PYC_F77" && which gfortran 1>/dev/null 2>&1; then
    PYC_F77=gfortran
  fi
fi

if $BUILD_MPIS; then
  case `uname` in
    Darwin) USE_MPI=${USE_MPI:-"openmpi-nodl"};; # mpich OSX CUDA fails
    *) USE_MPI=${USE_MPI:-"mpich-shared"};;
  esac
  MPI_BUILD=`echo $USE_MPI | sed 's/-.*//'`
fi
# Parallel compilers
if test -z "$MPICC" && which mpicc 1>/dev/null 2>&1; then
  MPICC=mpicc
fi
if test -z "$MPICXX" && which mpicxx 1>/dev/null 2>&1; then
  MPICXX=mpicxx
fi
if test -z "$MPIFC" && which mpif90 1>/dev/null 2>&1; then
  MPIFC=mpif90
fi
if test -z "$MPIF77" && which mpif77 1>/dev/null 2>&1; then
  MPIF77=mpif77
fi
HAVE_PAR_FORTRAN=false
if test -n "$MPIFC" && which $MPIFC 1>/dev/null 2>&1; then
  HAVE_PAR_FORTRAN=true
fi

######################################################################
#
# Now that CC set, get the chain
#
######################################################################

# We may want to add version to the chain variable
if test -z "$BILDER_CHAIN"; then
# Compiler base name determines the BILDER_CHAIN
  ccbase=$(basename "${CC}" .exe)
  case $(uname) in
    CYGWIN*)
      case $ccbase in
        *mingw*)
          ccver=`$CC --version | sed -e 's/ 9.*$//'`
          GCC_VERSION="$ccver"
          BILDER_CHAIN=MinGW
          ;;
        *icl)
          BILDER_CHAIN=icl
          ;;
        *)
# Need to figure out how to separate versions of vs
          BILDER_CHAIN=Vs${VISUALSTUDIO_VERSION}
          ;;
      esac
      ;;
    Darwin)
      case $ccbase in
        clang)
          ccver=`clang --version | head -1 | sed -e 's/^.*clang-//' -e 's/).*$//'`
          ;;
        gcc)
          ccver=`gcc --version | head -1 | sed -e 's/^.*GCC) //' -e 's/ .*$//'`
          GCC_VERSION="$ccver"
          ;;
      esac
      ;;
    Linux)
      case $ccbase in
        path*)  # For pathscale, strip version?
          BILDER_CHAIN=`echo $ccbase | sed -e 's/-[0-9].*$//'`
          ;;
        pgcc)
          BILDER_CHAIN=pgi
          ;;
        gcc)
          ccver=`gcc --version | head -1 | sed -e 's/^.*GCC) //' -e 's/ .*$//'`
          GCC_VERSION="$ccver"
          ;;
      esac
      ;;
  esac
  case $ccbase in
    clang | gcc | *mingw*)
      if test -n "$GCC_VERSION"; then
        GCC_MAJMIN=`echo $ccver | sed -e 's/\.[^\.]*$//'`
        GCC_MAJOR=`echo $GCC_MAJMIN | sed -e 's/\.[^\.]*$//'`
        GCC_MINOR=`echo $GCC_MAJMIN | sed -e 's/^[^\.]*\.//'`
      fi
      BILDER_CHAIN=${ccbase}${ccver}
      ;;
  esac
fi

######################################################################
#
# For python build.
#
######################################################################

if isCcPyc; then
  FORPYTHON_SHARED_BUILD=sersh
  if [[ `uname` =~ CYGWIN ]]; then
    FORPYTHON_STATIC_BUILD=sermd
  else
    FORPYTHON_STATIC_BUILD=ser
  fi
else
# Below: shared with pyc compilers
  FORPYTHON_SHARED_BUILD=pycsh
# Below, Unix: serial with PYC compilers.
# Below, Windows: serial with PYC compilers, shared runtime.
  FORPYTHON_STATIC_BUILD=pycst
fi
techo -2 "FORPYTHON_SHARED_BUILD = $FORPYTHON_SHARED_BUILD."
techo -2 "FORPYTHON_STATIC_BUILD = $FORPYTHON_STATIC_BUILD."

######################################################################
#
# Now that chain is known, check to see whether wait days have passed
# Chain is needed for subject
#
######################################################################


if test -n "$WAIT_PACKAGE"; then

# Search for the package
  if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/${WAIT_PACKAGE}.sh; then
    waitPkg="$BILDER_CONFDIR/packages/${WAIT_PACKAGE}.sh"
  elif test -f $BILDER_DIR/packages/${WAIT_PACKAGE}.sh; then
    waitPkg="$BILDER_DIR/packages/${WAIT_PACKAGE}.sh"
  fi
  echo "---------- Found $waitPkg ----------"

  if source $waitPkg; then
    bldsvar=`genbashvar ${WAIT_PACKAGE}`_BUILDS
    bldsval=`deref $bldsvar`
    if isBuildTime -i develdocs ${WAIT_PACKAGE} $bldsval $BLDR_INSTALL_DIR; then
      techo "${WAIT_PACKAGE} not installed in $BILDER_WAIT_DAYS days."
      techo "Time to install.  Setting BILDER_WAIT_DAYS to 0."
      BILDER_WAIT_DAYS=0
    else
      subj="Not installing: ${WAIT_PACKAGE} installed in the last $BILDER_WAIT_DAYS days."
      techo "$subj"
      unset EMAIL   # Disable emailing
      finish -s "$subj"
      exit 0
    fi
  fi
else
  techo "WARNING: [bildvars.sh] WAIT_PACKAGE not set in top bilder script."
fi

######################################################################
#
# If mpich, find the library dir, absolute path
#
######################################################################

if test `uname` = Linux -a -n "$MPICC"; then
  isMpich2=`$MPICC -show 2>/dev/null | grep mpich2`
  if test -n "$isMpich2"; then
    MPICH2_LIBDIR=`echo $isMpich2 | sed -e 's/^.*-L//' -e 's/ .*$//'`
    PAR_EXTRA_LDFLAGS="$PAR_EXTRA_LDFLAGS ${RPATH_FLAG}$MPICH2_LIBDIR"
    PAR_EXTRA_LT_LDFLAGS="$PAR_EXTRA_LDFLAGS ${LT_RPATH_FLAG}$MPICH2_LIBDIR"
  fi
fi

######################################################################
#
# If gfortran, find extra library dir, and see if high enough version.
#
######################################################################

techo -2 "Analyzing fortran."
case `uname` in
  Linux)
# PYC libdir for runpath
    gxxlib=`$PYC_CXX -print-file-name=libstdc++.so`
    techo "PYC_CXX = $PYC_CXX.  gxxlib = $gxxlib."
    gcclibdir=`dirname $gxxlib`
    if test $gcclibdir != .; then
      gcclibdir=`(cd $gcclibdir; pwd -P)`
      case $gcclibdir in
        /usr/lib/gcc/*) # Do not add system dirs
          ;;
        /*)
          addtopathvar PYC_LD_LIBRARY_PATH $gcclibdir
          addtopathvar PYC_LD_RUN_PATH $gcclibdir
          ;;
      esac
    fi
# If extras installed, add in the libdir
    if test -e $CONTRIB_DIR/extras/lib; then
      addtopathvar PYC_LD_LIBRARY_PATH $CONTRIB_DIR/extras/lib
      addtopathvar PYC_LD_RUN_PATH $CONTRIB_DIR/extras/lib
    fi
    if test -e $CONTRIB_DIR/lib; then
      addtopathvar PYC_LD_LIBRARY_PATH $CONTRIB_DIR/lib
      addtopathvar PYC_LD_RUN_PATH $CONTRIB_DIR/lib
    fi
    ;;
esac

# Get gfortran library.  Need to add for building python packages
if ! [[ `uname` =~ CYGWIN ]] && which $PYC_FC 1>/dev/null 2>&1; then
  LIBGFORTRAN=`$PYC_FC -print-file-name=libgfortran${SHOBJEXT}`
  LIBGFORTRAN_DIR=`dirname $LIBGFORTRAN`
  if test "$LIBGFORTRAN_DIR" = .; then
    unset LIBGFORTRAN_DIR
  fi
  if test -n "$LIBGFORTRAN_DIR"; then
# Shared libgfortran case
    LIBGFORTRAN_DIR=`(cd $LIBGFORTRAN_DIR; pwd -P)`
    case $LIBGFORTRAN_DIR in
      /usr/lib/gcc/*)
# For this case libgfortran location not needed to be in LD_LIBRARY_PATH
        ;;
      *)
        SER_EXTRA_LDFLAGS=`echo $SER_EXTRA_LDFLAGS -L$LIBGFORTRAN_DIR`
        PAR_EXTRA_LDFLAGS=`echo $PAR_EXTRA_LDFLAGS -L$LIBGFORTRAN_DIR`
        PYC_EXTRA_LDFLAGS=`echo $PYC_EXTRA_LDFLAGS -L$LIBGFORTRAN_DIR`
        case `uname` in
          Linux)
            if isCcGcc; then
              SER_EXTRA_LDFLAGS=`echo $SER_EXTRA_LDFLAGS ${RPATH_FLAG}$LIBGFORTRAN_DIR`
              PAR_EXTRA_LDFLAGS=`echo $PAR_EXTRA_LDFLAGS ${RPATH_FLAG}$LIBGFORTRAN_DIR`
              SER_EXTRA_LT_LDFLAGS=`echo $SER_EXTRA_LDFLAGS ${LT_RPATH_FLAG}$LIBGFORTRAN_DIR`
              PAR_EXTRA_LT_LDFLAGS=`echo $PAR_EXTRA_LDFLAGS ${LT_RPATH_FLAG}$LIBGFORTRAN_DIR`
            fi
            addtopathvar LD_LIBRARY_PATH $LIBGFORTRAN_DIR
            export LD_LIBRARY_PATH
            PYC_MODFLAGS="$PYC_MODFLAGS -lgomp"
            PYC_EXTRA_LDFLAGS=`echo -- $PYC_EXTRA_LDFLAGS -lgomp ${RPATH_FLAG}$LIBGFORTRAN_DIR`
            PYC_EXTRA_LT_LDFLAGS=`echo -- $PYC_EXTRA_LDFLAGS -lgomp ${LT_RPATH_FLAG}$LIBGFORTRAN_DIR`
            ;;
          esac
        ;;
    esac
  fi
fi

# Determine whether gfortran can handle allocatable arrays inside derived types
if $HAVE_SER_FORTRAN; then
  case `uname`-$FC in
    Linux-*gfortran*)
      LIBFORTRAN_DIR=$LIBGFORTRAN_DIR
      vertmp=`$FC --version | sed -e 's/^GNU Fortran ([^)]*)//'`
      gfortranversion=`echo $vertmp | sed 's/ .*//'`
      GFORTRAN_GOOD=${GFORTRAN_GOOD:-"false"}
      case "$gfortranversion" in
        4.[3-9].*)
          GFORTRAN_GOOD=true
          techo "gfortran is of sufficiently high version."
          ;;
        *)
          techo "gfortran not of sufficiently high version."
          techo "It cannot handle allocatable arrays inside derived types."
          techo "Install per README-gfortran or set FC to set compiler."
          ;;
      esac
      ;;
  esac
fi

######################################################################
#
# PYC_LD_RUN_PATH
#
######################################################################

if test `uname` = Linux; then
  if test -n "$PYC_LD_RUN_PATH"; then
    PYC_LD_RUN_VAR="LD_RUN_PATH=$PYC_LD_RUN_PATH"
    PYC_LD_RUN_ARG="-e '$PYC_LD_RUN_VAR'"
    if test "$CC" = gcc; then
      addtopathvar LD_RUN_PATH $PYC_LD_RUN_PATH
    fi
  fi
  export LD_RUN_PATH
  trimvar LD_RUN_PATH ':'
  if test -n "$LD_RUN_PATH"; then
    LD_RUN_VAR="LD_RUN_PATH=$LD_RUN_PATH"
    LD_RUN_ARG="-e '$LD_RUN_VAR'"
  fi
fi

######################################################################
#
# Set the Fortran compiler variables
#
######################################################################

techo "Finding the parallel fortran compilers."
findParallelFcComps

######################################################################
#
# Default compiler flags.
#
######################################################################

USE_CCXX_PIC_FLAG=${USE_CCXX_PIC_FLAG:-"true"}
USE_FORTRAN_PIC_FLAG=${USE_FORTRAN_PIC_FLAG:-"true"}
addDefaultCompFlags

######################################################################
#
# Parallel flags
#
######################################################################

techo -2 "Setting parallel flags."
# Parallel flags default to serial
MPI_CFLAGS=${MPI_CFLAGS:-"$CFLAGS"}
MPI_CXXFLAGS=${MPI_CXXFLAGS:-"$CXXFLAGS"}
MPI_FFLAGS=${MPI_FFLAGS:-"$FFLAGS"}
MPI_FCFLAGS=${MPI_FCFLAGS:-"$FCFLAGS"}

######################################################################
#
# Make combined flags
#
######################################################################

techo "Making the combined flags."
getCombinedCompVars
getCombinedCompFlagVars

######################################################################
#
# Find the right version of various executables
#
######################################################################

# Find gtar
if test -z "$TAR"; then
  if which gtar 1>/dev/null 2>&1; then
    TAR=gtar
  else
    TAR=tar
    techo "No gtar found, so using tar."
  fi
fi
TAR="$TAR --no-same-owner"
techo "TAR = $TAR."

# Find diff
if test -z "$BILDER_DIFF"; then
  BILDER_DIFF=diff
  if test -x /usr/bin/diff; then
    BILDER_DIFF=/usr/bin/diff
  fi
fi

# Find the sendmail
SENDMAIL=${SENDMAIL:-"sendmail"}
PATHSAV=$PATH
PATH="$PATH":/usr/lib:/usr/sbin
if ! which $SENDMAIL 1>/dev/null 2>&1; then
  techo "SENDMAIL = $SENDMAIL not found in $PATH.  Unsetting."
  unset SENDMAIL
else
  techo "SENDMAIL = $SENDMAIL."
fi
PATH="$PATHSAV"

# Determine opencascade or oce
USE_OCC=${USE_OCC:-"oce"}
export USE_OCC

######################################################################
#
# Determine whether to ignore cmake for some hosts.
# Determine some cmake variables.
#
######################################################################

if test -z "$PREFER_CMAKE"; then
  PREFER_CMAKE="false"
  case ${UQMAILHOST}-${USER} in
    numbersix-* | octet-* | multipole-*)
      PREFER_CMAKE=true
      ;;
  esac
  # techo "Setting PREFER_CMAKE to $PREFER_CMAKE."
else
  : # techo "PREFER_CMAKE already set to $PREFER_CMAKE."
fi
# techo exit; exit
if test -n "$JENKINS_FSROOT"; then
  CUDA_ALL_COMPUTE_CAPABILITIES=${CUDA_ALL_COMPUTE_CAPABILITIES:-"true"}
fi
CUDA_ALL_COMPUTE_CAPABILITIES=${CUDA_ALL_COMPUTE_CAPABILITIES:-"false"}

######################################################################
#
# Get the general combined variables.
#
######################################################################

getCombinedCompVars

######################################################################
#
# Find linear algebra libraries
#
######################################################################

USE_MKL=${USE_MKL:-"false"}  # Make sure set
LINK_WITH_MKL=${LINK_WITH_MKL:-"false"}  # Make sure set
findBlasLapack

######################################################################
#
# Do not build gstreamer chain by default.
#
######################################################################

GST_PLUGINS_BASE_BUILDS=${GST_PLUGINS_BASE_BUILDS:-"NONE"}

######################################################################
#
# Variables one can add to configure lines
#
######################################################################

if test -n "$SER_EXTRA_LDFLAGS"; then
  trimvar SER_EXTRA_LD_FLAGS ' '
  SER_CONFIG_LDFLAGS="LDFLAGS='$SER_EXTRA_LDFLAGS'"
fi

if test -n "$PAR_EXTRA_LDFLAGS" -o -n "$MPI_RPATH_ARG"; then
  trimvar PAR_EXTRA_LD_FLAGS ' '
  PAR_CONFIG_LDFLAGS="LDFLAGS='$PAR_EXTRA_LDFLAGS'"
fi

######################################################################
#
# Clean out leading and trailing spaces, colons, double colons
#
######################################################################

for i in PATH LD_LIBRARY_PATH PYC_LDFLAGS PYC_MODFLAGS SER_EXTRA_LDFLAGS PAR_EXTRA_LDFLAGS PYC_EXTRA_LDFLAGS; do
  trimvar $i ':'
done
techo "After trimvar, PATH = '$PATH'"

######################################################################
#
# Modifications under jenkins/unibild
#
######################################################################

if test -n "$BUILD_URL"; then
  BLDR_PROJECT_URL=${BUILD_URL}/artifact
fi

# If true, buildChain being used, so can echo blank lines differently.
USING_BUILD_CHAIN=false

######################################################################
#
# Write variables to log files
#
######################################################################

techo -2 "Trimming and writing out all variables."
hostvars="USER BLDRHOSTID CPUINFO FQHOSTNAME UQHOSTNAME FQMAILHOST UQMAILHOST FQWEBHOST MAILSRVR"
instdirsvars="BLDR_INSTALL_DIR CONTRIB_DIR DEVELDOCS_DIR USERDOCS_DIR SVNPKGS_TOPDIR TMPDIR"
pathvars="PATH PATH_NATIVE CONFIG_SUPRA_SP_ARG CMAKE_SUPRA_SP_ARG SYS_LIBSUBDIRS LD_LIBRARY_PATH LD_RUN_PATH LD_RUN_VAR LD_RUN_ARG PKG_CONFIG_PATH"
source $BILDER_DIR/mkvars.sh
vervars="BILDER_CHAIN GCC_VERSION GCC_MAJMIN GCC_MAJOR GCC_MINOR SVN_BLDRVERSION BLDR_SVNVERSION"
linalgargs="CMAKE_LINLIB_SER_ARGS CONFIG_LINLIB_SER_ARGS LINLIB_SER_LIBS CMAKE_LINLIB_BEN_ARGS CONFIG_LINLIB_BEN_ARGS LINLIB_BEN_LIBS"
compvars="FORPYTHON_STATIC_BUILD FORPYTHON_SHARED_BUILD USE_MPI MPI_BUILD CONFIG_COMPILERS_SER CONFIG_COMPILERS_PAR CONFIG_COMPILERS_BEN CONFIG_COMPILERS_PYC CMAKE_COMPILERS_SER CMAKE_COMPILERS_PAR CMAKE_COMPILERS_BEN CMAKE_COMPILERS_PYC"
flagvars="CONFIG_COMPFLAGS_SER CONFIG_COMPFLAGS_PAR CONFIG_COMPFLAGS_PYC CMAKE_COMPFLAGS_SER CMAKE_COMPFLAGS_PAR CMAKE_COMPFLAGS_PYC"
cmakevars="PREFER_CMAKE USE_CMAKE_ARG CMAKE_LIBRARY_PATH_ARG REPO_NODEFLIB_FLAGS TARBALL_NODEFLIB_FLAGS CUDA_ALL_COMPUTE_CAPABILITIES"
testvars="BILDER_CTEST_MODEL"
mkjvars="NUM_PHYS_CORES NUM_LOG_CORES MAKEJ_TOTAL MAKEJ_DEFVAL JMAKE"
ldvars="GLIBC_VERSION LIBGFORTRAN_DIR SER_EXTRA_LDFLAGS PAR_EXTRA_LDFLAGS PYC_EXTRA_LDFLAGS SER_CONFIG_LDFLAGS PAR_CONFIG_LDFLAGS"
instvars="BUILD_INSTALLERS INSTALLER_HOST INSTALLER_ROOTDIR"
othervars="BLDR_BUILD_NUMPY USE_ATLAS_PYCSH USE_OCC DOCS_BUILDS BILDER_TOPURL BLDR_PROJECT_URL BLDR_BUILD_URL"

techo ""
techo "Environment settings:"
completevars="RUNNRSYSTEM $hostvars $instdirsvars $pathvars $vervars $allvars $linalgargs $compvars $flagvars $genvars $cmakevars $testvars $qtvars $mkjvars $ldvars $instvars $othervars"
for i in $completevars; do
  trimvar $i ' '
  printvar $i
done
techo "All variables written."

env >$BUILD_DIR/bilderenv.txt

# techo "WARNING: [bildvars.sh] Quitting at end of bildvars.sh."; exit

