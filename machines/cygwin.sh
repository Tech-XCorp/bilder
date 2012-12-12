#!/bin/bash
#
# $Id$
#
# Modify the environment as needed by Visual Studio if not already
# done.  Looks for Visual Studio 10 first, then 9.  Environment
# modified according to which is found first.
#
# Variables can be determined by starting up the Visual Studio
# Command Prompt, then '\cywin\bin\bash.exe --login', and then
# getting the variables, INCLUDE, LIB, LIBPATH, and mods to PATH
# from that shell.
#
######################################################################

# Need to get runnrfcns if not known
if ! declare -f deref 1>/dev/null 2>&1; then
  runnrdir=`dirname $BASH_SOURCE`/../runnr
  runnrdir=`(cd $runnrdir; pwd -P)`
  TECHO=echo
else
  TECHO=techo
fi

# $TECHO "Sourcing cygwin.sh, PATH = $PATH"
$TECHO "VISUALSTUDIO_VERSION = '$VISUALSTUDIO_VERSION'"

IS_64_BIT=false

# Visual Studio is a 32 bit application, so installed in
# MINGW_BINDIR for gfortran
case `uname` in
  CYGWIN*64)
    IS_64_BIT=true
    programfiles='Program Files (x86)'
    MINGW_BINDIR=`which mingw64-gfortran 2>/dev/null`
    ;;
  CYGWIN*)
    MINGW_BINDIR=`which mingw32-gfortran 2>/dev/null`
    programfiles='Program Files'
    ;;
esac
if test -n "$MINGW_BINDIR"; then
  MINGW_BINDIR=`dirname $MINGW_BINDIR`
fi

# Java puts these system directories at the beginning of the PATH,
# so they are picked up by the Jenkins slave. These directories
# cause problems because Windows sort is in the system directory,
# so we need to remove these directories from the beginning of the
# PATH, if they are there.

if echo $PATH | grep -qi '/cygdrive/c/Windows/SysWOW64:'; then
  PATH=`echo $PATH | sed 's?/cygdrive/c/Windows/SysWOW64:??g'`
  PATH="$PATH:/cygdrive/c/Windows/SysWOW64"
fi

if echo $PATH | grep -qi '/cygdrive/c/Windows/System32:'; then
  PATH=`echo $PATH | sed 's?/cygdrive/c/Windows/System32:??g'`
  PATH="$PATH:/cygdrive/c/Windows/System32"
fi

# Add python to front of path.  This may create two copies of 
# the python directory in the path, but that's ok. In a fresh
# cygwin shell /usr/bin/python will be found, which is needed
# for Petsc.  However, if this file is sourced we will find
# the windows version.  Note: that if one installs windows
# python in C:\python26 then this path will find it ok, so
# no need to check that issue.

# For PETSc:
if test -f /usr/bin/python.exe; then
  CYGWIN_PYTHON='/usr/bin/python'
elif test -f /usr/bin/python2.7.exe; then
  CYGWIN_PYTHON='/usr/bin/python2.7'
elif test -f /usr/bin/python2.6.exe; then
  CYGWIN_PYTHON='/usr/bin/python2.6'
elif test -f /usr/bin/python2.5.exe; then
  CYGWIN_PYTHON='/usr/bin/python2.5'
fi

# Make sure that /usr/bin and /bin are just after the Python bin dir
# alexanda 2012-7-31: Changed this to above code that simply moves python to front of path
# PATH="/cygdrive/c/Python26:$PATH"
# JRC 20121111: This screwed me up.  I get my correct with my subversion
# in front of my path, and then move /usr/bin later than python, so that
# the correct subversion is unchanged.  Otherwise, svnversion looks modified.
# Restoring for now.  What we need to figure out is why the qar machines
# do not have the correct paths.
techo -2 "Before /usr/bin move, PATH = $PATH."
if echo ${PATH}: | grep -qi '/cygdrive/c/Python2'; then
# Find locations to be moved
  if echo $PATH | grep -q :/usr/bin:/bin: ; then
    ubp=/usr/bin:/bin
  else
    ubp=/usr/bin
  fi
  mvaft=$ubp
# Move /usr/bin last to find any other python first
  PATH_SAV="$PATH"
  PATH=`echo $PATH | sed -e 's?/usr/bin??'`:/usr/bin
  pythonexec=`which python`
  # echo "pythonexec = $pythonexec."
  aftloc=
  if echo $pythonexec | egrep -q "(p|P)ython2(6|7)"; then
    aftloc=`dirname $pythonexec`
  fi
# Do the move if python found in Windows area
  if test -n "$aftloc"; then
    : # PATH=`echo $PATH_SAV | sed -e "s?:$mvaft:?:?" -e "s?:$aftloc:?:$aftloc:$mvaft:?"`
    PATH=`echo $PATH_SAV | sed -e "s?:$mvaft:?:?" -e "s?:$aftloc:?:$aftloc:$mvaft:?"`
  else
    PATH="$PATH_SAV"
  fi
fi
techo -2 "After /usr/bin move, PATH = $PATH."

# Determine the paths needed by Visual Studio
#
# Args
# 1: the version
getVsPaths() {
  local vsver=$1
  $TECHO "Looking for tools for Visual Studio ${vsver}."
  if ! test -d "/cygdrive/c/Program Files/Microsoft Visual Studio ${vsver}.0"; then
    $TECHO "Microsoft Visual Studio ${vsver}.0 is not installed.  Will not set associated variables."
    return 1
  fi
  BUILD_DIR=${BUILD_DIR:-"."}
  local pathhasvs=false
  local path_sav="$PATH"
  if echo $PATH | grep "Visual Studio ${vsver}"; then
    $TECHO "WARNING: Visual Studio ${vsver} already in your path."
    pathhasvs=true
# Attempts to remove from path
    # PATHVS=`echo $PATH | sed -e "s?^.*\(/cygdrive/c/Program Files/Microsoft Visual Studio ${vsver}\)?\1?" -e "s?\(Windows/v7.0A/bin\).*$?\1?"`
    $TECHO "Temporary path = $PATH."
  fi
  local vscomntools=`deref VS${vsver}0COMNTOOLS`
  $TECHO "VS${vsver}0COMNTOOLS = $vscomntools."
  if [[ `uname` =~ WOW ]] && ! [[ "$vscomntools" =~ "(x86)" ]]; then
    $TECHO "WARNING: 64 bit Windows, but VS${vsver}0COMNTOOLS does not contain (x86)."
  fi

  arch=x86
  if $IS_64_BIT; then
    arch=amd64
  fi

  cat >$BUILD_DIR/getvsvars${vsver}.bat <<EOF
@echo off
echo PATHOLD="%PATH%"
call "%VS${vsver}0COMNTOOLS%\..\..\VC\vcvarsall.bat" $arch >NUL:
echo PATHNEW="%PATH%"
echo LIBPATH_VS${vsver}="%LIBPATH%"
echo LIB_VS${vsver}="%LIB%"
echo INCLUDE_VS${vsver}="%INCLUDE%"
EOF
  (cd $BUILD_DIR; cmd /c getvsvars${vsver}.bat | tr -d '\r' >vs${vsver}vars.sh)
  source $BUILD_DIR/vs${vsver}vars.sh

# Get the path difference
  local PATHOLDM=`echo "$PATHOLD" | sed -e 's?\\\\?/?g'`
  local PATHNEWM=`echo "$PATHNEW" | sed -e 's?\\\\?/?g'`
  local PATH_VAL=`echo "$PATHNEWM" | sed -e "s?$PATHOLDM??g"`

# Convert the paths to cygwin
  rm -f $BUILD_DIR/path_${vsver}.txt
  echo "$PATH_VAL" | tr ';' '\n' | sed '/^$/d' | while read line; do
    cygpath -au "$line": >> $BUILD_DIR/path_${vsver}.txt
  done
  if test -f $BUILD_DIR/path_${vsver}.txt; then
    PATH_CYG=`cat $BUILD_DIR/path_${vsver}.txt | tr -d '\n' | sed 's/:$//'`
  fi
  eval PATH_VS${vsver}="\"$PATH_CYG\""
  echo PATH_VS${vsver} = `deref PATH_VS${vsver}`
}

if $IS_64_BIT; then
  getVsPaths 9
  getVsPaths 10
  getVsPaths 11
else
  PATH_VS9="/cygdrive/c/${programfiles}/Microsoft Visual Studio 9.0/Common7/IDE:/cygdrive/c/${programfiles}/Microsoft Visual Studio 9.0/VC/BIN:/cygdrive/c/${programfiles}/Microsoft Visual Studio 9.0/Common7/Tools:/cygdrive/c/WINDOWS/Microsoft.NET/Framework/v3.5:/cygdrive/c/WINDOWS/Microsoft.NET/Framework/v2.0.50727:/cygdrive/c/${programfiles}/Microsoft Visual Studio 9.0/VC/VCPackages:/cygdrive/c/${programfiles}/Microsoft SDKs/Windows/v6.0A/bin"
  INCLUDE_VS9="C:\\${programfiles}\Microsoft Visual Studio 9.0\VC\INCLUDE;C:\\${programfiles}\Microsoft SDKs\Windows\v6.0A\include;"
  LIB_VS9="C:\\${programfiles}\Microsoft Visual Studio 9.0\VC\LIB;C:\\${programfiles}\Microsoft SDKs\Windows\v6.0A\lib;"
  LIBPATH_VS9="C:\Windows\Microsoft.NET\Framework\v3.5;C:\Windows\Microsoft.NET\Framework\v2.0.50727;C:\\${programfiles}\Microsoft Visual Studio 9.0\VC\LIB;"
# for MSVC10
  PATH_VS10="/cygdrive/c/${programfiles}/Microsoft Visual Studio 10.0/Common7/IDE/:/cygdrive/c/${programfiles}/Microsoft Visual Studio 10.0/VC/BIN:/cygdrive/c/${programfiles}/Microsoft Visual Studio 10.0/VC/bin:/cygdrive/c/${programfiles}/Microsoft Visual Studio 10.0/Common7/Tools:/cygdrive/c/Windows/Microsoft.NET/Framework/v4.0.30319:/cygdrive/c/Windows/Microsoft.NET/Framework/v3.5:/cygdrive/c/${programfiles}/Microsoft Visual Studio 10.0/VC/VCPackages:/cygdrive/c/${programfiles}/Microsoft SDKs/Windows/v7.0A/bin/NETFX 4.0 Tools:/cygdrive/c/${programfiles}/Microsoft SDKs/Windows/v7.0A/bin"
  INCLUDE_VS10="C:\\${programfiles}\Microsoft Visual Studio 10.0\VC\INCLUDE;C:\\${programfiles}\Microsoft SDKs\Windows\v7.0A\include;"
  LIB_VS10="C:\\${programfiles}\Microsoft Visual Studio 10.0\VC\LIB;C:\\${programfiles}\Microsoft SDKs\Windows\v7.0A\lib;C:\\${programfiles}\Microsoft Visual Studio 10.0\VC\lib;C:\\${programfiles}\Microsoft Visual Studio 10.0\VC\lib/amd64;"
  LIBPATH_VS10="C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v3.5;C:\\${programfiles}\Microsoft Visual Studio 10.0\VC\LIB;C:\\${programfiles}\Microsoft Visual Studio 10.0\VC\lib;C:\\${programfiles}\Microsoft Visual Studio 10.0\VC\lib/amd64;"

# for MSVC11
  PATH_VS11="/cygdrive/c/${programfiles}/Microsoft Visual Studio 11.0/Common7/IDE/:/cygdrive/c/${programfiles}/Microsoft Visual Studio 11.0/VC/BIN:/cygdrive/c/${programfiles}/Microsoft Visual Studio 11.0/VC/bin:/cygdrive/c/${programfiles}/Microsoft Visual Studio 11.0/Common7/Tools:/cygdrive/c/Windows/Microsoft.NET/Framework/v4.0.30319:/cygdrive/c/Windows/Microsoft.NET/Framework/v3.5:/cygdrive/c/${programfiles}/Microsoft Visual Studio 11.0/VC/VCPackages:/cygdrive/c/${programfiles}/Microsoft SDKs/Windows/v8.0A/bin/NETFX 4.0 Tools:/cygdrive/c/${programfiles}/Microsoft SDKs/Windows/v8.0A/bin"
  INCLUDE_VS11="C:\\${programfiles}\Microsoft Visual Studio 11.0\VC\INCLUDE;C:\\${programfiles}\Microsoft SDKs\Windows\v8.0A\include;"
  LIB_VS11="C:\\${programfiles}\Microsoft Visual Studio 11.0\VC\LIB;C:\\${programfiles}\Microsoft SDKs\Windows\v8.0A\lib;C:\\${programfiles}\Microsoft Visual Studio 11.0\VC\lib;C:\\${programfiles}\Microsoft Visual Studio 11.0\VC\lib/amd64;"
  LIBPATH_VS11="C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v3.5;C:\\${programfiles}\Microsoft Visual Studio 11.0\VC\LIB;C:\\${programfiles}\Microsoft Visual Studio 11.0\VC\lib;C:\\${programfiles}\Microsoft Visual Studio 11.0\VC\lib/amd64;"
fi

# Set the environments
FULLPATH_VS9=`echo $PATH | sed -e "s%:$PATH_VS10:%:%" -e "s%:$PATH_VS11:%:%"`
FULLPATH_VS9=`echo $FULLPATH_VS9 | sed "s%:/cygdrive%:$PATH_VS9:/cygdrive%"`
ENV_VS9="VS90COMNTOOLS='C:\Program Files\Microsoft Visual Studio 9.0\Common7\Tools' PATH='$FULLPATH_VS9' INCLUDE='$INCLUDE_VS9' LIB='$LIB_VS9' LIBPATH='$LIBPATH_VS9'"
# $TECHO "ENV_VS9 = \"$ENV_VS9\""
FULLPATH_VS10=`echo $PATH | sed -e "s%:$PATH_VS9:%:%" -e "s%:$PATH_VS11:%:%"`
FULLPATH_VS10=`echo $FULLPATH_VS10 | sed "s%:/cygdrive%:$PATH_VS10:/cygdrive%"`
ENV_VS10="VS100COMNTOOLS='C:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools' PATH='$FULLPATH_VS10' INCLUDE='$INCLUDE_VS10' LIB='$LIB_VS10' LIBPATH='$LIBPATH_VS10'"
# $TECHO "ENV_VS10 = \"$ENV_VS10\""
FULLPATH_VS11=`echo $PATH | sed -e "s%:$PATH_VS9:%:%" -e "s%:$PATH_VS10:%:%"`
FULLPATH_VS11=`echo $FULLPATH_VS11 | sed "s%:/cygdrive%:$PATH_VS11:/cygdrive%"`
ENV_VS11="VS110COMNTOOLS='C:\Program Files\Microsoft Visual Studio 11.0\Common7\Tools' PATH='$FULLPATH_VS11' INCLUDE='$INCLUDE_VS11' LIB='$LIB_VS11' LIBPATH='$LIBPATH_VS11'"
# $TECHO "ENV_VS11 = \"$ENV_VS11\""

setVs9Vars() {
# Remove old from PATH
# if MINGW_BINDIR does not exist, don't try to substitute or we'll remove
# a needed colon.
  if test -n "$MINGW_BINDIR"; then
    PATH=`echo $PATH | sed -e "s%:$PATH_VS10:%:%" -e "s%:$PATH_VS11:%:%" -e "s%:$MINGW_BINDIR%%"`
  else
    PATH=`echo $PATH | sed -e "s%:$PATH_VS10:%:%" -e "s%:$PATH_VS11:%:%"`
  fi
# Add new
  $TECHO "setVs9Vars... Adding Visual Studio 9 variables to environment."
  $TECHO "setVs9Vars... before PATH = $PATH"
  PATH=`echo $PATH | sed "s%:/cygdrive%:$PATH_VS9:/cygdrive%"`:$MINGW_BINDIR
# Do we need to make sure /usr/bin is before /cygdrive/c/Windows/system32?
  export INCLUDE="$INCLUDE_VS9"
  export LIB="$LIB_VS9"
  export LIBPATH="$LIBPATH_VS9"
  $TECHO "setVs9Vars... after PATH = $PATH"
  $TECHO "setVs9Vars... INCLUDE = $INCLUDE"
  $TECHO "setVs9Vars... LIB = $LIB"
  $TECHO "setVs9Vars... LIBPATH = $LIBPATH"
}

setVs10Vars() {
# Remove old from PATH
# if MINGW_BINDIR does not exist, don't try to substitute or we'll remove
# a needed colon.
  if test -n "$MINGW_BINDIR"; then
    PATH=`echo $PATH | sed -e "s%:$PATH_VS9:%:%" -e "s%:$PATH_VS11:%:%" -e "s%:$MINGW_BINDIR%%"`
  else
    PATH=`echo $PATH | sed -e "s%:$PATH_VS9:%:%" -e "s%:$PATH_VS11:%:%"`
  fi
# Add new
  PATH=`echo $PATH | sed "s%:/cygdrive%:$PATH_VS10:/cygdrive%"`:$MINGW_BINDIR
  export INCLUDE="$INCLUDE_VS10"
  export LIB="$LIB_VS10"
  export LIBPATH="$LIBPATH_VS10"
  $TECHO "setVs10Vars... Adding Visual Studio 10 variables to environment."
  $TECHO "setVs10Vars... PATH = $PATH"
  $TECHO "setVs10Vars... INCLUDE = $INCLUDE"
  $TECHO "setVs10Vars... LIB = $LIB"
  $TECHO "setVs10Vars... LIBPATH = $LIBPATH"
}

setVs11Vars() {
# Remove old from PATH
# if MINGW_BINDIR does not exist, don't try to substitute or we'll remove
# a needed colon.
  if test -n "$MINGW_BINDIR"; then
    PATH=`echo $PATH | sed -e "s%:$PATH_VS9:%:%" -e "s%:$PATH_VS10:%:%" -e "s%:$MINGW_BINDIR%%"`
  else
    PATH=`echo $PATH | sed -e "s%:$PATH_VS9:%:%" -e "s%:$PATH_VS10:%:%"`
  fi
# Add new
  PATH=`echo $PATH | sed "s%:/cygdrive%:$PATH_VS11:/cygdrive%"`:$MINGW_BINDIR
  export INCLUDE="$INCLUDE_VS11"
  export LIB="$LIB_VS11"
  export LIBPATH="$LIBPATH_VS11"
  $TECHO "setVs11Vars... Adding Visual Studio 11 variables to environment."
  $TECHO "setVs11Vars... PATH = $PATH"
  $TECHO "setVs11Vars... INCLUDE = $INCLUDE"
  $TECHO "setVs11Vars... LIB = $LIB"
  $TECHO "setVs11Vars... LIBPATH = $LIBPATH"
}

hasvisstudio=`echo $PATH | grep -i "/$programfiles/Microsoft Visual Studio"`
if test -n "$hasvisstudio"; then
  $TECHO "Found a Visual Studio in your path.  Not adding."
else
  if test -z "$VISUALSTUDIO_VERSION"; then
# Use VS 11 if present
    if test -d "/cygdrive/c/$programfiles/Microsoft Visual Studio 11.0/Common7/IDE"; then
      VISUALSTUDIO_VERSION=11
      $TECHO "Found Visual Studio 11."
    elif test -d "/cygdrive/c/$programfiles/Microsoft Visual Studio 10.0/Common7/IDE"; then
      VISUALSTUDIO_VERSION=10
      $TECHO "Found Visual Studio 10."
    elif test -d "/cygdrive/c/$programfiles/Microsoft Visual Studio 9.0/Common7/IDE"; then
      VISUALSTUDIO_VERSION=9
      $TECHO "Found Visual Studio 9."
    fi
  fi
  case "$VISUALSTUDIO_VERSION" in
    11)
      nopathvisstudio=`echo $PATH | grep -i "/cygdrive/c/$programfiles/Microsoft Visual Studio 11.0/VC/BIN:"`
      if test -z "$nopathvisstudio"; then
        setVs11Vars
      fi
      ;;
    10)
      nopathvisstudio=`echo $PATH | grep -i "/cygdrive/c/$programfiles/Microsoft Visual Studio 10.0/VC/BIN:"`
      if test -z "$nopathvisstudio"; then
        setVs10Vars
      fi
      ;;
    9)
      nopathvisstudio=`echo $PATH | grep -i "/cygdrive/c/$programfiles/Microsoft Visual Studio 9.0/VC/BIN:"`
      if test -z "$nopathvisstudio"; then
        setVs9Vars
      fi
      ;;
    *)
      $TECHO "WARNING: Visual Studio not found and not in path."
      ;;
  esac
fi
