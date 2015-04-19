#!/bin/bash
#
# $Id$
#
# Determine the python version and library path
#
######################################################################

techo
techo "Determining Python version."
# Make sure we get the built version
addtopathvar PATH $CONTRIB_DIR/python/bin
# Remove trailing carriage return on windows
pymajver=`python -c "import sys;print sys.version[0]" | tr -d '\r'`
techo "Python major version is '$pymajver'."
pyminver=`python -c "import sys;print sys.version[2]" | tr -d '\r'`
techo "Python minor version is '$pyminver'."
PYTHON_MAJMIN=${pymajver}.${pyminver}
NO_PYTHON=false
if test $pymajver -lt 2; then
  techo "Python version \($pymajver.$pyminver\) too old.  Must be 2.5 at least."
  NO_PYTHON=true
elif test $pymajver -eq 2; then
  if test $pyminver -lt 5; then
    techo "Python version \($pymajver.$pyminver\) too old.  Must be 2.5 at least."
    NO_PYTHON=true
  else
    techo "Python $pymajver.$pyminver is recent enough to build packages."
  fi
else
  techo "Unknown whether python version \($pymajver.$pyminver\) sufficient."
  techo "Proceeding as if it is."
fi

if ! $NO_PYTHON; then
  PYTHON=`which python`
# Make sure we are using the correct paths.  Cmake python needed on CYGWIN.
  case `uname` in
    CYGWIN*) MIXED_PYTHON="$(cygpath -am $PYTHON)";;
          *) MIXED_PYTHON=$PYTHON;;
  esac
  PYTHON_INCDIR=`python -c "import distutils.sysconfig; idir = distutils.sysconfig.get_python_inc(1); print idir," 2>/dev/null | tr -d '\r'`
  PYTHON_TOPLIBDIR=`python -c "import distutils.sysconfig; tldir = distutils.sysconfig.get_python_lib(1,1); print tldir," 2>/dev/null | tr -d '\r'`

# Windows stuff.
# Clean out backslashes for cmake compatibility.
  if [[ `uname` =~ CYGWIN ]]; then
    PYTHON_INCDIR=`cygpath -am $PYTHON_INCDIR`
    PYTHON_TOPLIBDIR=`cygpath -am $PYTHON_TOPLIBDIR`
# Ensure that python compiler file has the right permissions
    pycompfile="$PYTHON_TOPLIBDIR/distutils/msvc9compiler.py"
    pycompfilecw=`cygpath -au $pycompfile`
    if ! cp $pycompfilecw $BUILD_DIR; then
      techo "$pycompfile does not have read permissions.  Will fix."
      cmd="chmod a+r $pycompfilecw"
      techo "$cmd"
      $cmd 2>&1 | tee -a $LOGFILE
      cmd="ls -l $pycompfilecw"
      techo "$cmd"
      $cmd 2>&1 | tee -a $LOGFILE
    else
      techo "$pycompfile has correct read permissions."
    fi
    rm -f $BUILD_DIR/$pycompfile
  fi

#
# This needs fixing that works for both cygwin and linux.  Not clear
# that all is needed on Windows.
#
  case `uname` in
    CYGWIN*)
      PYTHON_DIR=`dirname $PYTHON_TOPLIBDIR`
      PYTHON_LIBDIR=$PYTHON_DIR/libs
      PYTHON_VERDIR=$PYTHON_DIR
      PYTHON_LIBSUBDIR=Lib
      ;;
    *)
      PYTHON_LIBDIR=`dirname $PYTHON_TOPLIBDIR`
      PYTHON_DIR=`dirname $PYTHON_LIBDIR`
      PYTHON_VERDIR=`basename $PYTHON_TOPLIBDIR`
      PYTHON_LIBSUBDIR=`basename $PYTHON_LIBDIR`
      ;;
  esac
  unset PYTHON_LIB
# Look for python lib in unix places.  Prefer static.
  if ! [[ `uname` =~ CYGWIN ]]; then
    pylibdirs="$PYTHON_LIBDIR $PYTHON_LIBDIR/python${PYTHON_MAJMIN}/config"
    for i in a so dylib; do # Prefer static lib
      for dir in $pylibdirs; do
        if test -f $dir/libpython${PYTHON_MAJMIN}.$i; then
          PYTHON_LIB=$dir/libpython${PYTHON_MAJMIN}.$i
          PYTHON_LLIB=-lpython$PYTHON_MAJMIN
          PYTHON_LIB_LIBDIR=$dir
          break
        fi
      done
      if test -n "$PYTHON_LIB"; then
        break
      fi
    done
  fi
# Visit needs shared Python lib in some cases, so define this as well
  for i in so dylib; do
    for dir in $pylibdirs; do
      if test -f $dir/libpython${PYTHON_MAJMIN}.$i; then
        PYTHON_SHLIB=$dir/libpython${PYTHON_MAJMIN}.$i
        break
      fi
    done
    if test -n "$PYTHON_SHLIB"; then
      break
    fi
  done
# If not found, set to PYTHON_LIB and hope for the best
  PYTHON_SHLIB=${PYTHON_SHLIB:-"$PYTHON_LIB"}
# Look for Windows python lib
  if test -z "$PYTHON_LIB"; then
    cand=$PYTHON_DIR/libs/python${pymajver}${pyminver}.lib
    case `uname` in
      CYGWIN*)
        tcand=`cygpath -u $cand`
        ;;
      *)
        tcand=$cand
        ;;
    esac
    techo "Looking for $tcand."
    if test -f $tcand; then
      PYTHON_LIB=$cand
      PYTHON_LLIB=-lpython${pymajver}${pyminver}
      PYTHON_LIB_LIBDIR=$PYTHON_LIBDIR/libs
    fi
  fi
  if test -z "$PYTHON_LIB"; then
    techo "PYTHON_LIB not found."
  fi

# Possible locations of packages
  PYINSTDIR=${BLDR_INSTALL_DIR}/${PYTHON_LIBSUBDIR}/${PYTHON_VERDIR}/site-packages
  case `uname` in
    CYGWIN*)
      PYTHON_SITEPKGSDIR=${CONTRIB_DIR}/Lib/site-packages
      NATIVE_PYTHON_SITEPKGSDIR=`cygpath -aw ${PYTHON_SITEPKGSDIR} | sed 's/\\\\/\\\\\\\\/g'`
      MIXED_PYTHON_SITEPKGSDIR=`cygpath -am ${PYTHON_SITEPKGSDIR}`
      ;;
    Darwin | Linux)
      PYTHON_SITEPKGSDIR=${CONTRIB_DIR}/lib/${PYTHON_VERDIR}/site-packages
      NATIVE_PYTHON_SITEPKGSDIR=${PYTHON_SITEPKGSDIR}
      MIXED_PYTHON_SITEPKGSDIR=${PYTHON_SITEPKGSDIR}
      ;;
  esac
# Add site-packages to front of path.
# If path already added, remove so as not to mix versions.
  echo "NATIVE_PYTHON_SITEPKGSDIR = $NATIVE_PYTHON_SITEPKGSDIR"
  unset BILDER_PYTHONPATH
# Below ensures the final sourced file is correct
  addtopathvar PYTHONPATH "$PYTHON_SITEPKGSDIR"
  case `uname` in
    CYGWIN*) trimvar PYTHONPATH ';' ;;
    *) trimvar PYTHONPATH ':' ;;
  esac
  export PYTHONPATH
fi

#
# Set distutils env now that PYTHONPATH is known
#
setDistutilsEnv

######################################################################
#
# If fortran is gfortran4, create a link to gfortran in the bilder
# directory to fool the numpy build system
#
######################################################################

case $PYC_FC in
  *gfortran4)
    if ! which gfortran 1>/dev/null 2>&1; then
      rm -f $BILDER_DIR/gfortran
      ln -s `which $PYC_FC` $BILDER_DIR/gfortran
      addtopathvar PATH $BILDER_DIR
    fi
    ;;
esac
if [[ "$PYC_FC" =~ gfortran ]]; then
  techo "gfortran is `which gfortran`"
fi

######################################################################
#
# Write variables to log files
#
######################################################################

techo "Python is version $pymajver.$pyminver"

for i in PYTHONPATH; do
  trimvar $i ':'
done

completevars="PYTHON MIXED_PYTHON PYTHON_SITEPKGSDIR NATIVE_PYTHON_SITEPKGSDIR PYTHONPATH PYTHON_BLDRVERSION PYTHON_MAJMIN PYTHON_DIR PYTHON_INCDIR PYTHON_TOPLIBDIR PYTHON_LIBDIR PYTHON_LIBSUBDIR PYTHON_LIB PYTHON_LLIB PYTHON_SHLIB PYTHON_LIB_LIBDIR FORPYTHON_SHARED_BUILD FORPYTHON_STATIC_BUILD"
for i in $completevars; do
  val=`derefpath $i`
  if test -n "$val"; then
    if ! [[ `uname` =~ CYGWIN ]]; then
      if cd $val 2>/dev/null; then
        val=`pwd -P`
        eval $i="$val"
        cd - 1>/dev/null 2>&1
      fi
    fi
    techo "$i = \"$val\""
  else
    techo "$i is unset"
  fi
done

