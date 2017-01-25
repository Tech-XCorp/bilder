#!/bin/bash
#
# $Id$
#
# Modify the environment as needed by Visual Studio if not already
# done.  Looks for Visual Studio 10 first, then 9.  Environment
# modified according to which is found first.
#
# Compiling 64 bit using express: http://jenshuebel.wordpress.com/2009/02/12/visual-c-2008-express-edition-and-64-bit-targets/
#
# Variables can be determined by starting up the Visual Studio
# Command Prompt, then '\cywin\bin\bash.exe --login', and then
# getting the variables, INCLUDE, LIB, LIBPATH, and mods to PATH
# from that shell.
#
######################################################################

# Need to get runnrfcns if not known
if ! declare -f derefpath 1>/dev/null 2>&1; then
  runnrdir=`dirname $BASH_SOURCE`/../runnr
  if test -d $runnrdir; then
    runnrdir=`(cd $runnrdir; pwd -P)`
    source $runnrdir/runnrfcns.sh
  fi
fi
if declare -f techo 1>/dev/null 2>&1; then
  TECHO=techo
  TECHO2="techo -2"
else
  TECHO=echo
  TECHO2=echo
fi

# $TECHO "NOTE: [cygwin.sh] Sourcing cygwin.sh, PATH = $PATH"
$TECHO "VISUALSTUDIO_VERSION = '$VISUALSTUDIO_VERSION'"

# Determine pointer size, location of visual studio
IS_64_BIT=false
if wmic os get osarchitecture | grep -q 64-bit; then
  IS_64_BIT=true
  programfiles='Program Files (x86)'
else
  programfiles='Program Files'
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

# Put openssl at the front of the path
putOsslInFront() {
  ossldir=`echo $PATH | sed -e 's?^.*\(/cygdrive/./OpenSSL\)?\1?I' -e 's?:.*$??'`
  test -z "$ossldir" && return
  techo "Putting OpenSSL at the front of the path."
  newpath=`echo $PATH | sed -e "s?:$ossldir:?:?"`
  if ! [[ $ossldir =~ /bin$ ]]; then
    techo "NOTE: [cygwin.vs] $ossldir does not end in bin. Appending."
    ossldir="$ossldir:$ossldir/bin"
  fi
  PATH="$ossldir:$newpath"
}

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
# alexanda 2012-7-31: Changed this to above code that simply moves
#   python to front of path
# PATH="/cygdrive/c/Python26:$PATH"
# JRC 20121111: This screwed me up.  I get mine correct with my subversion
# in front of my path, and then move /usr/bin later than python, so that
# the correct subversion is unchanged.  Otherwise, svnversion looks modified.
# Restoring for now.  What we need to figure out is why the qar machines
# do not have the correct paths.
$TECHO2 "Before /usr/bin move, PATH = $PATH."

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
  if echo $pythonexec | egrep -qi "Python2(6|7)"; then
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
$TECHO2 "After /usr/bin move, PATH = $PATH."

# Determine the paths needed by Visual Studio
#
# Args
# 1: the version
getVsPaths() {
  local vsver=$1
  $TECHO "Looking for tools for Visual Studio ${vsver}."
  if ! test -d "/cygdrive/c/$programfiles/Microsoft Visual Studio ${vsver}.0"; then
    $TECHO "Microsoft Visual Studio ${vsver}.0 is not installed.  Will not set associated variables."
    return 1
  fi
  local workdir=${BUILD_DIR:-"."}
  local pathhasvs=false
  local path_sav="$PATH"
  if echo $PATH | grep "Visual Studio ${vsver}"; then
    $TECHO "WARNING: Visual Studio ${vsver} already in your path."
    pathhasvs=true
  fi
  local vscomntools=`deref VS${vsver}0COMNTOOLS`
  $TECHO "VS${vsver}0COMNTOOLS = $vscomntools."

  arch=x86
  if $IS_64_BIT; then
    if ! [[ "$vscomntools" =~ "(x86)" ]]; then
      $TECHO "WARNING: 64 bit Windows, but VS${vsver}0COMNTOOLS does not contain (x86)."
    fi
    arch=amd64
    if test $vsver = 12; then
      arch=amd64
    fi
  fi

  cat >$workdir/getvs${vsver}vars.bat <<EOF
@echo off
echo PATHOLD="%PATH%"
call "%VS${vsver}0COMNTOOLS%\..\..\VC\vcvarsall.bat" $arch >NUL:
echo PATHNEW="%PATH%"
echo LIBPATH_VS${vsver}="%LIBPATH%"
echo LIB_VS${vsver}="%LIB%"
echo INCLUDE_VS${vsver}="%INCLUDE%"
EOF
  (cd $workdir; cmd /c getvs${vsver}vars.bat | tr -d '\r' >vs${vsver}vars.sh)
  source $workdir/vs${vsver}vars.sh
  rm -f $workdir/vs${vsver}vars.sh $workdir/getvs${vsver}vars.bat

# Get the path difference
  local PATHOLDM=`echo "$PATHOLD" | sed -e 's?\\\\?/?g'`
  local PATHNEWM=`echo "$PATHNEW" | sed -e 's?\\\\?/?g'`
  local PATH_VAL=`echo "$PATHNEWM" | sed -e "s?$PATHOLDM??g"`

# Convert paths to cygwin
  rm -f $workdir/path_${vsver}.txt
  echo "$PATH_VAL" | tr ';' '\n' | sed '/^$/d' | while read line; do
    cygpath -au "$line": >> $workdir/path_${vsver}.txt
  done
  if test -f $workdir/path_${vsver}.txt; then
    local PATH_CYG=`cat $workdir/path_${vsver}.txt | tr -d '\n' | sed 's/:$//'`
  fi
  rm -f $workdir/path_${vsver}.txt
  eval PATH_VS${vsver}="\"$PATH_CYG\""
  echo PATH_VS${vsver} = `deref PATH_VS${vsver}`
# Double slashes on other paths
  local tmp=`derefpath INCLUDE_VS${vsver}`
  eval INCLUDE_VS${vsver}="\"$tmp\""
  tmp=`derefpath LIB_VS${vsver}`
  eval LIB_VS${vsver}="\"$tmp\""
  tmp=`derefpath LIBPATH_VS${vsver}`
  eval LIBPATH_VS${vsver}="\"$tmp\""
}

allVersions="12 11 10 9"

for vsver in $allVersions; do
# This previously done for only 64 bit.  If we return to supporting 32-bit
# windows, getVsPaths will have to be revisited.
  getVsPaths $vsver
done

# Set the environment for a version of Visual Studio
#
# 1: the version
setVsEnv() {
# Convert to consistent kind of path
  local fullpath=`cygpath -aup "$PATH"`
  # $TECHO "At start, fullpath = $fullpath"
  for vsver in $allVersions; do
    local rmpath=`deref PATH_VS$vsver`
    if test -n "$rmpath"; then
      rmpath=`cygpath -aup "$rmpath"`
      # $TECHO "Removing $rmpath"
      fullpath=`echo $fullpath | sed -e "s%:$rmpath:%:%"`
    fi
  done
  local pathvs=`deref PATH_VS${1}`
  if test -z "$pathvs"; then
    TERMINATE_ERROR_MSG="ERROR: [${FUNCNAME}] Visual Studio $1 not found."
    terminate
  fi
  pathvs=`cygpath -aup "$pathvs"`
  fullpath=`echo $fullpath | sed "s%:/cygdrive%:$pathvs:/cygdrive%"`
  # $TECHO "After sed, fullpath = $fullpath"
  export PATH="$fullpath"
  # local cmnvar=VS${1}0COMNTOOLS
  # local cmnval="C:\Program Files\Microsoft Visual Studio ${1}.0\Common7\Tools"
  local inc=`deref INCLUDE_VS${1}`
  export INCLUDE="$inc"
  local lib=`deref LIB_VS${1}`
  export LIB="$lib"
  local libpath=`deref LIBPATH_VS${1}`
  export LIBPATH="$libpath"
  # ENV_VS="PATH='$fullpath' $cmnvar='$cmnval' INCLUDE='$inc' LIB='$lib' LIBPATH='$libpath'"
  ENV_VS="PATH='$PATH' INCLUDE='$INCLUDE' LIB='$LIB' LIBPATH='$LIBPATH'"
  $TECHO "ENV_VS = \"$ENV_VS\""
}

hasvisstudio=`echo $PATH | grep -i "/$programfiles/Microsoft Visual Studio"`
if test -n "$hasvisstudio"; then
  $TECHO "Found a Visual Studio in your path.  Not adding."
else
  if test -z "$VISUALSTUDIO_VERSION"; then
# Try all versions, starting with latest first
    for ver in $allVersions; do
      if test -d "/cygdrive/c/$programfiles/Microsoft Visual Studio ${ver}.0/Common7/IDE"; then
        VISUALSTUDIO_VERSION=$ver
        $TECHO "Found Visual Studio $ver"
	break
      fi
    done
  fi
  if test -n "$VISUALSTUDIO_VERSION"; then
    nopathvisstudio=`echo $PATH | grep -i "/cygdrive/c/$programfiles/Microsoft Visual Studio ${VISUALSTUDIO_VERSION}.0/VC/BIN:"`
    if test -z "$nopathvisstudio"; then
      setVsEnv ${VISUALSTUDIO_VERSION}
    fi
  else
    $TECHO "WARNING: Visual Studio not found and not in path."
  fi
fi

# Determine a path variable for atlas by removing dirs with parens.
# On 64 bit, ensure path to ProgramFiles (x86) has been mounted without parens.
if $IS_64_BIT; then
  pfsubdirs=`ls "/ProgramFilesX86/Microsoft Visual Studio"* 2>/dev/null`
  if test -z "$pfsubdirs"; then
    $TECHO "WARNING: [cygwin.sh] Microsoft Visual Studio not found under /ProgramFilesX86. Will try mounting.  Change /etc/fstab to make this permanent."
    mkdir -p /ProgramFilesX86
    umount /ProgramFilesX86
    cmd="mount 'C:/Program Files (x86)' /ProgramFilesX86"
    $TECHO "NOTE: [cygwin.sh] Executing $cmd"
    eval "$cmd"
  fi
  pfsubdirs=`ls "/ProgramFilesX86/Microsoft Visual Studio"* 2>/dev/null`
  if test -z "$pfsubdirs"; then
    $TECHO "WARNING: [cygwin.sh] /ProgramFilesX86/Microsoft Visual Studio not found on Win64.  Cannot set NOPAREN_PATH."
  else
    NOPAREN_PATH=`echo $PATH | sed -e 's/Program Files (x86)/ProgramFilesX86/g' | tr ':' '\n' | sed '/(/d' | tr '\n' ':'`
  fi
else
  NOPAREN_PATH=`echo $PATH | tr ':' '\n' | sed '/(/d' | tr '\n' ':'`
fi
$TECHO "NOPAREN_PATH = $NOPAREN_PATH"

