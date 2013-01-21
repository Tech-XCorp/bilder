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
# If installer hosts set or testing set, always make packages
#
######################################################################

if $POST2DEPOT; then
  if test -z "$INSTALLER_HOST" -o -z "$INSTALLER_ROOTDIR"; then
    techo "No INSTALLER_HOST or INSTALLER_ROOTDIR specified."
    POST2DEPOT=false
    techo "Turning off post to depot: POST2DEPOT=$POST2DEPOT."
  fi
fi

# If testing or posting, force building packages
if $TESTING || $POST2DEPOT; then
  techo "Either testing or posting to depot, so building packages."
  BUILD_INSTALLERS=true
fi
if $BUILD_INSTALLERS; then
  techo "Will build packages."
else
  techo "Will not build packages."
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
# Add parallel path now before absolute paths determined by getCombinedCompVars
addtopathvar PATH $CONTRIB_DIR/openmpi/bin
techo "PATH = $PATH"

######################################################################
#
# OS can set any unset flags
#
######################################################################

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
    LIBEXT=.lib
    unset LIBPREFIX
# Should be able to use systeminfo to get the number of cores
    MPICC=${MPICC:-"cl"}
    MPICXX=${MPICXX:-"cl"}
    PREFER_CMAKE=${PREFER_CMAKE:-"true"}
    SHOBJEXT=.dll
    if which blat 1>/dev/null 2>&1; then
      SENDMAIL=blat
    fi
    mylink=`which link`
    if test "$mylink" = /usr/bin/link; then
      techo "WARNING: Wrong link (/usr/bin/link) in path on cygwin."
      techo "WARNING: Cannot build some packages."
      techo "WARNING: 'which link' must return the link executable from Visual Studio."
      return 1
    fi
    mysort=`which sort`
    if test "$mysort" != /usr/bin/sort; then
      techo "WARNING: Not using /usr/bin/sort from cygwin (found $mysort)."
      return 1
    fi
    USE_ATLAS_CC4PY=true
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
    ATLAS_BUILDS=NONE	# Since using framework Accelerate
    if test -n "$ARCHFLAGS"; then
      techo "WARNING: ARCHFLAGS = $ARCHFLAGS.  Potential Python package build problems."
    fi
    ARCHIVER=ar
    SYSTEM_BLAS_SER_LIB="-framework Accelerate"
    SYSTEM_LAPACK_SER_LIB="-framework Accelerate"
    LIBEXT=.a
    LIBPREFIX=lib
    if ! MAKEJ_MAX=`hwprefs cpu_count 2>/dev/null`; then
      MAKEJ_MAX=`sysctl -n hw.ncpu`
    fi
    OSVER=`uname -r`
# On Darwin, jenkins is not getting /usr/local/bin
    if ! echo $PATH | egrep -q "(^|:)/usr/local/bin($|:)"; then
      PATH="$PATH":/usr/local/bin
    fi
    case "$OSVER" in
      9.[4-8].*)
        READLINK=stat
        PYC_CC=${PYC_CC:-"gcc-4.0"}
        PYC_CXX=${PYC_CXX:-"g++-4.0"}
        PYC_LDSHARED=${PYC_LDSHARED:-"gcc-4.0"}
        PYC_MODFLAGS=${PYC_MODFLAGS:-"-undefined dynamic_lookup"}
        ;;
      10.[0-4].*)
        READLINK=readlink
        # PYC_MODFLAGS=${PYC_MODFLAGS:-"-bundle -undefined dynamic_lookup -arch i386 -arch x86_64"}
# 16Jan2010: arch flags appear not to be needed on Darwin 10.5.0.
# Needed on earlier 10.X?
        PYC_MODFLAGS=${PYC_MODFLAGS:-"-undefined dynamic_lookup -arch i386 -arch x86_64"}
        ;;
      10.[5-9].*)
        READLINK=readlink
# Scipy fails to build for later versions of 10.X if the -arch arguments are present.
        PYC_MODFLAGS=${PYC_MODFLAGS:-"-undefined dynamic_lookup"}
        ;;
      11.* | 12.*)
        READLINK=readlink
        # PYC_MODFLAGS=${PYC_MODFLAGS:-"-bundle -undefined dynamic_lookup"}
# 20120329: -bundle seems to be wrong?
# 20121108: but it was present in many packages without harm.
        PYC_MODFLAGS=${PYC_MODFLAGS:-"-undefined dynamic_lookup"}
        ;;
    esac
    QMAKE_PLATFORM_ARGS="-spec macx-g++ -r"
    RPATH_FLAG=${RPATH_FLAG:-"-Wl,-rpath,"}	# For 10.5 and higher
    SHOBJEXT=.dylib
    SHOBJFLAGS=${SHOBJFLAGS:-"-dynamic -flat_namespace -undefined suppress"}
    ;;

  Linux)
    ARCHIVER=ar
    LIBEXT=.a
    LIBPREFIX=lib
    MAKEJ_MAX=`grep ^processor /proc/cpuinfo | wc -l`
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
        sfxorder="so"	# Need shared libs for uedge
        ;;
      i?86)
        SYS_LIBSUBDIRS=lib
        sfxorder="so a"
        ;;
    esac
    PYC_MODFLAGS=${PYC_MODFLAGS:-"-shared"}
    USE_ATLAS_CC4PY=true
    QMAKE_PLATFORM_ARGS="-spec linux-g++ -r"
    READLINK=readlink
    RPATH_FLAG=${RPATH_FLAG:-"-Wl,-rpath,"}
    SHOBJEXT=.so
    SHOBJFLAGS=${SHOBJFLAGS:-"-shared"}
    warnMissingPkgs
    ;;

esac
techo "Found $MAKEJ_MAX cores to build on."
IS_MINGW=${IS_MINGW:-"false"}

######################################################################
#
# Set the maximum value for the j arg to make
#
######################################################################

# Default -j value for make is half the number of processors,
# but not less than 1, and not greater than MKJMAX.
if test -n "$MAKEJ_MAX"; then
  MAKEJ_DEFVAL=`expr $MAKEJ_MAX / 2`
  if test $MAKEJ_DEFVAL -le 0; then
    MAKEJ_DEFVAL=1
  fi
  if test -n "$JMAKE"; then
    if test  "$MAKEJ_DEFVAL" -gt "$JMAKE"; then
      MAKEJ_DEFVAL=$JMAKE
    fi
  fi
  MKJ_DEFARG="-j $MAKEJ_DEFVAL"
fi

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

# Parallel compilers
MPICC=${MPICC:-"mpicc"}
MPICXX=${MPICXX:-"mpicxx"}
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
  ccbase=`basename $CC .exe`
  case `uname` in
    CYGWIN*)
      case $CC in
        *mingw*)
          BILDER_CHAIN=MinGW
          ;;
        *icl.*)
          BILDER_CHAIN=icl
          ;;
        *)
# Need to figure out how to separate versions of vs
          BILDER_CHAIN=Vs${VISUALSTUDIO_VERSION}
          ;;
      esac
      ;;
    Darwin)
      BILDER_CHAIN=$ccbase
      ;;
    Linux)
      case $ccbase in
        path*)  # For pathscale, strip version?
          BILDER_CHAIN=`echo $ccbase | sed -e 's/-[0-9].*$//'`
          ;;
        pgcc)
          BILDER_CHAIN=pgi
          ;;
        *)
          BILDER_CHAIN=$ccbase
          ;;
      esac
      ;;
  esac
fi

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
  echo "----------------------- Found $waitPkg ------------------------------ "

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
      finish -s "$subj" -n
    fi
  fi
else
  techo "WARNING: WAIT_PACKAGE not set in top bilder script."
fi

######################################################################
#
# If mpich, find the library dir, absolute path
#
######################################################################

isMpich2=`mpicc -show 2>/dev/null | grep mpich2`
if test -n "$isMpich2"; then
  MPICH2_LIBDIR=`echo $isMpich2 | sed -e 's/^.*-L//' -e 's/ .*$//'`
  PAR_EXTRA_LDFLAGS="$PAR_EXTRA_LDFLAGS ${RPATH_FLAG}$MPICH2_LIBDIR"
  PAR_EXTRA_LT_LDFLAGS="$PAR_EXTRA_LDFLAGS ${LT_RPATH_FLAG}$MPICH2_LIBDIR"
fi

######################################################################
#
# If gfortran, find extra library dir, and see if high enough version.
#
######################################################################

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
          PYC_LD_LIBRARY_PATH="$gcclibdir":$PYC_LD_LIBRARY_PATH
          trimvar PYC_LD_LIBRARY_PATH :
          PYC_LD_RUN_PATH="$gcclibdir":$PYC_LD_RUN_PATH
          trimvar PYC_LD_RUN_PATH :
          ;;
      esac
    fi
# If extras installed, add in the libdir
    if test -e $CONTRIB_DIR/extras/lib; then
      PYC_LD_LIBRARY_PATH=$CONTRIB_DIR/extras/lib:$PYC_LD_LIBRARY_PATH
      PYC_LD_RUN_PATH=$CONTRIB_DIR/extras/lib:$PYC_LD_RUN_PATH
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
            PYC_EXTRA_LDFLAGS=`echo $PYC_EXTRA_LDFLAGS ${RPATH_FLAG}$LIBGFORTRAN_DIR`
            PYC_EXTRA_LT_LDFLAGS=`echo $PYC_EXTRA_LDFLAGS ${LT_RPATH_FLAG}$LIBGFORTRAN_DIR`
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
  fi
  if test "$CC" = gcc; then
    addtopathvar LD_RUN_PATH $PYC_LD_RUN_PATH
    export LD_RUN_PATH
  fi
  trimvar LD_RUN_PATH ':'
  if test -n "$LD_RUN_PATH"; then
    LD_RUN_VAR="LD_RUN_PATH=$LD_RUN_PATH"
    LD_RUN_ARG="-e '$LD_RUN_VAR'"
  fi
fi
# Below works on benten
PYC_BLDRVERSION=`$PYC_CC --version 2>&1 | head -1 | sed -e 's/^.* //'`
# Below works on octet
PYC_BLDRVERSION=`$PYC_CC --version 2>&1 | head -1 | sed -e 's/^.*CC) *//' -e 's/ .*$//'`

######################################################################
#
# Set the Fortran compiler variables
#
######################################################################

findParallelFcComps

######################################################################
#
# Default compiler flags.
#
######################################################################

# PIC and optimization flags
case $CXX in
  *cl*)
    unset PIC_FLAG
    unset O3_FLAG
    ;;
  mingw*)
    unset PIC_FLAG
    O3_FLAG='-O3'
    ;;
  *path*)
    PIC_FLAG=-fPIC
    O3_FLAG='-O3'
    ;;
  *xl*)
    PIC_FLAG=${PIC_FLAG:-"-qpic=large"}
    O3_FLAG='-O3'
    ;;
  *)
    O3_FLAG='-O3'
    case `uname` in
      MINGW*)
        unset PIC_FLAG
        ;;
      *)
        PIC_FLAG=${PIC_FLAG:-"-fPIC"}
        ;;
    esac
    ;;
esac
PYC_PIC_FLAG=-fPIC

# Pipe flags
case $CC in
  /*/gcc* | gcc*)
    CFLAGS="$CFLAGS -pipe"
    CXXFLAGS="$CXXFLAGS -pipe"
    FLAGS="$FLAGS -pipe"
    F77LAGS="$F77LAGS -pipe"
    ;;
esac

# Add pic and pipe flags for gcc compilers
if [[ $PYC_CC =~ gcc ]] && ! [[ $PYC_CC =~ mingw ]]; then
  if test -n "$PYC_CFLAGS"; then
    PYC_CFLAGS="$PYC_CFLAGS -pipe -fPIC"
    PYC_CXXFLAGS="$PYC_CXXFLAGS -pipe -fPIC"
  else
    PYC_CFLAGS="-pipe -fPIC"
    PYC_CXXFLAGS="-pipe -fPIC"
  fi
fi
if [[ $PYC_FC =~ gfortran ]] && ! [[ $PYC_FC =~ mingw ]]; then
  if test -n "$PYC_FFLAGS"; then
    PYC_FFLAGS="$PYC_FFLAGS -pipe -fPIC"
    PYC_FCFLAGS="$PYC_FCFLAGS -pipe -fPIC"
  else
    PYC_FFLAGS="-pipe -fPIC"
    PYC_FCFLAGS="-pipe -fPIC"
  fi
fi

######################################################################
#
# Add pic flags to all flags
#
######################################################################

# Add PIC flags on flag basis
USE_CCXX_PIC_FLAG=${USE_CCXX_PIC_FLAG:-"true"}
USE_FORTRAN_PIC_FLAG=${USE_FORTRAN_PIC_FLAG:-"true"}
if test -n "$PIC_FLAG"; then
# PIC flags and fortran are always more problematic.  We probably
# need a more robust mechanism for determining when it is OK, and when
# it is not.  Should it be a machines file?  Just an individual build
# issue? etc.  I don't know for sure, but for now, just remove.
#
# Kills Linux build, so putting in an incremental fix: allow disabling
# for Fortran on a per-machine basis by setting USE_FORTRAN_PIC_FLAG=false.
  for i in SER MPI; do
    case $i in
      SER) unset varprfx;;
      *) varprfx=${i}_;;
    esac
    unset piccomps
    if $USE_CCXX_PIC_FLAG; then
      techo "Adding pic flags for C and C++."
      piccomps="C CXX"
    fi
    if $USE_FORTRAN_PIC_FLAG; then
      techo "Adding pic flags for Fortran."
      piccomps="$piccomps F FC"
    fi
    trimvar piccomps ' '
    if test -n "$piccomps"; then
      for j in $piccomps; do
        varname=${varprfx}${j}FLAGS
        varval=`deref $varname`
        eval "$varname='$varval $PIC_FLAG'"
        trimvar $varname ' '
      done
    fi
  done
fi

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

for i in SER PYC PAR; do

  case $i in
    SER) unset varprfx;;
    PAR) varprfx=MPI_;;
    *) varprfx=${i}_;;
  esac

# Configure flags
  unset CONFIG_COMPFLAGS_${i}
  for j in C CXX F FC; do
    oldval=`deref CONFIG_COMPFLAGS_${i}`
    varname=${varprfx}${j}FLAGS
    varval=`deref $varname`
    if test -n "$varval"; then
      eval "CONFIG_COMPFLAGS_${i}=\"$oldval ${j}FLAGS='$varval'\""
    fi
  done
  trimvar ALL_${i}_FLAGS ' '

# CMake flags
  unset CMAKE_COMPFLAGS_${i}
  for j in C CXX FC; do
    case $j in
      CC)
       cmakecompname=C
       ;;
      FC)
       cmakecompname=Fortran
       ;;
      *)
       cmakecompname=$j
       ;;
    esac
    oldval=`deref CMAKE_COMPFLAGS_${i}`
    varname=${varprfx}${j}FLAGS
    varval=`deref $varname`
    if test -n "$varval"; then
      eval "CMAKE_COMPFLAGS_${i}=\"$oldval -DCMAKE_${cmakecompname}_FLAGS:STRING='$varval'\""
    fi
  done
  trimvar ALL_${i}_CMAKE_FLAGS ' '

done

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

######################################################################
#
# Determine whether to ignore cmake for some hosts.
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

######################################################################
#
# Find boost
#
######################################################################

findBoost

######################################################################
#
# Make some vars absolute
#
######################################################################

CMAKE=`which cmake`

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

findBlasLapack

######################################################################
#
# Find the hdf5 libraries
#
######################################################################

findContribPackage Hdf5 hdf5 ser par
case `uname` in
  CYGWIN*) findContribPackage Hdf5 hdf5dll sersh parsh cc4py;;
  *) findContribPackage Hdf5 hdf5 sersh parsh cc4py;;
esac
findCc4pyDir Hdf5
# techo "Quitting in bildvars.sh."; cleanup

#SEK: Just trying to get pynetcdf to work
findContribPackage netcdf netcdf ser par
case `uname` in
  CYGWIN*)
    echo "Not setting netcdf on CYGWIN"
    ;;
  *)
    findContribPackage netcdf netcdf cc4py
    ;;
esac
findCc4pyDir netcdf

######################################################################
#
# Find the Qt libraries.
#
# Start by looking for qmake in one's path.
# If that fails, then look in the contrib dir.
# If that fails, then look for Windows installations.
#
######################################################################

findQt

######################################################################
#
# Variables one can add to configure lines
#
######################################################################

if test -n "$SER_EXTRA_LDFLAGS"; then
  SER_CONFIG_LDFLAGS="LDFLAGS='$SER_EXTRA_LDFLAGS'"
fi

if test -n "$EXTRA_LDFLAGS" -o -n "$MPI_RPATH_ARG"; then
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

techo -2 "Writing out all variables."
hostvars="USER BLDRHOSTID FQHOSTNAME UQHOSTNAME FQMAILHOST UQMAILHOST FQWEBHOST MAILSRVR"
pathvars="PATH PATH_NATIVE CMAKE CONFIG_SUPRA_SP_ARG CMAKE_SUPRA_SP_ARG SYS_LIBSUBDIRS LD_LIBRARY_PATH LD_RUN_PATH LD_RUN_VAR LD_RUN_ARG"
source $BILDER_DIR/mkvars.sh
linalgargs="CMAKE_LINLIB_SER_ARGS CONFIG_LINLIB_SER_ARGS LINLIB_SER_LIBS CMAKE_LINLIB_BEN_ARGS CONFIG_LINLIB_BEN_ARGS LINLIB_BEN_LIBS"
iovars="HDF5_SER_DIR HDF5_PAR_DIR CONFIG_HDF5_SER_DIR_ARG CONFIG_HDF5_PAR_DIR_ARG CONFIG_HDF5_CC4PY_DIR_ARG CMAKE_HDF5_SER_DIR_ARG CMAKE_HDF5_PAR_DIR_ARG CMAKE_HDF5_CC4PY_DIR_ARG NETCDF_SER_DIR NETCDF_PAR_DIR NETCDF_CC4PY_DIR_ARG CONFIG_HDF5_SER_DIR_ARG CONFIG_HDF5_PAR_DIR_ARG CONFIG_NETCDF_CC4PY_DIR_ARG CMAKE_NETCDF_SER_DIR_ARG CMAKE_NETCDF_PAR_DIR_ARG CMAKE_NETCDF_CC4PY_DIR_ARG"
compvars="CONFIG_COMPILERS_SER CONFIG_COMPILERS_PAR CONFIG_COMPILERS_BEN CONFIG_COMPILERS_PYC CMAKE_COMPILERS_SER CMAKE_COMPILERS_PAR CMAKE_COMPILERS_BEN CMAKE_COMPILERS_PYC"
flagvars="CONFIG_COMPFLAGS_SER CONFIG_COMPFLAGS_PAR CONFIG_COMPFLAGS_PYC CMAKE_COMPFLAGS_SER CMAKE_COMPFLAGS_PAR CMAKE_COMPFLAGS_PYC"
envvars="DISTUTILS_ENV DISTUTILS_ENV2 DISTUTILS_NOLV_ENV LINLIB_ENV"
cmakevars="PREFER_CMAKE USE_CMAKE_ARG CMAKE_LIBRARY_PATH_ARG REPO_NODEFLIB_FLAGS TARBALL_NODEFLIB_FLAGS BOOST_INCDIR_ARG"
qtvars="QMAKE_PLATFORM_ARGS QT_BINDIR"
ldvars="SER_EXTRA_LDFLAGS PAR_EXTRA_LDFLAGS PYC_EXTRA_LDFLAGS SER_CONFIG_LDFLAGS PAR_CONFIG_LDFLAGS"
instvars="INSTALLER_HOST INSTALLER_ROOTDIR"
othervars="USE_ATLAS_CC4PY DOCS_BUILDS BILDER_TOPURL BLDR_PROJECT_URL BLDR_BUILD_URL SVN_BLDRVERSION BLDR_SVNVERSION"

techo ""
techo "Environment settings:"
completevars="RUNNRSYSTEM $hostvars $pathvars BILDER_CHAIN $allvars $linalgargs $iovars $compvars $flagvars $envvars $genvars $cmakevars $qtvars $ldvars $instvars $othervars"
for i in $completevars; do
  printvar $i
done
techo "All variables written."

env >$BUILD_DIR/bilderenv.txt

# techo "WARNING: Quitting at end of bildvars.sh."; exit

