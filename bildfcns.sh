######################################################################
#
# bildfcns.sh: A set of methods for configuring and building packages
#
# $Rev$ $Date$
#
######################################################################

######################################################################
#
# Methods
#
######################################################################

#
# Determine whether today is later than some day by a certain number
# of days.
#
# Args:
# 1: The day to compare with in YYYY-MM-DD format
# 2: The number of days that one must be later by
isLaterByDays() {
  techo -2 "Comparing to date, $1."
  cursecs=`date -u +%s`
  case `uname` in
    Darwin)
      prvsecs=`date -uj -f %Y-%m-%d $1 +%s`  # OS X
      ;;
    *)
      prvsecs=`date -u --date=$1 +%s`  # Linux
      ;;
  esac
  days=$((($cursecs - $prvsecs)/86400))
  if test $days -ge $BILDER_WAIT_DAYS; then
    return 0
  fi
  return 1
}

#
# Determine whether build time has elapsed
#
# Args
# 1: the project without the version
# 2: the builds
# 3: the installation directory
#
# -i Any builds to ignore
#
isBuildTime() {
  local ignorebuilds=
  while test -n "$1"; do
    case "$1" in
      -i)
        ignorebuilds=$2
        shift
        ;;
      *)
        break
        ;;
    esac
    shift
  done
  techo -2 "isBuildTime called with $* and ignorebuilds = $ignorebuilds."
  if test -z "$2"; then
    return 1
  fi
  local builds=$2
  local instdir=$3
  if ! test -f $instdir/installations.txt; then
    return 0
  fi
  if test $BILDER_WAIT_DAYS -gt 0; then
    local chkbuilds="$builds"
    if test -n "$ignorebuilds"; then
      for i in `echo $ignorebuilds | tr ',' ' '`; do
        chkbuilds=`echo $chkbuilds | sed -e "s/^$i,//" -e "s/^$i$//g" -e "s/,$i,/,/g" -e "s/,$i$//"`
      done
      trimvar chkbuilds ','
    fi
    techo "Checking age of the "$chkbuilds" builds of $1."
    local si=false
    for i in `echo $chkbuilds | tr ',' ' '`; do
      local buildline=`grep "^${1}-" $instdir/installations.txt | grep -- "-$i " | tail -1`
      if test -z "$buildline"; then
        return 0
      fi
      BILDER_WAIT_LAST_INSTALL=$buildline
      local builddate=`echo $buildline | awk '{print $4}'`
      local buildday=`echo $builddate | sed 's/-[0-9][0-9]:.*$//'`
      if isLaterByDays $buildday $BILDER_WAIT_DAYS; then
        si=true
        techo "Project $1-$i not installed in the last $BILDER_WAIT_DAYS days."
        break
      else
        techo "Project $1-$i installed in the last $BILDER_WAIT_DAYS days."
      fi
    done
    if $si; then
      return 0
    else
      techo "All builds of $1 installed in the last $BILDER_WAIT_DAYS days."
      return 1
    fi
  fi
  return 0
}

#
# Source function to check some syntax of sourced file
#
# Args:
# 1: the name of the shell file to source
#
bilderSource() {
  if test -f $1; then
    cmd=`bash -n $1 2>&1`
    res=$?
    if test $res = 0; then
      source $1
    else
      techo "WARNING: Syntax error found in script: $1"
      techo "WARNING: $cmd"
    fi
  else
    techo "WARNING: Bilder unable to find script, $1, to source."
  fi
}

#
# Get the modification time of a file
#
getFileModTime() {
case `uname` in
  CYGWIN*)
    ls -l --time-style=+%F-%T $1 | awk '{print $6}'
    ;;
  Darwin)
    stat -f "%Sm" -t %F-%T $1
    ;;
  Linux)
    ls -l --time-style=+%F-%T $1 | awk '{print $6}'
    ;;
esac
}

#
# Print a variable
#
# Args:
# 1: the name of the variable
#
printvar() {
  val=`deref $1`
  if test -n "$val"; then
    techo "Variable $1 = \"$val\"."
  else
    techo "Variable $1 is unset."
  fi
}

#
# Make links or shortcuts.
#  CYGWIN: make shortcut and link.
#  MINGW:  make shortcut
#  unix:   make link
#
# Args:
# 1: the directory
# 2: the original node
# 3: the link
#
mkLink() {
  local shortcut
  local unix
  case `uname` in
    CYGWIN*)
      shortcut=true
      unix=true
      ;;
    MINGW*)
      shortcut=true
      unix=false
      ;;
    *)
      shortcut=false
      unix=true
      ;;
  esac
  if $shortcut; then
    techo "(cd $1; rmall $2.lnk $3.lnk; mkshortcut $2; mv $2.lnk $3.lnk)"
    (cd $1; rmall $3.lnk; mkshortcut $2; mv $2.lnk $3.lnk)
  fi
  if $unix; then
    techo "(cd $1; rmall $3; ln -s $2 $3)"
    (cd $1; rmall $3; ln -s $2 $3)
  fi
}

#
# Find the value of the variable whose name is in a variable
#
# Args:
# 1: the name of the variable desired
#
deref() {
  eval echo $`echo $1`
}

#
# svn action on a node.
# This is to work around a windows/unix incompatibility, such
# that doing "window-svn cygwin-node" or vice-versa does not work as
# neither os-svn understands the file system of the other.  So when
# there is an action on a node, one cd's to that node, then executes
# the action.
#
# Use:
#   bilderSvn <bilderSvn args> <svn cmd> <svn args> <svn target>
# where the svn args must be of the --foo=bar form.
#
# Args:
# 1: the svn action (co, up, ...)
# 2-n: args to svn in the --foo=bar form followed by a target
#
# Named args
# -q  do not echo command
# -r  redirect output to stderr
# -2  If USE_2ND_SVNAUTH is true, don't bother trying first checkout
#
bilderSvn() {

# Get the args for bilderSvn
  local usesecondauth=false
  local redirecttoerr=false
  local echocmd=true
  while test -n "$1"; do
    case "$1" in
      -2) usesecondauth=true;;
      -q) echocmd=false;;
      -r) redirecttoerr=true;;
      *)  break;;
    esac
    shift
  done
  local svncmd=$1
  shift

# Get the args for svn
  local svnargs=
  while test -n "$1"; do
    case "$1" in
      -*) svnargs="$svnargs $1";;
      *) break;;
    esac
    shift
  done
  local origtarget=$1

# Save current directory to go back to if needed
  local origdir=`pwd -P`

# Determine directory in which to execute command and what target is needed.
  local svntarget=
  local execdir=
  local targetdir=
  if test -z "$origtarget"; then
    execdir=$origdir
  elif test -d "$origtarget"; then
    execdir=`(cd $origtarget; pwd -P)`
  else
    targetdir=`dirname $origtarget`
    svntarget=`basename $origtarget`
    if test -z "$targetdir" || test "$targetdir" = .; then
      execdir=$origdir
    else
      execdir=`(cd $targetdir; pwd -P)`
    fi
  fi
  if test -z "$svntarget" && test "$svncmd" = revert; then
    svntarget=.
  fi

# Change to target's directory, cleanup and execute command
  cd $execdir
  $echocmd && techo "In $PWD:" 1>&2
  cmd="svn cleanup"
  $echocmd && techo "$cmd" 1>&2
  $cmd 1>&2
  cmd="svn $svncmd $svnargs $svntarget"
  $echocmd && techo "$cmd" 1>&2
# Need to capture output of this command
  $cmd
  res=$?
  cd $origdir
  $echocmd && techo "Back in $PWD." 1>&2

  return $res

}

#
# Perform svn cleanup recursively, even on svn:externals, which svn
# doesn't do.
#
# Get the externals, then recursively call ourselves for each one.
#
#
bilderSvnCleanup() {
  for dir in `svn pg svn:externals . | awk '{ print $1 }'`; do
    cd $dir
    bilderSvnCleanup
# At this point, we have to go back up, but if our external dir is of
# the form a/b, then we'll have to do "cd .." twice. We can't use cd -,
# so we just count the number of components and do "cd .." for each one.

    components=`echo $dir | tr / ' '`
    for slash in $components; do
      cd ..
    done
  done
}


#
# svn version on a node.  This 
#
# Args:
# 1: the node
#
bilderSvnversion() {
  # techo "bilderSvnversion called with args, $*." 1>&2
  BLDR_SVNVERSION=${BLDR_SVNVERSION:-"svnversion"}
  local version=
  local numargs=$#
  local args=
  local svnver=`which "$BLDR_SVNVERSION"`
  while test -n "$1"; do
# Single quotes not working on cygwin, so removing
    if test $# -eq 1; then
      techo -2 "Working on last arg, $1." 1>&2
# If using the windows client, convert path if not an option
      if [[ "$1" =~ ^- ]]; then
        techo -2 "Last arg, $1, is an option.  Adding to list." 1>&2
        args="$args $1"
      elif [[ "$svnver" =~ "Program Files" ]]; then
        techo "Using windows: '$svnver'.  Will convert last arg, $1, using cygpath." 1>&2
        if node=`cygpath -aw "$1"`; then
          args="$args $node"
        else
        techo "WARNING: cygpath did not work on $1." 1>&2
          args="$args $1"
        fi
      else
        techo -2 "Not using windows: '$svnver'.  Will add last arg, $1, to list." 1>&2
        args="$args $1"
      fi
    else
      args="$args $1"
    fi
    shift
  done
# Quoting args did not work
  if ! version=`"$BLDR_SVNVERSION" $args`; then
    techo "Command svnversion failed.  BLDR_SVNVERSION = $BLDR_SVNVERSION." 1>&2
    version=unknown
  fi
  version=`echo $version | tr -d '\r' | tr : -`
  echo "$version"
}

#
# Get the maker depending on system and build system
#
# Args:
# 1: the build system
#
getMaker() {
  local maker
  case `uname` in
    CYGWIN*)
      case "$1" in
        qmake | cmake | none)
          if which jom 1>/dev/null 2>&1; then
            maker=jom
            # maker=nmake
          else
            maker=nmake
          fi
          ;;
        *)
          maker=make
          ;;
      esac
      ;;
    *)
      local maker=make
      ;;
  esac
  echo $maker
}

#
# Get the flag prefix corresponding to a compiler variable name
#
# Args:
# 1: the compiler variable name (CC, CXX, F77, FC)
#
getCompFlagsPrefix() {
  local flagsprfx
  case $1 in
    CC)
      flagsprfx=C
      ;;
    F77)
      flagsprfx=F
      ;;
    *)
      flagsprfx=$i
      ;;
  esac
  echo $flagsprfx
}

#
# Get the top build directory for a package of a version
#
# Args:
# 1: package name
# 2: version
#
getBuildTopdir() {
# Default build directory
  local buildtopdir
  if test -d $BUILD_DIR/$1-$verval; then
    buildtopdir=$BUILD_DIR/$1-$verval
  else
    mkdir -p $BUILD_DIR/$1
    buildtopdir=$BUILD_DIR/$1
  fi
  echo $buildtopdir
}

#
# convert seconds to hh:mm:ss
#
myTime() {
  local secs=$1
  local hours=`expr $secs / 3600`
  secs=`expr $secs - $hours \* 3600`
  local mins=`expr $secs / 60`
  local secs=`expr $secs - $mins \* 60`
# Always print hours, as otherwise interpretable as mm:ss.
  # if test $hours -gt 0; then
    printf "%02d:" $hours
  # fi
  printf "%02d:%02d\n" $mins $secs
}

#
# Set permissions of a directory (if absolute) or a subdirectory of $INSTALL
# (if relative) to group rw and other just r.
#
# Args:
# 1: The subdirectory to fix or directory if begins with /
#
setOpenPerms() {
  case `uname` in
    CYGWIN*)        # No need on cygwin
      return 0
      ;;
  esac
  local permdir
  if test -n "$1"; then
    case "$1" in
      /*)
        permdir=$1
        ;;
      *)
        permdir=$BLDR_INSTALL_DIR/$1
        ;;
    esac
  fi
  techo "Setting open permissions on $permdir."
  local updir=`dirname $permdir`
  local dirgroup=
  dirgroup=`ls -ld $updir | sed 's/  */ /g' | cut -f 4 -d ' '`
  local res=0
  local res1=
  for i in $permdir; do
    if test -d $i; then
      cmd="find $i -user $USER -exec chgrp $dirgroup '{}' \;"
      techo "$cmd"
      eval "$cmd"
# On linux, cannot chmod a link
      local mod=
      if [[ `uname` =~ Linux ]]; then
        mod='\( -type d -or -type f \)'
      fi
      cmd="find $i -user $USER $mod -exec chmod ug=rwX,o=rX '{}' \;"
      techo "$cmd"
      eval "$cmd"
      res1=$?
      if test $res1 != 0; then res=$res1; fi
      cmd="find $i -type d -user $USER -exec chmod g+s '{}' \;"
      techo "$cmd"
      eval "$cmd"
      res1=$?
      if test $res1 != 0; then res=$res1; fi
    else
      cmd="chmod ug=rwX,o=rX $i"
      techo "$cmd"
      $cmd
      res=$?
    fi
  done
  return $res
}

#
# Set permissions of a directory (if absolute) or a subdirectory of $INSTALL
# (if relative) to user rw, group r, other none
#
# Args:
# 1: The subdirectory to fix or directory if begins with /
#
setClosedPerms() {
  case `uname` in
    CYGWIN*)        # No need on cygwin
      return
      ;;
  esac
  local permdir
  if test -n "$1"; then
    case "$1" in
      /*)
        permdir=$1
        ;;
      *)
        permdir=$BLDR_INSTALL_DIR/$1
        ;;
    esac
  fi
  techo "Setting closed permissions on $permdir."
  local res=0
  local res1=
  for i in $permdir; do
    if test -d $i; then
      cmd="find $i -user $USER -exec chmod u=rwX,g=rX,o-rwx '{}' \;"
      techo "$cmd"
      eval "$cmd"
      res1=$?
      if test $res1 != 0; then res=$res1; fi
      cmd="find $i -type d -user $USER -exec chmod g+s '{}' \;"
      techo "$cmd"
      eval "$cmd"
      res1=$?
      if test $res1 != 0; then res=$res1; fi
    else
      cmd="chmod u=rwX,g=rX,o-rwx $i"
      echo $cmd
      $cmd
      res=$?
    fi
  done
  return $res
}

#
# Check writability of a directory
#
# Args:
# 1: Name of the directory
#
# Named args:
# -c check and report, but do not exit
#
checkDirWritable() {
  local exitonfailure=true
  while test -n "$1"; do
    case "$1" in
      -c)
        exitonfailure=false
        ;;
      *)
        break
        ;;
    esac
    shift
  done
  if test -z "$1"; then
    TERMINATE_ERROR_MSG="Catastrophic error in checkDirWritable.  Directory not specified."
    cleanup
  fi
  local dir=$1

# Create directory if not present.
  if test -d $dir; then
    techo "Directory, $dir, already exists."
  else
    techo "Creating directory, $dir."
    if mkdir -p $dir; then
      techo "Directory, $dir, created."
    else
      techo "NOTE: Cannot create directory, $dir, on `hostname`."
      if $exitonfailure; then
        techo "Quitting. (checkDirWritable)"
        emailerror "FAILURE: Cannot create directory, $dir."
        usage 1
      fi
    fi
  fi

# Set directory perms.  Must always do, as may have been created by
# mkall-default.sh wrapper, which creates dir with wrong perms.
# Errors (not owner) to /dev/null.
  cmd="chmod 2775 $dir"
  $cmd 2>/dev/null
  local subdirs="bin include share"
  if [[ `uname` =~ CYGWIN ]]; then
    subdirs="bin include share Lib"
  else
    subdirs="bin include share lib"
  fi
  for j in bin include lib share; do
    if ! test -d $dir/$j; then
      mkdir -p $dir/$j
      chmod 2775 $dir/$j
    fi
  done
# Determine writability
  if ! touch $dir/tmp$$; then
    techo "NOTE: Cannot write to $dir.  USER = $USER with groups = `groups`."
    if $exitonfailure; then
      techo "Quitting."
      emailerror "Cannot write to $dir."
      usage 1
      exit
    fi
  fi
  rm $dir/tmp$$
}

#
# Take and name and return a valid bash variable
#
# Args:
# 1: The name used to generate the variable name
#
genbashvar() {
  local bashvar=`echo $1 | tr 'a-z./-' 'A-Z___'`
  echo $bashvar
}

#
# Remove values from a variable containing comma delimited values
#
# Args:
# 1: the variable
# 2: comma separated list of values to remove
#
rmVals() {
  if test -z "$2"; then
    return
  fi
  local var=$1
  local vals=`deref $var`
  for v in `echo $2 | tr ',' ' '`; do
    vals=`echo ,${vals}, | sed -e "s/,${v},/,/"`
  done
  trimvar vals ','
  eval ${var}=$vals
}

#
# Compute the builds from a package by taking the add builds
# minus the no-builds
#
# Args:
# 1: the package
#
computeBuilds() {
  buildsvar=`genbashvar $1`_BUILDS
  buildsval=`deref $buildsvar`
  if test -z "$buildsval"; then
    addbuildsvar=`genbashvar $1`_ADDBUILDS
    addbuildsval=`deref $addbuildsvar`
    nobuildsvar=`genbashvar $1`_NOBUILDS
    nobuildsval=`deref $nobuildsvar`
    addVals $buildsvar $addbuildsval
    rmVals $buildsvar $nobuildsval
  fi
}

#
# Add values to a variable containing comma delimited values
#
# Args:
# 1: the variable
# 2: comma separated list of values to add
#
addVals() {
  if test -z "$2"; then
    return
  fi
  local var=$1
  local vals=`deref $var`
  for v in `echo $2 | tr ',' ' '`; do
    if ! echo ${vals} | egrep -q "(^|,)$v($|,)" ; then
      vals=${vals},$v
    fi
  done
  trimvar vals ','
  eval ${var}=$vals
}

#
# Add a directory to a path-like variable if not already there.
# Convert to cygwin if not path
#
# Args:
# 1: The variable name
# 2: The directory to add
# 3: If "after" add after, otherwise before
#
addtopathvar() {
  # techo "addtopathvar entered."
# Determine the separator
  local sep=":"
  local addpathcand=$2
# Find absolute, resolved path, if it exists
  case `uname`-$1 in
    *-PATH)  # cygwin converts PATH and uses colon
      addpath=`(cd $addpathcand 2>/dev/null; pwd -P)`
      ;;
    CYGWIN*)
      sep=";"
      addpath=`cygpath -aw $addpathcand`
      ;;
  esac
# Fallback to given
  addpath=${addpathcand:-"$addpath"}
# Add to path variable if not already present
  local pathval=`deref $1`
  if ! echo $pathval | egrep -q "(^|$sep)$addpath($|$sep)" ; then
    bildersaveval=`deref BILDER_ADDED_${1}`
    if test "$3" = "after"; then
      eval $1="'${pathval}${sep}${addpath}'"
      eval BILDER_ADDED_${1}="'${bildersaveval}${sep}${addpath}'"
    else
      eval $1="'${addpath}${sep}${pathval}'"
      eval BILDER_ADDED_${1}="'${addpath}${sep}${bildersaveval}'"
    fi
  fi
  local bpvar=BILDER_$1
  local bpval=`deref $bpvar`
  if ! echo $bpval | egrep -q "(^|$sep)$addpath($|$sep)" ; then
    eval $bpvar="'${bpval}${sep}${addpath}'"
  fi
  if test $VERBOSITY -ge 2; then
    pathval=`deref $1`
    bpval=`deref $bpvar`
    techo "Variable $bpvar = $bpval, $1 = $pathval (addtopathvar)"
  fi
  # techo "addtopathvar returning."
}

#
# Install the configuration files
#
# Args:
# 1: The installation directory for previous mods, to capture them
#
createConfigFiles() {

  techo
  techo "  Bilder Creating configuration files"
  techo "======================================"

# Installation directory
  local instdir=$BLDR_INSTALL_DIR
  if test -n "$1"; then
    instdir=$1
  fi

# Determine whether module system exists
  local havemodules=
  if module list 1>/dev/null 2>&1; then
    havemodules=true
  else
    havemodules=false
  fi
# Determine whether the python module was loaded
  local pymodule=
  local havepymodule=false
  if $havemodules; then
# JRC to whomever wrote this code
    pymodule=`module list 2>&1 | grep ' python/' | sed 's/^.*) //'`
    if test -n "$pymodule"; then
      havepymodule=true
    fi
  fi

# Create setup scripts
  cd $PROJECT_DIR
  rm -f $BUILD_DIR/${BILDER_PACKAGE}.sh
  case `uname` in
    CYGWIN*) sep=';';;
    *) sep=':';;
  esac
# Path always uses colon
  trimvar BILDER_PATH ':'
  cat <<EOF >$BUILD_DIR/${BILDER_PACKAGE}.sh
#!/bin/bash
EOF
  if test -n "$BILDER_PATH"; then
    cat <<EOF >>$BUILD_DIR/${BILDER_PACKAGE}.sh
export PATH="${BILDER_PATH}:\$PATH"
EOF
  fi
# Other paths use semicolon
  for i in $BILDER_ADDL_PATHS; do
    local bpvar=BILDER_$i
    local bpval=`deref $bpvar`
    trimvar bpval "${sep}"
    if test -n "$bpval"; then
      cat <<EOF >>$BUILD_DIR/${BILDER_PACKAGE}.sh
export $i="${bpval}${sep}\$$i"
EOF
    fi
  done

  if $havepymodule; then
    cat <<EOF >>$BUILD_DIR/${BILDER_PACKAGE}.sh
# Load python modules
module unload python 2>/dev/null
module load $pymodule

EOF
  fi

# Allow local modifications to be saved
  if test -e $instdir/${BILDER_PACKAGE}.sh; then
    sed -n  '/^#SAVE/,$p' <$instdir/${BILDER_PACKAGE}.sh >>$BUILD_DIR/${BILDER_PACKAGE}.sh
  fi

  rm -f $BUILD_DIR/${BILDER_PACKAGE}.csh
  cat <<EOF >$BUILD_DIR/${BILDER_PACKAGE}.csh
#!/bin/csh
EOF
  if test -n "$BILDER_PATH"; then
    local cshpaths=`echo $BILDER_PATH | tr ':' ' '`
    cat <<EOF >>$BUILD_DIR/${BILDER_PACKAGE}.csh
set path = ( $cshpaths \$path )
EOF
  fi
  for i in $BILDER_ADDL_PATHS; do
    local bpvar=BILDER_$i
    local bpval=`deref $bpvar`
    trimvar bpval "${sep}"
    if test -n "$bpval"; then
      cat <<EOF >>$BUILD_DIR/${BILDER_PACKAGE}.csh
if (\${?$i}) then
  setenv $i "${bpval}${sep}\${$i}"
else
  setenv $i "${bpval}"
endif
EOF
    fi
  done

  if $domodules; then
    cat <<EOF >>$BUILD_DIR/${BILDER_PACKAGE}.csh
# Load python modules
module unload python 2>/dev/null
module load $mdlcmd

EOF
  fi

# Allow local modifications to be saved
  if test -e $instdir/${BILDER_PACKAGE}.csh; then
    sed -n  '/^#SAVE/,$p' < $instdir/${BILDER_PACKAGE}.csh >> $BUILD_DIR/${BILDER_PACKAGE}.csh
  fi

}

#
# Install the configuration files
#
# Args:
# 1: The installation directory for previous mods, to capture them
#
installConfigFiles() {

# Installation directory
  local instdir=$CONTRIB_DIR
  if test -n "$1"; then
    instdir=$1
  fi

# Install the setup scripts
  cmd="/usr/bin/install -m 775 $BUILD_DIR/${BILDER_PACKAGE}.csh $BUILD_DIR/${BILDER_PACKAGE}.sh $instdir"
  techo "$cmd"
  $cmd

}

#
# Print out how environment must be changed.
# Do not send to log to allow being sent to summary
#
# Args:
# 1: The installation directory for previous mods.  If empty,
#    $CONTRIB_DIR is used.
#
printEnvMods() {

# Installation directory
  local instdir=$BLDR_INSTALL_DIR
  if test -n "$1"; then
    instdir=$1
  fi

  trimvar BILDER_PATH ':'
  echo "ENSURE that $BILDER_PATH is part of your PATH!"
  for i in $BILDER_ADDL_PATHS; do
    local bpvar=BILDER_ADDED_$i
    local bpval=`deref $bpvar`
    case `uname` in
      CYGWIN*) trimvar bpval ';';;
      *) trimvar bpval ':';;
    esac
    if test -n "$bpval"; then
      if test `uname` = Linux -o $i != LD_LIBRARY_PATH; then
        echo "ENSURE that $bpval is part of your $i!"
      fi
    fi
  done
  echo ""

# Notify
  echo "Bourne shell users can"
  echo '  '"source $instdir/${BILDER_PACKAGE}.sh"
  echo "to pick up needed settings"
  echo "C shell users can"
  echo '  '"source $instdir/${BILDER_PACKAGE}.csh"
  echo "to pick up these settings"
  echo ""
  echo "These source commands can be placed at the end of the appropriate"
  echo "configuration files as well."

}

#
# Finish a build: summarizing, emailing, etc.
#
# Args:
# 1: The installation directory for files to be sourced.
# 2: The exit code
#
# Named args
# -c continue (don't quit)
# -s the subject for the email
#
finish() {

  techo -2 "finish called with '$*'."
  local doQuit=true
  local subject=
  while test -n "$1"; do
    case "$1" in
      -c) doQuit=false;;
      -s) subject="$2"; shift;;
       *) break;;
    esac
    shift
  done

# Summarize (which constructs the email subject)
  techo -2 "Calling summarize."
  summarize $1 $2
  techo -2 "After summarize, EMAIL_SUBJECT = '$EMAIL_SUBJECT'."

# Put summary at top of logfile
  cp $LOGFILE $LOGFILE.sav
  cat $SUMMARY | tee $LOGFILE
  cat $LOGFILE.sav >> $LOGFILE
  techo
  techo "$BILDER_NAME completed at `date`." | tee -a $BILDER_LOGDIR/timers.txt

# email
  subject=${subject:-"$EMAIL_SUBJECT"}
  cmd="emailSummary -s '$subject'"
  eval "$cmd"
  if $IS_SECOND_INSTALL; then
    echo "$subject" >$PROJECT_DIR/secondrunsubj.txt
  else
    echo "$subject" >$PROJECT_DIR/firstrunsubj.txt
  fi

# Do any final action the user has declared
  if $DO_FINAL_ACTION && declare -f bilderFinalAction 1>/dev/null 2>&1; then
    bilderFinalAction $FINAL_ACTION_ARGS
  fi

# Quit
  if $doQuit; then
    techo "${BILDER_NAME} quitting."
    date >$BILDER_LOGDIR/$BILDER_NAME.end
    if test -n "$2"; then
      exitcode=$2
    elif test -n "$anyFailures"; then
      local msg=
      if $IGNORE_TEST_RESULTS && test -z "${configFailures}${buildFailures}${installFailures}"; then
        msg="SUCCESS: configFailures = $configFailures, buildFailures = $buildFailures, installFailures = $installFailures, testFailures = $testFailures."
        exitcode=0
      else
        msg="FAILURE: configFailures = $configFailures, buildFailures = $buildFailures, installFailures = $installFailures, testFailures = $testFailures."
        exitcode=1
      fi
    else
      msg="SUCCESS: anyFailures is empty."
      exitcode=0
    fi
    techo "$msg"
    techo "finish is exiting."
    cmd="exit $exitcode"
    techo "$cmd"
    echo $exitcode >$BUILD_DIR/bilder.res
    $cmd
  else
# Rotate log and summary and restore original logfile if continuing
    rotateFile $SUMMARY
    rotateFile $LOGFILE
    mv $LOGFILE.sav $LOGFILE
  fi
}

#
# Find the type of repository of the current directory
#
# Args: none
#
getRepoType() {
# What kind of repo is this?
  local repotyp=""
  if test -d ".svn"; then
    repotype="SVN"
  elif test -d ".git"; then
    repotype="GIT"
  elif test -d ".hg"; then
    repotype="HG"
  fi
  echo $repotype
}

#
# Put the version in the package variable for version
#
# Args:
# 1: repo
# 2: project subdir that provides further provenance
#
# Named args (must come first):
# -l: Get the last version instead of the last changed version
#
getVersion() {

# Get options
  local lastChangedArg=-c
  while test -n "$1"; do
    case "$1" in
      -l)
        lastChangedArg=
        ;;
      *)
        break
        ;;
    esac
    shift
  done

# Get subdir
  local origdir=`pwd -P`
  subdir=${2:-"."}

# Check the directory
  local repodir=$1
  local repobase=`basename $1`
  if test -d $repodir; then
    repodir=`(cd $repodir; pwd -P)`
  else
    if test $repobase = $1; then
      repodir=$PROJECT_DIR/$1
    fi
  fi
  local vervar=`genbashvar $repobase`_BLDRVERSION
  cd $repodir 2>/dev/null
  res=$?
  if test $res != 0; then
    eval ${vervar}=unknown
    techo "Directory $repodir does not exist.  Version is unknown.  Cannot configure."
    return 1
  fi

  local repotype=`getRepoType`

# Get the revision
  if test "$repotype" == "SVN"; then
    techo "Getting version of $repodir  at `date`."
    rev=`bilderSvnversion $lastChangedArg`

# svnversion -c is likely to return a complex version such as 1535:2091 and
# we want to strip off the first part and colon if so. However, we take a look
# at svnversion to be sure the version is not mixed. If it is mixed, we use
# that instead, so we know we are working with a mixed version.

    if test -n "$lastChangedArg"; then
      local svntmp=`bilderSvnversion`
      case $svntmp in
        *[A-Z-]*) rev=$svntmp;;
               *) rev=`echo $rev | sed 's/.*-//'`;;
      esac
    fi

    if test $subdir != "."; then
      techo "Getting version of subdir, $subdir, at `date`."
      local svntmp=`bilderSvnversion $subdir`
      rev="${rev}+${svntmp}"
    fi
  elif test "$repotype" == "GIT"; then
    techo "Getting the current git branch of $1 at `date`."
# NB: For git, we are using the number of repository revisions as the version
#     number. Depending on where you get your repository and how you have
#     applied patches, I believe that your repo could get a different number
#     for the same code tree or the same number for a different code tree. (SG)
    if ! rev=`git rev-list HEAD | wc -l | awk '{print $1}'`; then
      techo "Git branch failed.  In path?  Returning."
      cd $origdir
      return 1
    fi
  elif test "$repotype" == "HG"; then
    techo "Getting the current hg id (hash) of $1 at `date`."
    if ! rev=`hg id -i`; then
      techo "Hg failed.  In path?  Returning."
      cd $origdir
      return 1
    fi
  elif test -z "$repotype"; then
    techo "Directory $repodir is not a repository, assuming exported"
    rev="exported"
  else
    techo "Directory $repodir is an unknown repository type, $repotype, assuming exported"
    rev="exported"
  fi

# Prepend r.
  rev="r"${rev}
# Finally, store the revision in <project>_BLDRVERSION
  eval ${vervar}=$rev
  # techo "${vervar} = $rev."
  case $rev in
    *:* | *M) techo "WARNING: $repodir is not clean.  ${vervar} = $rev.";;
  esac
  # techo exit; exit

}

# Replace compilers with optimization-reducing compilers.
#
# Args
# 1: the build directory
# 2: The compiler to replace
# 3: The optimization reducing, replacing compiler
#
replaceCMakeComps() {
  builddir=$1
  oldcomp=$2
  newcomp=$3
  cat <<EOF >$builddir/replacecomps.sh
#!/bin/bash
echo "Replacing compilers and linkers with reducing optimization compiler."
find $builddir -name link.txt -exec sed -i.bak -e "s?^[[:graph:]]*$oldcomp ?$builddir/txutils/$newcomp ?" '{}' \;
find $builddir -name build.make -exec sed -i.bak -e "s? [[:graph:]]*$oldcomp ? $builddir/txutils/$newcomp ?" '{}' \;
EOF
  chmod a+x $builddir/replacecomps.sh
  cmd="$builddir/replacecomps.sh"
  techo "$cmd"
  $cmd | tee -a $LOGFILE
}

#
# Determine whether patch is out of date
# This depends on knowing the installation subdir,
# which is not known at bilderUnpack if not default.
# Further, this does not work for python packages.
#
# Args:
# 1: Full name of installation = <project>-<version>-<build>
#
# Named args (must come first):
# -i the installation directory
# -s the installation subdirectory
#
isPatched() {

# Determine installation directory
  local instdir="$BLDR_INSTALL_DIR"
  local checkempty=false
  local instsubdir=
  while test -n "$1"; do
    case "$1" in
      -i)
        instdir="$2"
        shift
        ;;
      -s)
        instsubdir="$2"
        shift
        ;;
      *)
        break
        ;;
    esac
    shift
  done
  local installation=$1

# Determine subdir (actually link) from installation
  if test -z "$instsubdir"; then
    instsubdir=$installation
  fi

# Deduce patch from variable, then default for rev, then HEAD if snv
  local projver=`echo $installation | sed 's/-[^-]*$//'`
  local proj=`echo $projver | sed 's/-.*$//'`
  local patchvar=`genbashvar $proj`_PATCH
  local patchval=`deref $patchvar`
# If not predefined, set to SVN
  if test -n "$patchval"; then
    techo "Predefined $patchvar = $patchval."
  else
    patchval=$BILDER_DIR/patches/${projver}.patch
  fi
  techo "Looking for $patchval."
  pkgsandpatches="$pkgsandpatches `basename $patchval`"
  if ! test -f $patchval; then
    techo "Patch $patchval not found."
    patchval=
# If version is svn, try head
    if [[ $projver =~ ${proj}-r ]]; then
      patchval=$BILDER_DIR/patches/${proj}-rHEAD.patch
      techo "Looking for $patchval."
      pkgsandpatches="$pkgsandpatches `basename $patchval`"
      if ! test -f $patchval; then
        techo "Patch $patchval not found."
        patchval=
      fi
    fi
  fi
  eval $patchvar=$patchval

# If a patch found, look for it in the repo
  if test -n "$patchval"; then
    techo "Patch value found, $patchvar = $patchval."
    local patchname=`basename $patchval`
    local dopatch=false
    techo "Looking for $instdir/$instsubdir/$patchname."
    if test -d $instdir/$instsubdir; then
# This implies default installation subdir
      if ! test -f $instdir/$instsubdir/$patchname; then
        techo "Patch $instdir/$instsubdir/$patchname is missing.  Rebuilding."
        dopatch=true
      elif ! $BILDER_DIFF -q $instdir/$instsubdir/$patchname $patchval; then
        techo "Patch $instdir/$instsubdir/$patchname and $patchval differ.  Rebuilding."
        dopatch=true
      else
        techo "Patch up to date."
      fi
    else
      techo "Patch $instdir/$instsubdir not present.  Patch cannot be checked."
    fi
    if $dopatch; then
      cd $origdir
      return 1
    fi
  fi
  cd $origdir
  return 0

}

#
# Determine whether one build is installed.
#
# Args:
# 1: Full name of installation = <project>-<version>-<build>
#
# Named args (must come first):
# -e checks for empty directory and reinstalls if that is the case
# -i the installation directory
#  #  -s the installation subdirectory
#
isInstalled() {

# Determine installation directory
  local checkempty=false
  # local instsubdir=
if false; then
  local instdir="$BLDR_INSTALL_DIR"
  while test -n "$1"; do
    case "$1" in
      -e)
        checkempty=true
        ;;
      -i)
        instdir="$2"
        shift
        ;;
      # -s)
        # instsubdir="$2"
        # shift
        # ;;
      *)
        break
        ;;
    esac
    shift
  done
else
  local instdirs=
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "i:I:" arg; do
    case $arg in
      i) instdirs="$OPTARG";;
      I) instdirs="$OPTARG";;
    esac
  done
  shift $(($OPTIND - 1))
# Eventually look in several installation dirs, but for now just one.
  instdir=`echo $instdirs | sed 's/,.*$//'`
fi
  # instsubdir=${instsubdir:-"$1"} # may not be, so must check for existence
  installation=$1

# Look for installations
  techo "Looking for $installation in $instdir/installations.txt."
  if test -f $instdir/installations.txt; then
    local hasit=`grep -- ^${installation}" " $instdir/installations.txt | tail -1`
    techo -2 "Found '$hasit'. checkempty = $checkempty."
    if test -n "$hasit"; then

# Look for patch up to date
      local args="-i $instdir"
      if ! isPatched $args $installation; then
        return 1
      fi

# look for empty dir
      if $checkempty; then
# This screws up python installations as they go in the lib subdir.
# Doing on demand only now.
        if [ "$(ls -A $instdir/$1)" ]; then
# installation directory exists and is not empty
          return 0
        else
# Someone has removed the install since installations.txt was written
          techo "Project directory $instdir/$1 is empty. Will need to reinstall as $instdir modified since $hasit build."
          return 1
        fi
      fi
    else
      return 1
    fi
  else
    return 1
  fi

}

#
# Creates the configure script for reconfiguring
# This needs to be generalized to include distutils.
#
# Args are used to
# 1: hostname (e.g., franklin.nersc.gov)
# 2: the package name (e.g., facets)
# 3: the build (e.g., ser)
#
mkConfigScript() {
  local configscript=$1-$2
  if test -n "$3"; then
    configscript=$configscript-$3
  fi
  configscript=$configscript-config
  local sedfile=$configscript.sed
  configscript=$configscript.sh
  local vervar=`genbashvar $2`_BLDRVERSION
  local verval=`deref $vervar`
# Generate sed file
  sed -e "s/@PACKAGE@/$2/" -e "s/@VERSION@/$verval/" <$BILDER_DIR/addnewlines.sed >$sedfile
  # echo "End is $2-$verval"
  echo "#!/bin/bash" > $configscript
  local configure_txt=$1-$2-$3-config.txt
# Make sure all scripts have the exact same length for sed below
  echo >> $configscript
  if egrep -q "(^|/)cmake('| ) " $configure_txt; then
    echo "# Clear cmake cache to ensure a clean configure." >> $configscript
    echo "rm -rf CMakeFiles CMakeCache.txt" >> $configscript
    echo >> $configscript
  fi
# Prettify the configure script.  Darwin does not allow \n in substitutions,
# so use mkConfigScript.sed, modified with package and version.
# For lines containing a blank after an =, put quote after equals and at end.
# Reduce successive quotes.
# Remove (spuriously added) double quotes internal to single quotes
# Indent all but first line, add backslash to all line, then remove from last
# Make sure that last line is the configure line when this is called.
  tail -1 $configure_txt | sed -f $sedfile |\
    sed -e '/= /s/=/="/' -e '/= /s/$/"/' |\
    sed -e "s/\"'/'/g" -e "s/'\"/'/g" -e 's/""/"/g' -e 's/""/"/g' |\
    sed -e "s/'\(.*\)\"\(.*\)'/'\1\2'/" |\
    sed -e '2,$s/^/  /' -e '1,$s/$/ \\/' -e '$s/ \\$//' >>$configscript
  chmod u+rx $configscript
# Also touch the build script file, so that CMake can find it
  local buildscript=`echo $configscript | sed -e 's/-config\./-build./'`
  touch $buildscript
}

# Install the config shell scripts if they exist.  This is useful
# for keeping a record of what configure scripts worked
# Eventually we could put these onto the web (semi)automatically
#
# Args are used to
# 1: hostname (e.g., franklin.nersc.gov)
# 2: the package name (e.g., facets)
# 3: the build (e.g., ser)
#
instConfigScript() {
  local configscript=$1-$2-$3-config.sh
  if test -e $configscript; then
    cmd="install -m 755 $configscript $4/share/configFiles"
    techo "$cmd"
    $cmd
  else
    techo "Configuration script, $configscript, not found."
  fi
}


#
# Determine whether a set of builds is installed.
#
# Args:
# 1: packagename-version
# 2: comma separated list of build names
#
# return whether all packages are installed
#
areAllInstalled() {
# Determine installation directory
  local instdir=$BLDR_INSTALL_DIR
  while test -n "$1"; do
    case "$1" in
      -i)
        instdir=$2
        shift
        shift
        ;;
      *)
        break
        ;;
    esac
  done
# If no builds, just check short name
  if test -z "$2"; then
    if isInstalled -i $instdir $1; then
      return 0
    else
      return 1
    fi
  fi
# Look for all requested installations, if all present, return.
  for i in `echo $2 | tr ',' ' '`; do
    if isInstalled -i $instdir $1-$i; then
      techo "Package $1-$i is installed."
    else
      techo "Package $1-$i is not installed."
      return 1
    fi
  done
  return 0  # 0 is true
}

#
# Determine whether one should install a package of a given version
#
# Args:
# 1: packagename-version
# 2: comma separated list of builds
# 3: comma separated list of dependencies
#
# Named args:
# -I comma separated list of directories: The first is the
#    primary installation directory, e.g., BLDR_INSTALL_DIR.
#    Subsequent directories are alternate places (besides
#    CONTRIB_DIR that builds and or dependencies might be found.
#
shouldInstall() {
  techo -2 "shouldInstall called with $*"

# Determine installation directory
  local instdirs=
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "i:I:" arg; do
    case $arg in
      i) instdirs="$OPTARG";;
      I) instdirs="$OPTARG";;
    esac
  done
  shift $(($OPTIND - 1))

# The first instollation dir is where the package will be installed
  local instdir=`echo $instdirs | sed 's/,.*$//'`
# Dependencies are sought in all possible installdirs named above
# plus the contrib dir.
  if ! echo $instdirs | egrep -q "(^|,)$CONTRIB_DIR(,|$)"; then
    instdirs=$instdirs,$CONTRIB_DIR
  fi
  trimvar instdirs ,

# Bassi has a hard time with empty strings as args.
  if test "$2" = '-' -o "$2" = NONE; then
    unset builds
    return 1      # false
  else
    builds=$2
  fi

# Needed below
  local proj=`echo $1 | sed 's/-.*$//'`
  local lcproj=`echo $proj | tr A-Z a-z`

# Moved to bilderPreconfig in case of forced build
  local currPkgScriptRevVar=`genbashvar ${proj}`_PKGSCRIPT_VERSION
  local currentPkgScriptRev=`deref ${currPkgScriptRevVar}`
  if test -z "$currentPkgScriptRev"; then
    if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/${lcproj}.sh; then
      currentPkgScriptRev=`svn info $BILDER_CONFDIR/packages/${lcproj}.sh |\
        grep 'Last Changed Rev:' | sed 's/.* //'`
    elif test -f $BILDER_DIR/packages/${lcproj}.sh; then
      currentPkgScriptRev=`svn info $BILDER_DIR/packages/${lcproj}.sh |\
        grep 'Last Changed Rev:' | sed 's/.* //'`
    else
      currentPkgScriptRev=unknown
    fi
    eval $currPkgScriptRevVar=$currentPkgScriptRev
  fi

# Do we want to check for installations in multiple dirs?
  local dir=$instdir
# if installations.txt does not exist, then we should install (anything).
  if test ! -f $dir/installations.txt; then
    techo "File $dir/installations.txt does not exist.  Proceeding with next step."
    return 0
  fi

# If not present in installations.txt, then rebuild
  local pkgline=`grep ^${proj}- $dir/installations.txt | tail -1`
  techo -2 "pkgline = $pkgline."
  if test -z "$pkgline"; then
    techo "Package $proj not found in $dir/installations.txt.  Proceeding with next step."
    return 0
  fi

  local pkgdate=`echo $pkgline | awk '{ print $4 }'`

# Find the rev of the package script that we used when the package was built.
# If it doesn't exist, we set it to 0 which will ensure that the package will
# be rebuilt.
  local pkgScriptRev=`echo $pkgline | awk '{ print $5 }' | sed 's/bilder-r//'`
  local pkgScriptRevStr=${pkgScriptRev:-"UNKNOWN"}
  if test -z "$pkgScriptRev" -o "$pkgScriptRev" = unknown; then
    pkgScriptRev=0
  fi
  techo "Package $proj last installed at $pkgdate (${lcproj}.sh script at r$pkgScriptRevStr) into $dir."

# Find earliest date of any of the builds in any of the directories.
# NOT IMPLEMENTED YET.
  if test -n "$builds"; then
    techo "Package $proj has builds, $builds."
  fi

# See whether installation is older than package file.
# For packages like Python, $proj will be Python, but the package script will
# be python.sh, so we use $lcproj.
  if test $currentPkgScriptRev -gt $pkgScriptRev; then
    techo -n "Script ${lcproj}.sh was r$pkgScriptRevStr when built, now r$currentPkgScriptRev"
    if $BUILD_IF_NEWER_PKGFILE; then
      techo "... rebuilding."
      return 0
    else
      techo "... not rebuilding because BUILD_IF_NEWER_PKGFILE = $BUILD_IF_NEWER_PKGFILE."
    fi
  else
    techo "Script $BILDER_DIR/packages/${proj}.sh is r$pkgScriptRevStr"
  fi

  techo "Bilder using `which sort` to do sorting."

# See whether the installation is older than project config file
# $BILDER_CONFDIR/packages/${proj}.conf file if it exists
  local projconf=$BILDER_CONFDIR/packages/${proj}.conf
  if [ -e "$projconf" ]; then
    echo "Config file present $projconf"
    local conffiledate=`ls -l --time-style=+%F-%T $projconf`
    conffiledate=`echo $conffiledate | awk '{print $6}'`
    local latedate=`(echo $pkgdate; echo $conffiledate) | sort -r | head -1`
    latedate=`echo $latedate | sed 's/ .*$//'`
    if test "$latedate" != $pkgdate; then
      techo "Configuration $projconf changed more recently than $proj.  Rebuilding."
      return 0
    fi
  fi

# Find date of build of last dependency
  local lastdepdate=
  local lastdep=
  if test -n "$3"; then
    techo "Package $1 depends on $3."
    for dep in `echo $3 | tr ',' ' '`; do
# Search for depline in install and contrib dirs
      local depdate=
      for dir in `echo $instdirs | tr ',' ' '`; do
        local depline=`grep ^${dep}- $dir/installations.txt | tail -1`
        if test -n "$depline"; then
          techo -2 "$dep installation found in $dir/installations.txt."
          depdate=`(echo $depline | awk '{ print $4 }'; echo $depdate) | sort -r | head -1`
        else
          techo -2 "$dep installation not found in $dir/installations.txt."
        fi
      done
      if test -z "$depdate"; then
        techo "No build of $dep found.  Assume built elsewhere or not needed."
      else
        if test -z "$lastdepdate"; then
          lastdepdate="$depdate"
          lastdep=$dep
        else
          lastdepdate=`(echo $lastdepdate; echo $depdate) | sort -r | head -1`
          if test "$lastdepdate" = "$depdate"; then
            lastdep=$dep
          fi
        fi
      fi
    done
    if test -n "$lastdep"; then
      techo "Most recently installed dependency, $lastdep, installed $lastdepdate."
# If any dependency built later than package, rebuild package
      local latedate=`(echo $pkgdate; echo $lastdepdate) | sort -r | head -1`
      latedate=`echo $latedate | sed 's/ .*$//'`
      if test "$latedate" != "$pkgdate"; then
        techo "Dependency $lastdep installed more recently than $proj.  Rebuilding."
        return 0
      else
        techo "Package $proj of some version installed more recently than all dependencies."
      fi
    else
      techo "None of the dependencies found in Bilder installation locations."
    fi
  else
    techo "Package $1 has no dependencies."
  fi

# If all builds younger than $BILDER_WAIT_DAYS, do not rebuild
  if ! isBuildTime $proj $builds $instdir; then
    return 1
  fi

# Now look for builds of this particular version
  techo "Checking for installation of '$builds' builds of $1."
  if areAllInstalled -i $instdirs $1 $builds; then
    if test -n "$builds"; then
      techo "$builds builds of $1 installed."
    else
      techo "Package $1 is installed."
    fi
    return 1      # false
  fi
  if test -n "$builds"; then
    techo "One or more of $builds build(s) of $1 not installed."
  else
    techo "Package $1 is not installed."
  fi
  return 0  # true

}

#
# Warn for absence of needed libraries
#
warnMissingPkgs() {

# Start with png and freetype
  local dirs="/usr/include $CONTRIB_DIR/include"
  for i in ft2build.h png.h; do
    local havepkg=false
    for j in $dirs; do
      if test -f $j/$i; then
        havepkg=true
        break
      fi
    done
    if ! $havepkg; then
      local pkg
      case $i in
        ft2build.h)
          pkg=freetype-devel
          ;;
        *)
          pkg=`basename $i .h`-devel
          ;;
      esac
      techo "WARNING: $i not found.  May need to install $pkg."
    fi
  done

# Look for missing libraries
  local missingpkgs
  local cands="Xt Xext Xrender Xtst GL SM freetype png"
  for k in $cands; do
    local lib=lib$k
    local found=false
    local syslibdirs=
    for j in $SYS_LIBSUBDIRS; do
      syslibdirs="$syslibdirs /usr/$j"
    done
    for j in $syslibdirs $CONTRIB_DIR/lib /opt/local/lib /usr/local/lib; do
      if test -L $j/$lib.so -o -f $j/$lib.so; then
        found=true
        break
      fi
    done
    if ! $found; then
      techo "WARNING: $lib.so not found."
      missingpkgs="$missingpkgs ${lib}-devel"
    fi
  done
  trimvar missingpkgs ' '
  if test -n "$missingpkgs"; then
    techo "WARNING: May need to install $missingpkgs."
  fi

}

#
# (Possibly build Python in contrib) and point to it.
#
# Args:
#  1 (boolean) true = build Python, false = don't build
#
setupContribPython() {
  local doit=${1:-"false"}
# Use buildChain to get all dependencies
  if $doit; then
    buildChain python
    cd $PROJECT_DIR        # Do not pick up python in python build dir
    source $BILDER_DIR/bilderpy.sh
# Need to clear out PID and RES variables for this chain so
# bilderInstall will not think these have been built and then reinstall.
  fi
}

#
# Remove any record of installation for a project
#
# Args:
# 1: the project
#
removeInstallFiles() {
 rm -f $BUILD_DIR/$1-{config,built,instald}
}

#
# Remove any record of installation
#
# Args:
# 1: the project
#
removeInstallRecord() {
  local instdirvar=`genbashvar ${1}`_INSTALL_DIR
  techo -2 instdirvar = $instdirvar
  local instdirval=`deref $instdirvar`
  if test -z "$instdirval"; then
    instdirval=$BLDR_INSTALL_DIR
  fi
  if test -f $instdirval/installations.txt; then
    grep -v ^$1 $instdirval/installations.txt >/tmp/removedir$$
    cp /tmp/removedir$$ $instdirval/installations.txt
    rm /tmp/removedir$$
  fi
}

#
# Returns whether CC contains the equivalent of gcc
#
isCcGcc() {
  # techo -2 "CC = $CC, PYC_CC = $PYC_CC."
  case $CC in
    */gcc* | gcc*)
     return 0
     ;;
  esac
  return 1
}

#
# Add in cc4py build.  Done to packages that will be used by python.
#
# Args:
# 1: the package to add it to
#
# Named args (must come first):
# -f forces addition of cc4py build, as needed for Darwin
#
# return whether added cc4py to the build
#
addCc4pyBuild() {
  local forceadd=false
  while test -n "$1"; do
    case "$1" in
      -f)
        local forceadd=true
        shift
        ;;
      *)
        break
        ;;
    esac
  done
  local buildsvar=`genbashvar $1`_BUILDS
  local buildsval=`deref $buildsvar`
  if test "$buildsval" != NONE; then
    if $forceadd || ! isCcGcc; then
      if ! echo "$buildsval" | egrep -q "(^|,)cc4py($|,)"; then
        buildsval=$buildsval,cc4py
        trimvar buildsval ,
        eval $buildsvar=$buildsval
        buildsval=`deref $buildsvar`
        return 0
      fi
    fi
  fi
  return 1
}

#
# Add in ben build if not present and no par build.
#
# Args:
# 1: the package
#
# echoes the new builds
#
addBenBuild() {
  local buildsvar=`genbashvar $1`_BUILDS
  local buildsval=`deref $buildsvar`
  if test "$CONFIG_COMPILERS_SER" != "$CONFIG_COMPILERS_BEN"; then
    if test -n "$buildsval" -a "$buildsval" != NONE; then
      if ! echo $buildsval | egrep -q "(^|,)ben($|,)"; then
        if ! echo $buildsval | egrep -q "(^|,)par($|,)"; then
          buildsval=$buildsval,ben
        fi
      fi
    fi
  fi
  eval $buildsvar=$buildsval
}

#
# Get all package repos
#
# Args:
#
getPkgRepos() {

# Determine the file containing the package repos
  if test -n "$PACKAGE_REPOS_FILE"; then
    techo "PACKAGE_REPOS_FILE = $PACKAGE_REPOS_FILE."
    grep "^PACKAGE_REPO:" $PACKAGE_REPOS_FILE | sed 's/^PACKAGE_REPO: *//' >$BUILD_DIR/pkgrepos.txt
    NUM_PACKAGE_REPOS=`wc -l $BUILD_DIR/pkgrepos.txt | sed -e 's/^ *//' -e 's/ .*$//'`
    echo "NUM_PACKAGE_REPOS = $NUM_PACKAGE_REPOS."
    local i=0; while test $i -lt $NUM_PACKAGE_REPOS; do
      i1=`expr $i + 1`
      local line=`sed -n "${i1}p" <$BUILD_DIR/pkgrepos.txt`
      # echo "line = $line."
      local repodir=`echo $line | sed 's/,.*$//'`
      PACKAGE_REPO_DIRS[$i]=$repodir
      local repomethod=`echo $line | sed -e "s/$repodir,//" -e 's/=.*$//'`
      PACKAGE_REPO_METHODS[$i]=$repomethod
      local repourl=`echo $line | sed -e "s/$repodir,$repomethod=//"`
      PACKAGE_REPO_URLS[$i]=$repourl
      i=$i1
    done
    if test $NUM_PACKAGE_REPOS -eq 0; then
      techo "WARNING: Found 0 package repos."
    else
      techo "Found $NUM_PACKAGE_REPOS package repos:"
      local i=0; while test $i -lt $NUM_PACKAGE_REPOS; do
        techo "PACKAGE_REPO_DIRS[$i] = ${PACKAGE_REPO_DIRS[$i]}."
        techo "PACKAGE_REPO_METHODS[$i] = ${PACKAGE_REPO_METHODS[$i]}."
        techo "PACKAGE_REPO_URLS[$i] = ${PACKAGE_REPO_URLS[$i]}."
        i=`expr $i + 1`
      done
    fi
  else
    techo "WARNING: PACKAGE_REPOS_FILE undefined.  Not known where to get packages."
    NUM_PACKAGE_REPOS=0
  fi

# Check out all the repos
  cd $PROJECT_DIR
  local i=0; while test $i -lt $NUM_PACKAGE_REPOS; do
    if test -d ${PACKAGE_REPO_DIRS[$i]}; then
      techo "${PACKAGE_REPO_DIRS[$i]} exists.  No need to get."
    else
      case ${PACKAGE_REPO_METHODS[$i]} in
        svn)
          if ! bilderSvn co "--non-interactive --depth=empty ${PACKAGE_REPO_URLS[$i]} ${PACKAGE_REPO_DIRS[$i]}"; then
            bilderSvn -2 co "--non-interactive --depth=empty ${PACKAGE_REPO_URLS[$i]} ${PACKAGE_REPO_DIRS[$i]}"
          fi
          ;;
        *)
          mkdir ${PACKAGE_REPO_DIRS[$i]}
          ;;
      esac
    fi
    i=`expr $i + 1`
  done
  cd - 1>/dev/null

}

#
# Set the distutils environment
#
setDistutilsEnv() {

# For some distutils packages, the flags should be with the compiler,
# so as not to overwrite the package flags.  This apparently varies,
# so here we set them separately, and packages that need them together
# will have to assemble what they need.
# DISTUTILS_ENV defines the compiler and flags separately.
# DISTUTILS_ENV2 defines the compiler and flags together, so the flags
#  can be added by each package.

  unset DISTUTILS_ENV
  unset DISTUTILS_ENV2
  case `uname` in
    CYGWIN*)
      DISTUTILS_ENV="$ENV_VS9"
      ;;
    *)
      for i in CC CXX F77 FC; do
        local compval=`deref PYC_$i`
        if test -n "$compval"; then
          local flagsprfx=`getCompFlagsPrefix $i`
          local flagsval=`deref PYC_${flagsprfx}FLAGS`
          local compflagsval="$compval $flagsval"
          trimvar compval ' '
          DISTUTILS_ENV="$DISTUTILS_ENV $i='$compval' ${flagsprfx}FLAGS='$flagsval'"
# Second form required to get, e.g., CFLAGS, not CCFLAGS.
          DISTUTILS_ENV2="$DISTUTILS_ENV2 $i='$compflagsval'"
        fi
      done
      DISTUTILS_ENV="$DISTUTILS_ENV F90='$PYC_FC' F90FLAGS='$PYC_FCFLAGS'"
# Numpy uses F90 with flags
      DISTUTILS_ENV2="$DISTUTILS_ENV2 F90='$PYC_FC $PYC_FCFLAGS'"
      ;;
  esac

# Create load vars env
  local LDVARS_ENV
# All should be the gcc variables
  if [[ `uname` =~ Linux ]]; then
    for i in LD_RUN_PATH LD_LIBRARY_PATH LDSHARED; do
      local val=`deref PYC_$i`
      local val2=`deref $i`
      if test -n "$val"; then
        LDVARS_ENV="$LDVARS_ENV $i='$val:$val2'"
      fi
    done
    if test -n "$PYC_LD_LIBRARY_PATH"; then
      PYC_MODFLAGS="$PYC_MODFLAGS -Wl,-rpath,$PYC_LD_LIBRARY_PATH"
    fi
  fi

# Finish up
  DISTUTILS_NOLV_ENV="$DISTUTILS_ENV"
  # DISTUTILS_ENV="$DISTUTILS_ENV $LINLIB_CC4PY_ENV $LDVARS_ENV"
  DISTUTILS_ENV="$DISTUTILS_ENV $LDVARS_ENV"
  # DISTUTILS_ENV2="$DISTUTILS_ENV2 $LINLIB_CC4PY_ENV $LDVARS_ENV"
  DISTUTILS_ENV2="$DISTUTILS_ENV2 $LDVARS_ENV"
  trimvar DISTUTILS_ENV ' '
  trimvar DISTUTILS_NOLV_ENV ' '
  trimvar DISTUTILS_ENV2 ' '

}

#
# Parallel Fortran compilers
#
findParallelFcComps() {
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
}

#
# Compute combined vars
#
getCombinedCompVars() {

  techo -2 "Setting the combined compiler variables."
  for i in SER BEN PYC PAR; do

    # techo -2 "Working on $i."

# Compiler variable names for autotools
    case $i in
      SER) unset varprfx;;
      PYC) varprfx=PYC_;;
      PAR) varprfx=MPI;;
      *) varprfx=$i;;
    esac

# Configure compilers
    # techo -2 "Adding to COMPILERS_$i."
    unset CONFIG_COMPILERS_$i
    for j in CC CXX FC F77; do
      techo -2 "COMPILER $j."
      local var=${varprfx}$j
      local comp=`deref ${var}`
# Why is the below here?  Breaks names with spaces in them.
      # comp=`echo $comp | sed 's/ .*$//'`
      # techo -2 "compbin = $compbin."
      if test -n "$comp"; then
        local compbin=
        if ! compbin=`which "$comp" 2>/dev/null` && [[ `uname` =~ CYGWIN ]]; then
          compbin=`cygpath -au "$comp"`
        fi
        compbin=${compbin:-"$comp"}
        eval $var="'$compbin'"
        val=`deref CONFIG_COMPILERS_$i`
        eval CONFIG_COMPILERS_$i=\"$val $j=\'$compbin\'\"
      fi
    done
    trimvar CONFIG_COMPILERS_$i ' '

# Cmake compilers.
    techo -2 "Adding to CMAKE_COMPILERS_$i."
    unset CMAKE_COMPILERS_$i
# Trilinos wants F77, but that should be fixed in trilinos
    # for j in CC CXX F77; do
    for j in CC CXX FC; do
      case $j in
        CC)
         cmakecompname=C
         ;;
        F77 | FC)
         cmakecompname=Fortran
         ;;
        *)
         cmakecompname=$j
         ;;
      esac
      var=${varprfx}$j
      comp=`deref ${var}`
# Why is the below here?  Breaks names with spaces in them.
      # compbin=`echo $comp | sed 's/ .*$//'`
      # techo "$var = $comp."
      if test -n "$comp" && which "$comp" 1>/dev/null 2>&1; then
        case `uname` in
          CYGWIN*)
            compbin=`cygpath -am "$comp"`
            if ! echo $compbin | grep -q '\.exe$'; then
              compbin="$compbin".exe
            fi
            ;;
          *) compbin="$comp";;
        esac
        # techo "$var = $compbin."
# Compilers need not be in path
        val=`deref CMAKE_COMPILERS_$i`
        eval CMAKE_COMPILERS_$i=\"$val -DCMAKE_${cmakecompname}_COMPILER:FILEPATH=\'$compbin\'\"
      fi
    done
    trimvar CMAKE_COMPILERS_$i ' '

  done
  techo -2 "The combined compiler variables have been set."

}

#
# Given a variable prefix and a set of libraries specified
# by any of full path, -L, -l, populate
#  <var prefix>_LIBRARY_DIRS with the library directories
#  <var prefix>_LIBRARY_NAMES with the basic names (no suffixes or prefixes)
#  <var prefix>_STATIC_LIBRARIES with any static libraries found
#
# Args:
# 1: The prefix of the variable
# 2: Set of libraries
#
findLibraries() {

# Get the cmake args
  local argprfx=$1
  local libval=$2
  techo -2 "Finding variables for $argprfx for libraries, $libval."
  if test -z "$libval"; then
    return
  fi

# Find library directories
  local libdirs
  local libdir
  local libnames
  local libname
  for k in $libval; do
    unset libdir
    unset libname
    case $k in
      -l*)
        libname=`echo $k | sed 's/^-l//'`
        ;;
      -L*)
        libdir=`echo $k | sed 's/^-L//'`
        ;;
      /* | [a-zA-Z]:*)
        libdir=`dirname $k`
        libname=`basename $k | sed -e 's/^lib//' -e 's/\.lib$//' -e 's/\.a$//' -e 's/\.so$//' -e 's/\.dll$//' -e 's/\.dylib$//'`
        ;;
    esac
    if test -n "$libdir"; then
      if ! echo $libdirs | egrep -q "(^| )$libdir($| )"; then
        libdirs="$libdirs $libdir"
      fi
    fi
    if test -n "$libname"; then
      if ! echo $libnames | egrep -q "(^| )$libname($| )"; then
        libnames="$libnames $libname"
      fi
    fi
  done
  pkgdir=`echo $libdirs | sed 's/ .*$//'`
  pkgdir=`dirname $pkgdir`
  eval ${argprfx}_DIR="$pkgdir"
  trimvar libdirs ' '
  eval ${argprfx}_LIBRARY_DIRS="'$libdirs'"
  trimvar libnames ' '
  eval ${argprfx}_LIBRARY_NAMES="'$libnames'"

# Find static libraries
  local staticlibs
  local staticlib
  for k in $libnames; do
    unset staticlib
    for ld in $libdirs; do
      if test -f $ld/lib${k}.a; then
        staticlib=$ld/lib${k}.a
        break
      elif test -f $ld/${k}.lib; then
        staticlib=$ld/${k}.lib
        break
      fi
    done
    if test -n "$staticlib"; then
      if ! echo $staticlibs | egrep -q "(^| )$staticlib($| )"; then
        staticlibs="$staticlibs $staticlib"
      fi
    fi
  done
  if test -n "$staticlibs"; then
    trimvar staticlibs ' '
  fi
  eval ${argprfx}_STATIC_LIBRARIES="'$staticlibs'"

}

#
# Find a package that may be in the contrib dir, reset vars as appropriate,
# but if found as a SYSTEM_ variable, use that.
#
# Args:
# 1: The name of the package
#    (appropriately capitalized, pkgnamelc be a package.sh bilder script)
# 2: Library name to look for
# 3: different builds to look for
#
# Named args (must come first):
# -p Variable name prefix
#
findContribPackage() {

  local nameprefix=
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "p:" arg; do
    case $arg in
      p) nameprefix=$2;;
    esac
  done
  shift $(($OPTIND - 1))

# Get args, builds
  if test -n "$1"; then
    local pkgname=$1
    pkgnamelc=`echo $1 | tr 'A-Z./' 'a-z__'`
    pkgnameuc=`echo $1 | tr 'a-z./-' 'A-Z___'`
    shift
    local PKG_LIBNAME=$1
    shift
  else
    techo "[findContribPackage] usage: findContribPackage pkgname BUILDS"
  fi
  local pkgnameprefix=${nameprefix}${pkgnameuc}
  while test -n "$1"; do
    local targetBlds="$targetBlds $1"
    shift
  done
  trimvar targetBlds ' '
  techo "Seeking $pkgnamelc with builds $targetBlds as system definition or in contrib dir."

# For each build, find the specified library
  local BLD
  local adirvar
  local adirval
  local alibvar
  local alibval
  local alibdirval
  eval HAVE_${pkgnameprefix}_ANY=false
  for bld in $targetBlds; do

# Set variable names
    BLD=`echo $bld | tr 'a-z' 'A-Z'`
    sysadirvar=SYSTEM_${pkgnameprefix}_${BLD}_DIR
    adirvar=${pkgnameprefix}_${BLD}_DIR
    alibvar=${pkgnameprefix}_${BLD}_LIB

# First look in system
    adirval=`deref $sysadirvar`
# Otherwise in contrib
    if test -z "$adirval"; then
      case $bld in
        ser)
          adirval=${CONTRIB_DIR}/${pkgnamelc}
          ;;
        *)
          adirval=${CONTRIB_DIR}/${pkgnamelc}-$bld
          ;;
      esac
    fi
    alibdirval=${adirval}/lib
    if test -d $alibdirval; then
      alibdirval=`(cd $alibdirval; pwd -P)`
      techo "Found $alibdirval."
    elif test -n "$adirval" -a -d "$adirval"; then
      techo "Using $adirvar = $adirval."
      eval HAVE_${pkgnameprefix}_$BLD=true
    else
      techo "Directory $adirvar not set, and $alibdirval not found. Setting HAVE_${pkgnameprefix}_$BLD to false."
      eval HAVE_${pkgnameprefix}_$BLD=false
      continue
    fi

# Look for the library
    local havelib=false
    if test -f $alibdirval/${PKG_LIBNAME}.lib; then
      havelib=true
      alibval=$alibdirval/${PKG_LIBNAME}.lib
    else
      for sfx in a so dylib; do
        if test -f $alibdirval/lib${PKG_LIBNAME}.$sfx; then
          havelib=true
          alibval=$alibdirval/lib${PKG_LIBNAME}.$sfx
          break
        fi
      done
      if test -d $alibdirval/${PKG_LIBNAME}.framework; then
        havelib=true
      fi
    fi

# Set variables accordingly
    if $havelib; then
      eval $adirvar=`(cd $alibdirval/..; pwd -P)`
      eval HAVE_${pkgnameprefix}_${BLD}=true
      adirval=`deref $adirvar`
      eval ${pkgnameprefix}_${BLD}_LIBDIR=$alibdirval
      eval $alibvar=$alibval
      techo "Package ${pkgnameprefix}_${BLD} found."
      techo "$adirvar = $adirval."
      techo "$alibvar = $alibval."
    elif test -n "$adirval"; then
      techo "New build, ${pkgnameprefix}_${BLD}, not found."
      techo "Keeping ${pkgnameprefix}_${BLD}_DIR = $adirval."
    else
      techo "Package ${pkgnameprefix}_${BLD} not set or found."
      eval HAVE_${pkgnameprefix}_$BLD=false
    fi

# Set cmake and config args
    adirvar=${pkgnameprefix}_${BLD}_DIR
    adirval=`deref $adirvar`
    local adirvalcmake=
    local alibdirvalcmake=
    case `uname` in
      CYGWIN*)
        if test -n "$adirval"; then
          adirvalcmake=`cygpath -am $adirval`
        fi
        if test -n "$alibdirval"; then
          alibdirvalcmake=`cygpath -am $alibdirval`
        fi
        ;;
      *)
        adirvalcmake="$adirval"
        alibdirvalcmake="$alibdirval"
        ;;
    esac
    eval CMAKE_${pkgnameprefix}_${BLD}_DIR=$adirvalcmake
    eval CMAKE_${pkgnameprefix}_${BLD}_LIBDIR=$alibdirvalcmake
    if test -n "$adirvalcmake"; then
# cmake moving too root_dir
      eval CMAKE_${pkgnameprefix}_${BLD}_DIR_ARG=-D${pkgname}_ROOT_DIR:PATH=$adirvalcmake
    fi
    val=`deref CMAKE_${pkgnameprefix}_${BLD}_DIR_ARG`
    techo "CMAKE_${pkgnameprefix}_${BLD}_DIR_ARG = $val"
    if test -n "$adirval"; then
      eval CONFIG_${pkgnameprefix}_${BLD}_DIR_ARG=--with-${pkgnamelc}-dir=$adirval
    fi
    val=`deref CONFIG_${pkgnameprefix}_${BLD}_DIR_ARG`
    techo "CONFIG_${pkgnameprefix}_${BLD}_DIR_ARG = $val"

# Set any
    local havepkg=`deref HAVE_${pkgnameprefix}_$BLD`
    if $havepkg; then
      eval HAVE_${pkgnameprefix}_ANY=true
    fi

  done

}

#
# Set the values of package variables to a default value
#
# Args:
# 1: The name of the package, capitalized as the variable is.
# 2: The builds to set.  The first one determines the default.
# 3: The variables endings for the first variables to set.
#    The first one determines whether found.
#
setDefaultPkgVars() {
  local PKG=$1
  local BLDS="$2"
  local VARS="$3"
  local PREFIXES="$4"
  local SUFFIXES="$5"
  local DEFB=`echo $BLDS | sed 's/ .*$//'`
  local BLDSREM=`echo $BLDS | sed "s/^$DEFB //"`
  local VAR0=`echo $VARS | sed 's/ .*$//'`
  # techo "BLDSREM = $BLDSREM."
  local varval=
  local defval=
  for BLD in $BLDSREM; do
    varval=`deref ${PKG}_${BLD}_${VAR0}`
    defval=`deref ${PKG}_${DEFB}_${VAR0}`
    if test -z "$varval" -a -n "$defval"; then
      techo "Setting ${PKG}_$BLD variables to ${PKG}_$DEFB values."
      eval HAVE_${PKG}_${BLD}=true
      for VAR in $VARS; do
      eval ${PKG}_${BLD}_${VAR}=`deref ${PKG}_${DEFB}_${VAR}`
      # techo "${PKG}_${BLD}_${VAR} = `deref ${PKG}_${BLD}_${VAR}`."
      done
      if test -n "$PREFIXES" -a -n "$SUFFIXES"; then
        for PRE in $PREFIXES; do
          for SUF in $SUFFIXES; do
            eval ${PRE}_${PKG}_${BLD}_${SUF}=`deref ${PRE}_${PKG}_${DEFB}_${SUF}`
          done
        done
      fi
    fi
  done
}

#
# Find blas and lapack in various forms for the builds, ser, cc4py, and ben.
#
# The goal is to assign values
#   LINLIB_${BLD}_LIBS, the absolute paths to the libraries
#   CMAKE_LINLIB_${BLD}_ARGS, the cmake args for finding those libraries
#   CONFIG_LINLIB_${BLD}_ARGS, the autotools args for finding those libraries
# where BLD = SER, CC4PY, BEN, and
#   LAPACK_${BLD}_${VAR}
#   BLAS_${BLD}_${VAR}
# where VAR is one of DIR, LIBRARY_DIRS, LIBRARY_NAMES
#
# Additionally, the above are set for the prefixes, SYSTEM, ATLAS,
# CONTRIB, CLAPACK_CMAKE, and USR.
#
# There is the possibility that lapack and blas are not
# found, but they are there.  In this case they remain
# unset and packages should find.
#
findBlasLapack() {

  techo "----------------------------------------"
  techo "--------> Executing findBlasLapack <--------"
# The favored configuration args in order:
#   system
#   contrib atlas, contrib lapack
#   atlas-clapack, clapack
  USE_ATLAS=${USE_ATLAS:-"false"}

# Temps
  local lapack_libs=
  local blas_libs=

#
# First: Determine LAPACK_${BLD}_LIBS and BLAS_${BLD}_LIBS
# for possible build values, BLD.
#

# Use system libraries if defined
  for BLD in SER CC4PY BEN; do
    lapack_libs=`deref SYSTEM_LAPACK_${BLD}_LIB`
    blas_libs=`deref SYSTEM_BLAS_${BLD}_LIB`
    if test -n "$lapack_libs" -a -n "$blas_libs"; then
      techo "Setting lapack and blas using SYSTEM_LAPACK_${BLD}_LIB = $lapack_libs and SYSTEM_BLAS_${BLD}_LIB = $blas_libs."
      eval LAPACK_${BLD}_LIBS="\"$lapack_libs\""
      eval BLAS_${BLD}_LIBS="\"$blas_libs\""
    fi
  done

# Find atlas build, but use it only if requested.
  findContribPackage ATLAS atlas ser cc4py ben clp
# Set defaults
  setDefaultPkgVars ATLAS "SER CC4PY BEN" "LIB DIR LIBDIR" "CMAKE CONFIG" DIR_ARG
  for BLD in SER CC4PY BEN; do
    techo -2 "ATLAS_${BLD}_DIR = `deref ATLAS_${BLD}_DIR`."
    techo -2 "ATLAS_${BLD}_LIB = `deref ATLAS_${BLD}_LIB`."
    techo -2 "ATLAS_${BLD}_LIBDIR = `deref ATLAS_${BLD}_LIBDIR`."
    techo -2 "CMAKE_ATLAS_${BLD}_DIR_ARG = `deref CMAKE_ATLAS_${BLD}_DIR_ARG`."
    techo -2 "CONFIG_ATLAS_${BLD}_DIR_ARG = `deref CONFIG_ATLAS_${BLD}_DIR_ARG`."
  done
# Compute vars
  USE_ATLAS_CC4PY=${USE_ATLAS_CC4PY:-"true"}
  for BLD in SER CC4PY BEN CLP; do
    lapack_libs=`deref LAPACK_${BLD}_LIBS`
    blas_libs=`deref BLAS_${BLD}_LIBS`
    local haveatlas=`deref HAVE_ATLAS_$BLD`
    local useatlas=`deref USE_ATLAS_$BLD`
    useatlas=${useatlas:-"$USE_ATLAS"}
    useatlas=${useatlas:-"false"}
    if $useatlas && $haveatlas && test -z "$lapack_libs" -o -z "$blas_libs"; then
      local atlaslibdir=`deref ATLAS_${BLD}_DIR`/lib
      eval LAPACK_${BLD}_LIBS="\"-L$atlaslibdir -llapack\""
      if test $BLD = CLP; then
        eval BLAS_${BLD}_LIBS="\"-L$atlaslibdir -lcblas -lf77blas -latlas -lf2c\""
      else
        eval BLAS_${BLD}_LIBS="\"-L$atlaslibdir -lcblas -lf77blas -latlas\""
      fi
    fi
    techo -2 "LAPACK_${BLD}_LIBS = `deref LAPACK_${BLD}_LIBS`."
    techo -2 "BLAS_${BLD}_LIBS = `deref BLAS_${BLD}_LIBS`."
  done

# Find the lapack in the contrib dir, but use it only if requested.
  findContribPackage -p CONTRIB_ LAPACK lapack ser cc4py ben
  setDefaultPkgVars CONTRIB_LAPACK "SER CC4PY BEN" "LIB DIR LIBDIR" "CMAKE CONFIG" DIR_ARG
  USE_CONTRIB_LAPACK=${USE_CONTRIB_LAPACK:-"false"}
  if $USE_CONTRIB_LAPACK; then
    for BLD in SER CC4PY BEN; do
      lapack_libs=`deref LAPACK_${BLD}_LIBS`
      blas_libs=`deref BLAS_${BLD}_LIBS`
      local havecontlp=`deref HAVE_CONTRIB_LAPACK_$BLD`
      if $havecontlp && test -z "$lapack_libs" -o -z "$blas_libs"; then
        local contlplibdir=`deref CONTRIB_LAPACK_${BLD}_LIBDIR`
        eval LAPACK_${BLD}_LIBS="\"-L$contlplibdir -llapack\""
        eval BLAS_${BLD}_LIBS="\"-L$contlplibdir -lblas\""
      fi
    done
  fi

# Find clapack.  Use it if found and not defined.
  findContribPackage clapack_cmake lapack ser cc4py ben
  for BLD in SER CC4PY BEN; do
    lapack_libs=`deref LAPACK_${BLD}_LIBS`
    blas_libs=`deref BLAS_${BLD}_LIBS`
    local haveclp=`deref HAVE_CLAPACK_CMAKE_$BLD`
    if $haveclp && test -z "$lapack_libs" -o -z "$blas_libs"; then
      local clplibdir=`deref CLAPACK_CMAKE_${BLD}_LIBDIR`
      eval LAPACK_${BLD}_LIBS="\"-L$clplibdir -llapack\""
      eval BLAS_${BLD}_LIBS="\"-L$clplibdir -lblas -lf2c\""
    fi
  done

# If still not found, try some system locations under /usr
  if test `uname` = Linux; then
    techo "Looking for blas and lapack in $SYS_LIBSUBDIRS under /usr."
    for lib in blas lapack; do
      varname=USR_`genbashvar $lib`_SER_LIBS
      unset varval
      for dir in $SYS_LIBSUBDIRS; do
        if test -f /usr/$dir/lib${lib}.so -o -L /usr/$dir/lib${lib}.so; then
          varval=/usr/$dir/lib${lib}.so
          break
        elif test -f /usr/$dir/lib${lib}.a; then
          varval=/usr/$dir/lib${lib}.a
          break
        fi
      done
      if test -n "$varval"; then
        eval $varname=$varval
        techo "$varname = $varval found."
      else
        techo "WARNING: $varname empty and lib${lib} not found.  May need to install $lib-devel."
      fi
    done
# No need to set as always found by build systems.
# Not true: nubeam needs these specified.
# if false; then
    lapack_libs=`deref LAPACK_SER_LIBS`
    blas_libs=`deref BLAS_SER_LIBS`
    if test -z "$lapack_libs" -o -z "$blas_libs"; then
      LAPACK_SER_LIBS="$USR_LAPACK_SER_LIBS"
      BLAS_SER_LIBS="$USR_BLAS_SER_LIBS"
    fi
# fi
  fi

# Ben, cc4py default to ser
  LAPACK_BEN_LIBS=${LAPACK_BEN_LIBS:-"$LAPACK_SER_LIBS"}
  BLAS_BEN_LIBS=${BLAS_BEN_LIBS:-"$BLAS_SER_LIBS"}
  LAPACK_CC4PY_LIBS=${LAPACK_CC4PY_LIBS:-"$LAPACK_SER_LIBS"}
  BLAS_CC4PY_LIBS=${BLAS_CC4PY_LIBS:-"$BLAS_SER_LIBS"}

# Find all library variables.
# Not done for Darwin, as Accelerate framework there.
  if ! test `uname` = Darwin; then
    for BLD in SER CC4PY BEN; do
      lapack_libs=`deref LAPACK_${BLD}_LIBS`
      blas_libs=`deref BLAS_${BLD}_LIBS`
      eval LINLIB_${BLD}_LIBS="\"$lapack_libs $blas_libs\""
      trimvar LINLIB_${BLD}_LIBS ' '
      if test -n "`deref LINLIB_${BLD}_LIBS`"; then
        findLibraries LAPACK_${BLD} "$lapack_libs"
        findLibraries BLAS_${BLD} "$blas_libs"
        eval CONFIG_LINLIB_${BLD}_ARGS="\"--with-lapack-lib='$lapack_libs' --with-blas-lib='$blas_libs' --with-lapack='$lapack_libs' --with-blas='$blas_libs'\""
        local lapack_libdirs=`deref LAPACK_${BLD}_LIBRARY_DIRS | tr ' ' ';'`
        local lapack_libnames=`deref LAPACK_${BLD}_LIBRARY_NAMES | tr ' ' ';'`
        local blas_libdirs=`deref BLAS_${BLD}_LIBRARY_DIRS | tr ' ' ';'`
        local blas_libnames=`deref BLAS_${BLD}_LIBRARY_NAMES | tr ' ' ';'`
        eval CMAKE_LINLIB_${BLD}_ARGS="\"-DLAPACK_LIBRARY_DIRS:PATH='$lapack_libdirs' -DLAPACK_LIBRARY_NAMES:STRING='$lapack_libnames' -DBLAS_LIBRARY_DIRS:PATH='$blas_libdirs' -DBLAS_LIBRARY_NAMES:STRING='$blas_libnames'\""
      fi
    done
  fi

# Print out results
  for BLD in SER CC4PY BEN; do
    techo "LINLIB_${BLD}_LIBS = `deref LINLIB_${BLD}_LIBS`."
    techo "CMAKE_LINLIB_${BLD}_ARGS = `deref CMAKE_LINLIB_${BLD}_ARGS`."
    techo "CONFIG_LINLIB_${BLD}_ARGS = `deref CONFIG_LINLIB_${BLD}_ARGS`."
    for PKG in BLAS LAPACK; do
      for VAR in DIR LIBRARY_DIRS LIBRARY_NAMES; do
        techo "${PKG}_${BLD}_${VAR} = `deref ${PKG}_${BLD}_${VAR}`."
      done
    done
  done
  # techo "Quitting after finding blas and lapack libraries."; exit

# The linear library env is needed for numpy and scipy only.
# BLAS and LAPACK define the dirs they are in, and then numpy
# checks for mkl, acml, ...
  LINLIB_CC4PY_ENV=
  for PKG in LAPACK BLAS; do
    local libdir=`deref ${PKG}_CC4PY_LIBRARY_DIRS | sed 's/ .*$//'`
    if test -n "$libdir"; then
      if [[ `uname` =~ CYGWIN ]]; then
        libdir=`cygpath -aw "$libdir"`
      fi
      LINLIB_CC4PY_ENV="$LINLIB_CC4PY_ENV $PKG='$libdir'"
    fi
  done
  trimvar LINLIB_CC4PY_ENV ' '
  techo "LINLIB_CC4PY_ENV = $LINLIB_CC4PY_ENV."
  setDistutilsEnv
  # techo "Quitting after setDistutilsEnv."; exit

}

#
# Find the BOOST includes
#
findBoost() {
  if test -z "$BOOST_BLDRVERSION"; then
    source $BILDER_DIR/packages/boost.sh
  fi
  if test -L $CONTRIB_DIR/boost -o -d $CONTRIB_DIR/boost; then
    local boostincdir=`(cd $CONTRIB_DIR/boost/include; pwd -P)`
    if [[ `uname` =~ CYGWIN ]]; then
      boostincdir=`cygpath -am $boostincdir`
    fi
    BOOST_INCDIR_ARG="-DBoost_INCLUDE_DIR='$boostincdir'"
  fi
}

#
# Find a the cc4py build of a package that may be in the contrib dir
# by using that value, or sersh if not present, then ser
#
# Args:
# 1: The name of the package (should be a package.sh bilder script)
#
findCc4pyDir() {

# Get name of package
  if test -n "$1"; then
    local pkgname=$1
    local pkgnameuc=`echo $1 | tr 'a-z./-' 'A-Z___'`
    local pkgnamelc=`echo $1 | tr 'A-Z./' 'a-z__'`
    shift
  fi

# Look through names
  local val=`deref ${pkgnameuc}_CC4PY_DIR`

# If explicit build not found, then it is the shared, then the serial
  if test -z "$val"; then
    eval ${pkgnameuc}_CC4PY_DIR=`deref ${pkgnameuc}_SERSH_DIR`
    val=`deref ${pkgnameuc}_CC4PY_DIR`
  fi
  if test -z "$val"; then
    eval ${pkgnameuc}_CC4PY_DIR=`deref ${pkgnameuc}_SER_DIR`
    val=`deref ${pkgnameuc}_CC4PY_DIR`
  fi
  eval CONFIG_${pkgnameuc}_CC4PY_DIR_ARG="--with-${pkgnamelc}-dir='$val'"
  if test -n "$val"; then
    case `uname` in
      CYGWIN*)
        val=`cygpath -am $val`
      ;;
    esac
  fi
  eval CMAKE_${pkgnameuc}_CC4PY_DIR_ARG="-D${pkgname}_ROOT_DIR:PATH='$val'"
  techo "CMAKE_${pkgnameuc}_CC4PY_DIR_ARG = `deref CMAKE_${pkgnameuc}_CC4PY_DIR_ARG`."

}

#
# Find the QT packages
#
findQt() {
# First try to find Qt in the contrib directory
  if [[ `uname` =~ CYGWIN ]]; then
    findContribPackage qt QtCore4 ser
  else
    findContribPackage qt QtCore ser
  fi
  if test -n "$QT_SER_DIR"; then
    QT_BINDIR=$QT_SER_DIR/bin
    QMAKE=$QT_BINDIR/qmake
    techo "Qt found in $CONTRIB_DIR.  Using QT_BINDIR = $QT_BINDIR."
    addtopathvar PATH $QT_SER_DIR/bin
    techo "$QT_SER_DIR/bin added to path."
    return 0
  fi
  techo "Qt not found in $CONTRIB_DIR."
# Next try to find qmake in one's path
  QMAKE=`which qmake 2>/dev/null`
  if test -n "$QMAKE"; then
    QT_BINDIR=`dirname $QMAKE`
    techo "qmake found in PATH.  Using QT_BINDIR = $QT_BINDIR."
    return 0
  fi
  techo "qmake not in path."
  if test -z "$QT_BINDIR"; then
    case `uname` in
      CYGWIN*)
        techo "Searching Windows installation directories."
        QT_BVER=`ls /cygdrive/c/Qt | grep "^4" | tail -1`
        if test -n "$QT_BVER"; then
          QT_BINDIR=/cygdrive/c/Qt/$QT_BVER/bin
        fi
        ;;
    esac
  fi
  if test -z "$QT_BINDIR"; then
    techo "WARNING: Could not find Qt."
    return 1
  fi
  QMAKE=$QT_BINDIR/qmake
  techo "QT_BINDIR = $QT_BINDIR."
  addtopathvar PATH $QT_BINDIR
  return 0
}

#
# Compute the make jvalue from the builds
#
# Args:
# 1: package name
# 2: comma delimited list of builds
#
computeMakeJ() {
  if test -n "$MAKEJ_MAX" -a -n "$2"; then
    local numblds=`echo $2 | tr ',' ' ' | wc -w | sed 's/^ *//'`
    local jval=`expr $MAKEJ_MAX / $numblds`
    if test -n "$jval"; then
      if test $jval -le 0; then
        jval=1
      fi
    else
      jval=1
    fi
    local makejvar=`genbashvar $1`_MAKEJ_MAX
    eval $makejvar=$jval
    local makejargs=`genbashvar $1`_MAKEJ_ARGS
    eval $makejargs="-j${jval}"
    techo -2 "computeMakeJ: $makejvar = $jval, $makejargs = -j${jval}."
  fi
}

#
# Unpack a package and link to non versioned name.
# Sets start time, $1_START_TIME.
#
# Args:
# 1: package name
# 2: the builds (ser, par, ...)
# 3: Any dependencies
#
# Named args (must come first):
# -i prepare for in-source build by unpacking source into build directory
# -I use this for the installation directory
# -f forces unpacking
#
bilderUnpack() {

# Save args from printout below
  if ! $USING_BUILD_CHAIN; then
    techo "bilderUnpack not using build chain."
  fi
  techo -2 "bilderUnpack called with $*"

# Determine whether to force install
  local inplace=false   # Whether to build in place
  local unpack=false
  local installdir=
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "fiI:" arg; do
    case $arg in
      f) unpack=true;;
      i) inplace=true;;
      I) installdir="$OPTARG";;
    esac
  done
  shift $(($OPTIND - 1))

# Remaining args
  local builds=$2
  techo "Determining whether to unpack $1."

# Record start time
  local starttimevar=`genbashvar $1`_START_TIME
  local starttimeval=`date +%s`
  eval $starttimevar=$starttimeval

# If unpacked, build directory is the subdir, except for qmake,
# which will override this, but use this directory for where
# generated files go.
  local unpackedvar=`genbashvar $1`_UNPACKED
  eval $unpackedvar=true

# Determine name of variable holding version and the value.
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`
# If not defined, look for standard and experimental versions
  if test -z "$verval"; then
    local vervar1=
    if $BUILD_EXPERIMENTAL; then
      vervar1=`genbashvar $1`_BLDRVERSION_EXP
    else
      vervar1=`genbashvar $1`_BLDRVERSION_STD
    fi
    verval=`deref $vervar1`
    eval $vervar=$verval
  fi
  if test -z "$verval"; then
    techo "$vervar not defined.  Cannot build."
    return 1
  fi

# Get builds if not specified as second arg
  local builds=$2
  local bldsvar=`genbashvar $1`_BUILDS
  local bldsval=`deref $bldsvar`
  techo -2 "$bldsvar = $bldsval"
  local builds=${builds:-"$bldsval"}
  if test -z "$builds" -o "$builds" = NONE; then
    techo "No builds so not unpacking $1-$verval."
    return 1
  fi

# Start build
  cd $PROJECT_DIR

# Get dependencies if not specified as third arg
  local DEPS=$3
  local depsvar=`genbashvar $1`_DEPS
  local depsval=`deref $depsvar`
  local DEPS=${DEPS:-"$depsval"}

# Determine name of variable holding umask.  If not present, default to 002.
  local umaskvar=`genbashvar $1`_UMASK
  local umaskval=`deref $umaskvar`
  if test -z "$umaskval"; then
    eval $umaskvar=002
  fi

# Set installation directory
  local instdirsvar=`genbashvar ${1}`_INSTALL_DIRS
  local instdirsval=${installdir:-"`deref $instdirsvar`"}
  if test -z "$instdirsval"; then
    techo -2 "bilderUnpack $1 $2 $3: instdirsval not set"
    instdirsval=$CONTRIB_DIR
    eval $instdirsvar=$instdirsval
  fi
  techo "bilderUnpack: $instdirsvar = $instdirsval."

# See whether should install
  if shouldInstall -I $instdirsval $1-$verval "$builds" $DEPS; then
    unpack=true
    techo "Package $1 needs building since a dependency rebuilt or $1 not installed."
  fi

  if $unpack; then

    techo -2 "inplace = $inplace"
    techo "Unpacking $1."
    techo "$vervar = $verval."

# Search for the package in all repos with all suffixes
    local tarball=
    local i=0; while test $i -lt $NUM_PACKAGE_REPOS; do
      local pkgdir=$PROJECT_DIR/${PACKAGE_REPO_DIRS[$i]}
      local sfx
      local sfxs=".tar.gz .tgz .tar.bz2 .tar.xz"
      for sfx in $sfxs; do
        local tarballbase=$1-${verval}${sfx}
        techo -n "Seeking $tarballbase in $pkgdir using"
        local tarballtry=$pkgdir/$tarballbase
        if test -f $tarballtry; then
          tarball=$tarballtry
        fi
        if $SVNUP_PKGS; then
          case ${PACKAGE_REPO_METHODS[$i]} in
            svn)
              techo " svn."
              (cd $pkgdir; bilderSvn up $tarballbase)
              ;;
            direct)
# Determine whether to use wget or curl
              local DIRECT_METHOD=
              if which wget 1>/dev/null 2>&1; then
                DIRECT_METHOD="wget -N -nv"
                techo " wget."
              else
                DIRECT_METHOD="curl -f -o $tarballbase"
                techo " curl."
              fi
              cd $pkgdir
              if ! test -f $tarballbase; then
                cmd="${DIRECT_METHOD} ${PACKAGE_REPO_URLS[$i]}/$tarballbase"
                techo "$cmd"
                $cmd
              fi
              cd - 1>/dev/null 2>&1
              ;;
          esac
        fi
        if test -f $tarballtry; then
          techo "$tarballbase found."
          tarball=$tarballtry
          tarballbase=`basename $tarballtry`
          pkgsandpatches="$pkgsandpatches $tarballbase"
          break
        else
          techo "$tarballbase not found."
        fi
      done
      if test -n "$tarball"; then
        break
      fi
      i=`expr $i + 1`
    done

# Not found
    if test -z $tarball; then
      TERMINATE_ERROR_MSG="Catastrophic error in bilderUnpack.  No tarball of any compression appeared.  Network okay?"
      cleanup
    fi

# Found
    techo "Found $tarball."

# If patch already set, do not change
    local patchvar=`genbashvar $1`_PATCH
    local patchval=`deref $patchvar`
    if test -z "$patchval"; then
      patchval=$BILDER_DIR/patches/$1-$verval.patch
      eval $patchvar=$patchval
    fi
    pkgsandpatches="$pkgsandpatches `basename $patchval`"
# No longer need to get patches now that they are part of bilder
    if test -f $patchval; then
      techo "Found $BILDER_DIR/patches/$1-$verval.patch."
    else
      techo "Did not find $BILDER_DIR/patches/$1-$verval.patch."
      patchval=
      eval $patchvar=
    fi
    cd $BUILD_DIR
    rmall $1-$verval
    techo "Unpacking $tarball."
    local pretar=
    case $tarball in
      *.tar.gz | *.tgz) pretar="gunzip -c";;
      *.tar.bz2) pretar="bunzip2 -c";;
      *.tar.xz) pretar="unxz -c";;
    esac
    if $inplace; then
      techo -2 "inplace evaluated to true."
      mkdir -p $1-$verval
      cd $1-$verval
      local builds=`echo $builds | tr ',' ' '`
      techo -2 builds = $builds
      for i in $builds; do
        techo "Unpacking for $i build in $PWD."
        cmd="rmall $i"
        techo -2 "$cmd"
        $cmd
        if test ! -f $tarball; then
          TERMINATE_ERROR_MSG="Catastrophic failure in bilderUnpack.  Tarball $tarball did not show up."
          cleanup
        fi
        cmd="$pretar $tarball | $TAR -xf -"
        techo "$cmd"
        $pretar $tarball | $TAR -xf -
        if test $? != 0; then
          TERMINATE_ERROR_MSG="Catastrophic error in bilderUnpack.  Unpacking failed."
          cleanup
        fi
        cmd="mv $1-$verval $i"
        techo -2 "$cmd"
        if ! $cmd; then
          techo "Catastrophic failure with mv in bilderUnpack."
          sleep 1
          techo -2 "$cmd"
          if ! $cmd; then
            TERMINATE_ERROR_MSG="Catastrophic failure with mv in bilderUnpack."
            cleanup
          fi
        fi
        if test -n "$patchval"; then
          techo "Patching $1-$i."
# OS X does not accept '-i'
# Check for whether new style patch
          local patchlev=-p1
          if grep -q '\.\./' $BILDER_DIR/patches/$1-$verval.patch; then
            patchlev=-p1
          fi
          (cd $BUILD_DIR/$1-$verval/$i; cmd="patch $patchlev -N <$patchval"; techo "In $PWD: $cmd"; patch $patchlev -N <$patchval >$BUILD_DIR/$1-$verval/$i/patch.out 2>&1)
          techo "Package $1-$i patched.  Results in $BUILD_DIR/$1-$verval/$i/patch.out."
          if grep -qi fail $BUILD_DIR/$1-$verval/$i/patch.out; then
            grep -i fail $BUILD_DIR/$1-$verval/$i/patch.out | sed 's/^/WARNING: /' >$BUILD_DIR/$1-$verval/$i/patch.fail
            cat $BUILD_DIR/$1-$verval/$i/patch.fail | tee -a $LOGFILE
          fi
        fi
      done
    else
      rmall $1-$verval/*
      techo "Unpacking for all builds in $PWD."
      if test ! -f  $tarball; then
        TERMINATE_ERROR_MSG="Catastrophic failure in bilderUnpack. Tarball$tarball did not show up."
        cleanup
      fi
      cmd="$pretar $tarball | $TAR -xf -"
      techo "$cmd"
      eval "$cmd"
      if test $? != 0; then
        techo "Catastrophic error in bilderUnpack.  Unpacking failed."
        cleanup
      fi
      if test -n "$patchval"; then
        techo "Patching $1."
# OS X does not accept '-i'
        local patchlev=-p1
# pcre has some '../' but not ' ../'
        if grep -q ' \.\./' $patchval; then
          : # patchlev=-p0
        fi
        (cd $BUILD_DIR/$1-$verval; cmd="patch $patchlev -N <$patchval"; techo "In $PWD: $cmd"; patch -N $patchlev <$patchval >$BUILD_DIR/$1-$verval/patch.out)
        techo "Package $1 patched. Results in $BUILD_DIR/$1-$verval/patch.out."
        if grep -qi fail $BUILD_DIR/$1-$verval/patch.out; then
          grep -i fail $BUILD_DIR/$1-$verval/patch.out | sed 's/^/WARNING: /' >$BUILD_DIR/$1-$verval/patch.fail
          cat $BUILD_DIR/$1-$verval/patch.fail | tee -a $LOGFILE
        fi
      fi
    fi
    techo "$tarball unpacked."
# Determine number of builds
    computeMakeJ $1 $builds
    return 0
  fi
  return 1

}

#
# Preconfigure a package.  Assumes version has been set in variable
# with name generated by genbashvar.  Sets installation directory,
# $1_INSTALL_DIR, and start time, $1_START_TIME.
#
# Dependencies:
# $1_BUILDS: A comma separated list of builds, e.g., "ser,par,nopetsc".
# $1_DEPS: A comma separated list of dependencies, e.g., "nubeam,uedge".
#
# Args:
# 1: package name
#
# Named args (must come first):
# -c force use of cmake even when a configure is present
# -f force preconfig, even if a dependency was not rebuilt
# -I use this for the comma separate list of installation directories
# -p execute this as the preconfigure action
# -t do not record failure if $IGNORE_TEST_RESULTS is true
#
# Returns 0 if ready to and should configure
# Returns 1 if all needed installations installed or did not preconfigure
#
bilderPreconfig() {

  techo -2 "bilderPreconfig called with $*"

# Default option values
  local usecmake=false
  local forcepreconfig=false
  local instdirs=
  local preconfigaction=
  local recordfailure=true
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "cfi:I:p:t" arg; do
    case $arg in
      c) usecmake=true;;
      f) forcepreconfig=true;;
      I) instdirs="$OPTARG";;
      p) preconfigaction="$OPTARG";;
      t) recordfailure=false;;
    esac
  done
  shift $(($OPTIND - 1))
  local proj=$1
  local lcproj=`echo $proj | tr A-Z a-z`

# Record start time
  local starttimevar=`genbashvar $1`_START_TIME
  local starttimeval=`date +%s`
  eval $starttimevar=$starttimeval
  # techo -2 "$starttimevar = $starttimeval"

# If preconfigaction not defined, set it, to local if it exists, then general
  if ! cd $PROJECT_DIR/$1 2>/dev/null; then
    techo "$PROJECT_DIR/$1 does not exist, cannot preconfigure."
    return 1
  fi
  if test -z "$preconfigaction" -a -x config/cleanconf.sh; then
    preconfigaction=config/cleanconf.sh
  fi
  preconfigaction=${preconfigaction:-"autoreconf"}

# Not unpacked
  local unpackedvar=`genbashvar $1`_UNPACKED
  eval $unpackedvar=false

# Determine builds
  buildsvarname=`genbashvar $1`_BUILDS
  builds=`deref $buildsvarname`
  if test -z "$builds" -o "$builds" = NONE; then
    techo "No builds specified for ${1}, quitting bilderPreconfig."
    return 1
  fi

# Determine name of variable holding umask.  If not present, default to 007.
  local umaskvar=`genbashvar $1`_UMASK
  local umaskval=`deref $umaskvar`
  if test -z "$umaskval"; then
    eval $umaskvar=007
  fi

# Get auxiliary files if defined.
  local testdatavar=`genbashvar $1`_TESTDATA
  local testdataval=`deref $testdatavar`
  techo "$testdatavar = $testdataval."
  if $TESTING && test -n "$testdataval"; then
    if declare -f bilderGetTestData 1>/dev/null 2>&1; then
      bilderGetTestData $1
    else
      techo "WARNING: function bilderGetTestData not defined.  Requested by $1."
      if test -n "$BILDER_CONFDIR"; then
        techo "WARNING: It should be defined in $BILDER_CONFDIR/bilderrc."
      else
        techo "WARNING: Define BILDER_CONFDIR and then define bilderGetTestData in $BILDER_CONFDIR/bilderrc."
      fi
    fi
  fi

# Create file stamp
  cd $PROJECT_DIR/$1
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`
  # techo "$vervar = $verval."

# Get dependencies
  local depsvar=`genbashvar $1`_DEPS
  local DEPS=`deref $depsvar`

# Set installation directory if not already set.
  local instdirsvar=`genbashvar $1`_INSTALL_DIRS
  local instdirs=${instdirs:-"`deref $instdirsvar`"}
  if test -z "$instdirs"; then
    instdirs=$BLDR_INSTALL_DIR
    eval $instdirsvar=$instdirs
  fi

# Set the package script version here, as is needed for installation
# even if this is not the reason for initiating a build.
  local currentPkgScriptRev=
  if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/${lcproj}.sh; then
    currentPkgScriptRev=`svn info $BILDER_CONFDIR/packages/${lcproj}.sh |\
      grep 'Last Changed Rev:' | sed 's/.* //'`
  elif test -f $BILDER_DIR/packages/${lcproj}.sh; then
    currentPkgScriptRev=`svn info $BILDER_DIR/packages/${lcproj}.sh |\
      grep 'Last Changed Rev:' | sed 's/.* //'`
  else
    currentPkgScriptRev=unknown
  fi
  local temp=`genbashvar ${1}`
  eval ${temp}_PKGSCRIPT_VERSION=$currentPkgScriptRev

# See whether should install
  doInstall=$forcepreconfig
  if $doInstall; then
    techo "Preconfiguring $1 because of -f option."
  else
# Determine builds to check for installation
    local chkbuilds="$builds"
    techo "Checking whether to install the "$chkbuilds" builds of $1."
    if shouldInstall -I $instdirs $1-$verval $chkbuilds $DEPS; then
      doInstall=true
      techo "Preconfiguring $1-$verval because a dependency rebuilt, or $1 not installed."
    fi
  fi

# If autotooled and that succeeds, then return true (0)
  RESULT=0
  if $doInstall; then
    techo "Preconfiguring $1 in $PWD."
    techo "$vervar = $verval."

# Remove any old configure files
    if test -x ${preconfigaction} || $usecmake; then
      cmd="rm -rf configure config.cache aclocal.m4 config.h.in autom4te*.cache"
      techo "$cmd"
      $cmd
      cmd="find . -name Makefile.in -delete"
      techo $cmd
      $cmd
    fi

# Preconfigure as needed
    if test -x ${preconfigaction} && ! $usecmake; then
      techo -2 "${preconfigaction} found"
      local preconfig_txt=$FQMAILHOST-$1-preconfig.txt
      case `uname` in
        # CYGWIN* | MINGW*)
          # RESULT=0
          # ;;
        *)
          local cmd="${preconfigaction}"
          techo "$cmd" | tee $preconfig_txt
          $cmd 1>>$preconfig_txt 2>&1
          RESULT=$?
          ;;
      esac
      if test $RESULT = 0; then
        techo "Package $1 preconfigured."
        echo SUCCESS >>$preconfig_txt
      else
        techo "Package $1 failed to preconfigure."
        echo FAILURE >>$preconfig_txt
        if $recordfailure || ! $IGNORE_TEST_RESULTS; then
          configFailures="$configFailures $1-preconfig"
          anyFailures="$anyFailures $1-preconfig"
        else
          techo "Not recording preconfig failure.  recordfailure = $recordfailure, IGNORE_TEST_RESULTS = $IGNORE_TEST_RESULTS."
        fi
      fi
      if test -n "$BLDR_PROJECT_URL"; then
        local subdir=`pwd -P | sed "s?^$PROJECT_DIR/??"`
        techo "See $BLDR_PROJECT_URL/$subdir/$preconfig_txt."
      fi
    else
      techo "Package $1 does not need preconfiguring."
      rm -f CMakeCache.txt
    fi
  else
    RESULT=1
  fi

# Print result and return
  if test $RESULT = 0; then
# Compute -j arg for make
    computeMakeJ $1 $builds
    techo "Package $1 preconfigured (if needed)."
  else
    techo "Package $1 not needed or preconfigure failed."
  fi
  return $RESULT

}

#
# Remove the libtool interlibrary dependency checking, as it
# is buggy
#
rminterlibdeps() {
  sed -i.bak -e "s/postdeps=.*$/postdeps=/g" -e "s/postdep_objects=.*$/postdep_objects=/g" -e "s/link_all_deplibs=.*$/link_all_deplibs=no/g" libtool
  sed -i.bak -e "s?-L/opt/fftw/3.2.[0-9]/lib??g" -e "s?/opt/fftw/3.2.[0-9]/lib??g" libtool
  rm -f libtool.bak
}

#
# Configure a package in a subdir
#
# Args:
# 1: package name
# 2: build name
# 3: configuration arguments except for prefix
# 4: (optional) this plus version gives installation directory
# 5: (optional) environment variable declarations
#
# Named args (must come first):
# -b Build in a subdir relative to where the configure takes place
#     (e.g., petscdev uses this)
# -B Same as -b only the typing of make is in place even though the
#     actual build is out-of-place.  This is for legacy petsc builds
#     of the petscrepo (yes, petsc is ridiculously complicated).
# -c force use of cmake even when a configure is present
# -d <dependencies>
# -f force regardless of dependencies
# -g do not use version for installation dir when 4th arg is used
#      and the installation dir is not otherwise specified (e.g., -p prefix)
# -i configures in the source directory
# -I use optarg for install directory
# -l removes previous install if found
# -n uses a space instead of an equals for the prefix command.
# -m Use this command instead of autotool/cmake configure.  Looks in
#    the build dir of the package/buildname and then in the package
#    for the command.
# -s if specified with -m, strips off the builddir and uses only the command
#    specified with -m option
# -p <specified prefix subdir>.  '-' means none.
# -q <name of .pro file> path (relative to src directory) and
#    name of .pro file to run qmake on
# -r uses riverbank procedure (for sip and PyQt): python configure.py
# -t do not record failure if $IGNORE_TEST_RESULTS is true
#
# Returns
#  0: configured and ready to build.
#  1: failed to configure
# 99: configuration not needed
#
bilderConfig() {

  techo -2 "bilderConfig called with $*"

# Default option values
  unset DEPS
  unset QMAKE_PRO_FILENAME
  local instsubdirval
  local cmval
  local configcmdin
  local stripbuilddir=false
  local forceconfig=false
  local usecmake=false
  local forceqmake=false
  local inplace=false
  local instdirs=
  local noequals=false  # Do not use equals in prefix command
  local webdocs=false  # By default, we do not build documentation for the web
  local riverbank=false
  local rminstall=false
  local recordfailure=true
  local buildsubdir
  local build_inplace=false
# Parse options
  set -- "$@" # This syntax is needed to keep parameters quoted
  OPTIND=1
  while getopts "b:B:cd:fgiI:lm:snp:q:rt" arg; do
    case $arg in
      b) buildsubdir="$OPTARG";;
      B) buildsubdir="$OPTARG"
         build_inplace=true
         ;;
      c) usecmake=true; cmval=cmake;;
      d) DEPS=$OPTARG;;
      f) forceconfig=true;;
      g) webdocs=true;;
      i) inplace=true;;
      I) instdirs="$OPTARG";;
      l) rminstall=true;;
      m) configcmdin="$OPTARG";;
      s) stripbuilddir=true;;
      n) noequals=true;;
      p) instsubdirval="$OPTARG";;
      q) QMAKE_PRO_FILENAME="$OPTARG"; forceqmake=true;
         cmval=qmake; inplace=true;;
      r) riverbank=true;;
      t) recordfailure=false;;
    esac
  done
  shift $(($OPTIND - 1))

  techo "Determining whether to configure $1-$2."

# Get the version
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`
# Get dependencies if not specified with -d
  local depsvar=`genbashvar $1`_DEPS
  local depsval=`deref $depsvar`
  local DEPS=${DEPS:-"$depsval"}
# Get installation directory.
  local instdirvar=`genbashvar ${1}-${2}`_INSTALL_DIR
# Look for command line definition
  local instdirval=`echo $instdirs | sed 's/,.*$//'`
# Look for build specific definition
  if test -z "$instdirval"; then
    instdirval=`deref $instdirvar`
  fi
# Look for first package specific installation directory
  if test -z "$instdirval"; then
    instdirsvar=`genbashvar ${1}`_INSTALL_DIRS
    instdirval=`deref $instdirsvar | sed 's/,.*$//'`
  fi
# Set from default
  if test -z "$instdirval"; then
    techo -2 "instdirval = $instdirvar is empty in bilderConfig"
    instdirval=$BLDR_INSTALL_DIR
  fi
  eval $instdirvar=$instdirval
  techo "$instdirvar = $instdirval."

#
# See whether should install
#
# Start with assumption of not building
  dobuildval=false
# Cannot build unless this build in BUILDS variable
  local buildsvar=`genbashvar $1`_BUILDS
  local buildsval=`deref $buildsvar`
  if echo $buildsval | egrep -q "(^|,)$2($|,)"; then
# Build if forced
    if $forceconfig; then
      dobuildval=true
    else
      if shouldInstall -I $instdirval $1-$verval $2 $DEPS; then
        dobuildval=true
        techo "Package $1-$verval-$2 is a candidate for configuring since a dependency rebuilt or $1-$verval not installed."
      fi
    fi
  fi
# Store result
  local dobuildvar=`genbashvar $1-$2`_DOBUILD
  eval $dobuildvar=$dobuildval
  local builddirvar=`genbashvar $1-$2`_BUILD_DIR

# If not installed, configure.  If successful, put install string into
# the config file.
  if $dobuildval; then

#
# Determine the installation directory and subdirectory
#
    local instsubdirvar=`genbashvar $1-$2`_INSTALL_SUBDIR
    if test -z "$instsubdirval"; then
      instsubdirval=`deref $instsubdirvar`
    fi
# Variable holding string naming this installation
    if test -z "$instsubdirval"; then
      if test -n "$4"; then
        if ! $webdocs; then
           # The default for installs when 4th argument is passed
           instsubdirval=$4-$verval
        else
           instsubdirval=$4
        fi
      else
        instsubdirval=$1-$verval-$2
      fi
    fi
    eval $instsubdirvar=$instsubdirval
# Do the installation
    if test $instsubdirval != '-'; then
      fullinstalldir=$instdirval/`deref $instsubdirvar`
    else
      fullinstalldir=$instdirval
    fi
    techo -2 Full installation directory is $fullinstalldir.

#
# If unpacked, we know the build directory, up to a subdirectory
# change for qmake.
#
    local unpackedvar=`genbashvar $1`_UNPACKED
    local unpackedval=`deref $unpackedvar`
    local builddir
    if $riverbank; then
      builddir=$BUILD_DIR/$1-$verval
    elif test "$unpackedval" = true && test -n "$buildsubdir"; then
      # This is for petsc where we configure inplace build build out-of-place
      builddir=$BUILD_DIR/$1-$verval
    elif test "$unpackedval" = true; then
      builddir=$BUILD_DIR/$1-$verval/$2
      cmd="mkdir -p $builddir"
      techo "$cmd"
      $cmd
    else
      unset builddir
    fi
    eval $builddirvar=$builddir

# Determine the configuration command and any required args.
# For qmake and jam, this determines the build directory.
#
# configexec: the executable
# configargs: the default args to the executable
# cmval:      string describing the type of configuration (e.g., autotools)
#
    local configexec=
    local configargs=
# Work through the specified, mutually exclusive cases
    if $forceqmake; then
# qmake configure
      configexec=qmake
      cmval=qmake
      if test -d $PROJECT_DIR/$1; then
# From repo
        builddir=`dirname $PROJECT_DIR/$1/$QMAKE_PRO_FILENAME`
      else
# From tarball
        builddir=`dirname $builddir/$QMAKE_PRO_FILENAME`
      fi
      inplace=true
# CMake has configure and CMakeLists but must be configured with configure,
# so that has to go first.
# Do not automatically add $CONFIG_SUPRA_SP_ARG, as does not always apply
    elif $usecmake; then
# cmake configure
      configexec="$CMAKE"
      cmval=cmake
    elif $riverbank; then
# riverbank configure
      configexec=python
      local pspdir=$PYTHON_SITEPKGSDIR
      local cbindir=$CONTRIB_DIR/bin
      if [[ `uname` =~ CYGWIN ]]; then
        pspdir=`cygpath -aw $pspdir`
        cbindir=`cygpath -aw $cbindir`
      fi
      configargs="configure.py --destdir='$pspdir' --bindir='$cbindir'"
      cmval=riverbank
    elif test -n "$configcmdin"; then
# Custom configure executable
      if test -f $builddir/$configcmdin; then
        configexec="$builddir/$configcmdin"
      elif test -f $builddir/../$configcmdin; then
        configexec="$builddir/../$configcmdin"
      fi
      cmval='custom'
    elif test -n "$builddir"; then
# For all unpacked cases, the build directory is known.
      if test -f $builddir/bootstrap.bat; then
# Anything with jam was unpacked, so build directory is known.
        case `uname` in
          CYGWIN*)
            configexec="$builddir/bootstrap.bat"
            chmod u+x $configexec
            ;;
          *)
            configexec="$builddir/bootstrap.sh"
            ;;
        esac
        cmval=b2
        inplace=true
      elif test -f $builddir/../configure; then
# Usual autotools out-of-place build
        configexec="$builddir/../configure"
        configargs="--prefix=$fullinstalldir"
        cmval=autotools
        # If configure is a python script like PETSc, then use the
        # cygwin python.
        if head -1 $configexec | egrep -q python; then
          if test -n "$CYGWIN_PYTHON"; then
            configexec="$CYGWIN_PYTHON $configexec"
          fi
        fi
      elif test -f $builddir/configure; then
# Possible in-place build, e.g., PETSc, doxygen
        configexec="$builddir/configure"
		cmval=autotools
        #This signals PETSc, and on Windows we have issues
        if test -n "$buildsubdir"; then
          if test -n "$CYGWIN_PYTHON"; then
		    cmval=petsc;
          fi
        fi
        if $noequals; then
          configargs="--prefix $fullinstalldir"
        else
          configargs="--prefix=$fullinstalldir"
        fi
      elif test -f $builddir/../CMakeLists.txt; then
# CMake is always out of place
        configexec="$CMAKE"
        cmval=cmake
      elif test -f $builddir/../src/CMakeLists.txt; then
# CMake is always out of place
        configexec="$CMAKE"
        cmval=cmake
      fi
    elif test -f $PROJECT_DIR/$1/configure -a -f $PROJECT_DIR/$1/configure.ac; then
# Repo, autotools
      configexec="$PROJECT_DIR/$1/configure"
      configargs="--prefix=$fullinstalldir"
      cmval=autotools
    elif test -f $PROJECT_DIR/$1/configure; then
# Repo but not configure.ac: Most likely petsc
      configexec="$PROJECT_DIR/$1/configure"
      configargs="--prefix=$fullinstalldir"
      cmval=petsc
      # SEK: I'm not sure this will work on Windows
      if ! test -d $BUILD_DIR/$1; then
            ln -sf $PROJECT_DIR/$1 $BUILD_DIR/$1
      fi
    elif test -f $PROJECT_DIR/$1/CMakeLists.txt; then
# Repo, CMake
      configexec="$CMAKE"
      cmval=cmake
    fi
    if test -z "$configexec"; then
      techo "No configure system found for $1-$2.  Assuming no need."
      return 0
    fi
# Validate presence of config command
    if ! which "$configexec" 1>/dev/null 2>&1; then
      TERMINATE_ERROR_MSG="Catastrophic failure in configuring $1-$2.  Unable to find $configexec.  PATH = $PATH."
      cleanup
    else
      configexec=`which "$configexec"`
    fi
    local cmvar=`genbashvar $1`_CONFIG_METHOD
    eval $cmvar=$cmval
    techo "Configuration of type $cmval."

# Strip the builddir from configcmdin if -s and -m options specified
    if test -n "$configcmdin" && $stripbuilddir; then
      configexec="$configcmdin"
    fi
    if test "$cmval" = petsc; then
      configexec="$CYGWIN_PYTHON '$configexec'"
    fi	
    techo "Will configure with '$configexec'."

#
# Find the build directory if not yet known
#
    if test -z "$builddir"; then
# In place build with qmake
      if $inplace && test -d $PROJECT_DIR/$1; then
# In place build from repo, non qmake
        builddir=$PROJECT_DIR/$1
# For petsc tarballs, the configure is in place but the builds are
# out-of-place
      elif $inplace; then
        local buildtopdir=`getBuildTopdir $1 $verval`
        (cd $buildtopdir; mkdir -p $2) # mkdir -p fails on a link
        techo "HERE where I belong"
        local builddir=$buildtopdir
# In all other cases, build under main dir in builds directory
      else
        local buildtopdir=`getBuildTopdir $1 $verval`
        (cd $buildtopdir; mkdir -p $2) # mkdir -p fails on a link
        local builddir=$buildtopdir/$2
      fi
    fi
# Store build directory
    eval $builddirvar=$builddir
    cmd="cd $builddir"
    techo "$cmd"
    $cmd

#
# Clean out any old build unless requested not to now that builddir
# has been created.
#
    unset cmd
    if test $RM_BUILD; then
      if test "$cmval" = cmake -a "$inplace" = false; then
        cmd="rmall *"
      elif $inplace; then
        if test -f Makefile -a $1 != petsc -a $1 != petscdev -a $1 != slepc; then
          local bildermake=${bildermake:-"`getMaker $cmval`"}
          cmd="$bildermake distclean"
        fi
      elif $riverbank; then
        unset cmd
      else
        cmd="rmall *"
      fi
    fi
    if test -n "$cmd"; then
      if test `\ls | wc -l` -gt 0; then
        chmod -R u+w *
      fi
      techo "$cmd" | tee distclean.out
      if ! $cmd 2>&1 >>distclean.out; then
# For CYGWIN, may need to run twice
        sleep 1
        techo "$cmd" | tee -a distclean.out
        $cmd 2>&1 >>distclean.out
      fi
    fi

#
# Remove previous install if requested and installdir exists
#
    if test -d $fullinstalldir -a "$rminstall" = true; then
      rmall $fullinstalldir
    fi

# Location of source for cmake builds.
    local srcarg=
# Add other, default args
    case $cmval in
      qmake)
        # eval $builddirvar=$builddir
        PRO_FILENAME=`basename $QMAKE_PRO_FILENAME`
        configargs="$configargs $PRO_FILENAME"
        ;;
      cmake)
        case `uname` in
          CYGWIN*)
            cmakeinstdir=`cygpath -am $fullinstalldir`
            ;;
          *)
            cmakeinstdir="$fullinstalldir"
            ;;
        esac
# Some options are always chosen
        configargs="$configargs -DCMAKE_INSTALL_PREFIX:PATH=$cmakeinstdir -DCMAKE_BUILD_TYPE:STRING=$CMAKE_BUILD_TYPE -DCMAKE_COLOR_MAKEFILE:BOOL=FALSE $CMAKE_LIBRARY_PATH_ARG"
	if test $VERBOSITY -ge 1; then
	  configargs="$configargs -DCMAKE_VERBOSE_MAKEFILE:BOOL=TRUE"
        fi
        if test -n "$SVN_BINDIR"; then
          configargs="$configargs -DSVN_BINDIR:PATH='${SVN_BINDIR}'"
        fi
        if test -f $PROJECT_DIR/$1/CMakeLists.txt; then
          srcarg=$PROJECT_DIR/$1
        elif test -f $builddir/../CMakeLists.txt; then
          srcarg=`(cd $builddir/..; pwd -P)`
        elif test -f $builddir/../src/CMakeLists.txt; then
          srcarg=`(cd $builddir/../src; pwd -P)`
        else
          techo "cmake build, but no CMakeLists.txt.  Skipping this build."
          return 1
        fi
        ;;
    esac
# Fix up srcarg for Windows
    techo -2 "srcarg = $srcarg, uname = `uname`"
    sleep 1 # Give cygwin time to catch up.
    case `uname` in
      CYGWIN*)
# Add cygwin root on windows
        if test -n "$srcarg"; then
          if test -d "$srcarg" -a ! -h "$srcarg"; then
            techo -2 "Directory, $srcarg, exists."
          else
# Might not be a repo and have to add version
            techo -2 "Directory, $srcarg, does not exist."
            srcarg=${srcarg}-${verval}
          fi
          srcarg=`cygpath -am ${srcarg}`
        fi
        ;;
    esac
    techo -2 "After Windows fix, srcarg = $srcarg"

# Ready to start configuring
    local configure_txt=$FQMAILHOST-$1-$2-config.txt
    techo "Configuring $1-$2 in $PWD at `date`." | tee $configure_txt
    local finalcmd
    case `uname` in
      CYGWIN*)
        case "$cmval" in
          cmake)
            if which jom 1>/dev/null 2>&1; then
              finalcmd="'$configexec' $configargs -G 'NMake Makefiles JOM' $3 $srcarg"
            else
              finalcmd="'$configexec' $configargs -G 'NMake Makefiles' $3 $srcarg"
            fi
            ;;
          autotools)
            case $1 in
              qt)  # QT is not autotools
                local finalcmd="'$configexec' $configargs $3"
                ;;
              *)  # Actually, this decision should be made by the package
                local finalcmd="'$configexec' $configargs $3"
                ;;
            esac
            ;;
          *)
            local finalcmd="$configexec $configargs $3"
            ;;
        esac
        ;;
      MINGW*)
        case "$configexec" in
          cmake*)
            local finalcmd="'$configexec' $configargs -G 'MSYS Makefiles' $3 $srcarg"
            ;;
          *)
            local finalcmd="'$configexec' $configargs $3 CC=gcc"
            ;;
        esac
        ;;
      *)
        finalcmd="$configexec $configargs $3 $srcarg"
        ;;
    esac

    # finalcmd="$configexec $3 $srcarg"

# Now add the environment variables
    if test -n "$5"; then
      finalcmd="env $5 $finalcmd"
    fi

# Cannot remove the old install automatically, as many packages
# like all the autotools packages, have to be installed in the
# same directory.  Can be done optionally by bilderInstall using
# the -r flag if needed and acceptable.
    # rmall $fullinstalldir
# Store command
    techo "$finalcmd" | tee -a $configure_txt
# Store command in a script
    mkConfigScript $FQMAILHOST $1 $2
# Execute the command
    eval "$finalcmd" 1>>$configure_txt 2>&1
    RESULT=$?
# Save the configuration command
    if test $RESULT = 0; then
      techo "Package $1-$verval-$2 configured at `date`." | tee -a $configure_txt
      echo SUCCESS >>$configure_txt
      configSuccesses="$configSuccesses $1-$2"
    else
      eval $dobuildvar=false
      techo "Package $1-$verval-$2 failed to configure at `date`." | tee -a $configure_txt
      echo FAILURE >>$configure_txt
      if $recordfailure || ! $IGNORE_TEST_RESULTS; then
        configFailures="$configFailures $1-$2"
        anyFailures="$anyFailures $1-$2"
      else
        techo "bilderConfig not recording failures: recordfailure = $recordfailure."
      fi
    fi
    if test -n "$BLDR_PROJECT_URL"; then
      local subdir=`pwd -P | sed "s?^$PROJECT_DIR/??"`
      techo "See $BLDR_PROJECT_URL/$subdir/$configure_txt."
    fi
  else
    techo "Not configuring since $1-$verval-$2 already installed in $instdirval, or $2 not in $buildsvar = $buildsval."
    RESULT=99
  fi

# Finally, if building in a separate place, need to fix that.
  if test -n "$buildsubdir"; then
    if ! $build_inplace; then
      builddir=$builddir/$buildsubdir
      eval $builddirvar=$builddir
      cmd="cd $builddir"
      techo "$cmd"
      $cmd
    fi
  fi

  return $RESULT

}

#
# Add a build to the lists of building packages and pids
#
# Args:
# 1: <pkg>-<build>
# 2: pid
#
addBuildToLists() {
  pidvarname=`genbashvar $1`_PID
  eval $pidvarname=$pid
  PIDLIST="$PIDLIST $2"
  trimvar PIDLIST ' '
  pkgsBuilding="$pkgsBuilding $1"
  trimvar pkgsBuilding ' '
  techo "Build $1 with $pidvarname = $pid launched at `date`."
}

#
# Build a package in a subdir.  Sets the $1_$2_PID variable to allow
# later waiting for completion.
#
# Args:
# 1: package name
# 2: build name = build subdir (note: use "all" for testing)
# 3: (optional) args for the build
# 4: (optional) environment variables for the build
#
# Named args (must come first):
# -k Keep old build, do not make clean
# -m Use instead of make
#
# Return 0 if a build launched
#
bilderBuild() {

# Check to build
  # techo "NOBUILD = $NOBUILD."
  if $NOBUILD; then
    techo "Not building $1-$2, as NOBUILD = $NOBUILD."
    return 0
  fi

# Default option values
  local builddir
  local bildermake
  local makeclean=true
# Parse options
# This syntax is needed to keep parameters quoted
  set -- "$@"
  OPTIND=1
  while getopts "km:" arg; do
    case "$arg" in
      k) makeclean=false;;
      m) bildermake="$OPTARG";;
    esac
  done
  shift $(($OPTIND - 1))

# Additional targets.
  local buildargs="$3"

# Get the version
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`

# Get the build directory
  local builddirvar=`genbashvar $1-$2`_BUILD_DIR
  local builddir=`deref $builddirvar`

# Check that we are building.  Must not be turned off, and last
# result must have been good and configuration file must exist
  local dobuildvar=`genbashvar $1-$2`_DOBUILD
  local dobuildval=`deref $dobuildvar`
# Presence of file enough to know it built.
  if $NOBUILD || ! $dobuildval; then
    techo "Not building $1-$verval-$2."
    techo -2 "NOBUILD = $NOBUILD.  $dobuildvar = $dobuildval."
    return 1
  fi

# Build if so
  if ! $dobuildval; then
    return 1
  fi

  local pidvarname=`genbashvar $1_$2`_PID
# The file that determines whether this has been done
  techo "Building $1 in $builddir."
  cd $builddir
  res=$?
  if test $res != 0; then
    TERMINATE_ERROR_MSG="Catastrophic error in building $1-$2.  Cannot change directory to $builddir."
    cleanup
  fi
  # This needs to match what waitBuild uses
  local bilderbuild_resfile=bilderbuild-$1-$2.res
  rm -f $bilderbuild_resfile

# Determine how to make
  local cmvar=`genbashvar $1`_CONFIG_METHOD
  local cmval=`deref $cmvar`
  bildermake=${bildermake:-"`getMaker $cmval`"}

# Fresh build for case of Fortran and Babel
  if $makeclean; then
    techo "$bildermake clean"
    $bildermake clean 1>/dev/null 2>&1
  fi
# Ignore errors for depend, as some fortran components do not have this.
  techo "$bildermake -i depend"
  $bildermake -i depend 1>depend.txt 2>&1

# make all
  local envprefix=
  if test -n "$4"; then
    envprefix="env $4"
  fi
  local mktarg
  case `uname` in
    CYGWIN*)
      if test "$cmval" = qmake; then
        mktarg=release
      fi
      ;;
  esac
  local buildscript=$FQMAILHOST-$1-$2-build.sh
  echo '#!/bin/bash' >$buildscript
  if test -n "$envprefix"; then
    echo -n "$envprefix " | tee -a $buildscript
  fi
  echo "$bildermake $mktarg $buildargs" | tee -a $buildscript
  echo 'res=$?' >>$buildscript
  echo "echo Build of $1-$2 completed with result = "'$res.' >>$buildscript
  echo 'echo $res >'$bilderbuild_resfile >>$buildscript
  echo 'exit $res' >>$buildscript
  chmod ug+x $buildscript
  local build_txt=$FQMAILHOST-$1-$2-build.txt
  techo "Building $1-$2 in $PWD using $buildscript at `date`." | tee $build_txt
  techo "$buildscript" | tee -a $build_txt
  # cat $buildscript | tee -a $build_txt | tee -a $LOGFILE
  techo "$envprefix $bildermake $mktarg $buildargs" | tee -a $build_txt
  ./$buildscript >>$build_txt 2>&1 &
  pid=$!
  if test -z "$pid"; then
    techo "WARNING: pid not known.  Something bad happened."
    return 1
  fi
# Record build
  addBuildToLists $1-$2 $pid
  if test -n "$BLDR_PROJECT_URL"; then
    local subdir=`pwd -P | sed "s?^$PROJECT_DIR/??"`
    techo "See $BLDR_PROJECT_URL/$subdir/$build_txt."
  fi
  return 0

}

#
# Wait for a package to complete building in a subdir
#
# Args:
# 1: Either <pkg>-<build> or <pkg>
#    The former is used by bilderBuild, the latter by bilderDuBuild
#
# Named args:
# n: Do not record failure
# t: Actually a test, so a build failure is actually a test failure.
#    do not record in anyFailures if $IGNORE_TEST_RESULTS = true
#
# Returns result if built, otherwise 99
#
waitBuild() {

# Default option values
  local istest=false
  local recordfailure=true
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "nt" arg; do
    case $arg in
      n) recordfailure=false;;
      t) istest=true;;
    esac
  done
  shift $(($OPTIND - 1))

# Check to see whether was built
  local pidvarname=`genbashvar $1`_PID
  local pid=`deref $pidvarname`
  local resvarname=`genbashvar $1`_RES
  local res=`deref $resvarname`
# If res not empty this already done.
  local build_txt=$FQMAILHOST-$1-build.txt
  local firstwait=false

# Wait on test and process according to result
  if test -n "$pid"; then
# To collect build, pid must be nonempty so that we know build was launched,

    techo "Waiting on process $pidvarname = $pid."
    firstwait=true
    wait $pid
    res=$?
    eval $resvarname=$res
    techo "Build $1 with $pidvarname = $pid concluded at `date` with result = $res."

# Remove from PIDLIST and pkgsBuilding
    PIDLIST=`echo $PIDLIST | sed -e "s/^$pid //" -e "s/ $pid$//" -e "s/ $pid / /" -e "s/^$pid$//"`
    pkgsBuilding=`echo $pkgsBuilding | sed -e "s/^$1 //" -e "s/ $1$//" -e "s/ $1 / /" -e "s/^$1$//"`

# Determine build directory
    local builddirvar=`genbashvar $1`_BUILD_DIR
    local builddir=`deref $builddirvar`
    if test -z "$builddir"; then
      local vervar=`genbashvar $1`_BLDRVERSION
      local verval=`deref $vervar`
      if test -d $BUILD_DIR/$1-$verval; then
        builddir=$BUILD_DIR/$1-$verval
      fi
    fi

# Ensure that the build produced a result
    local bilderbuild_resfile=bilderbuild-$1.res
    if test -n "$builddir"; then
      newres=`cat $builddir/$bilderbuild_resfile`
      if test -z "$newres"; then
        TERMINATE_ERROR_MSG="Catastropic failure in waitBuild.  No result in $builddir/$bilderbuild_resfile."
        cleanup
      fi
# Check for inconsistency of wait return value and build result and correct
      if test $res = $newres; then
        techo "Recorded build result is $newres.  Consistent."
      else
        techo "Recorded build result is $newres.  Inconsistent.  Using $newres."
        res=$newres
        eval $resvarname=$res
      fi
    else
      techo "Directory $builddirvar is empty, so cannot check $bilderbuild_resfile."
    fi

# Record SUCCESS only first time we have waited.
    if test -s $builddir/$build_txt; then
      if test $res = 0; then
        if $istest; then
# Why is this now needed?
          if ! echo "$testSuccesses" | egrep -q "(^| )$1($| )"; then
            testSuccesses="$testSuccesses $1"
          fi
        else
# Why is this now needed?
          if ! echo "$buildSuccesses" | egrep -q "(^| )$1($| )"; then
            buildSuccesses="$buildSuccesses $1"
          fi
        fi
        echo SUCCESS >>$builddir/$build_txt
      else
        echo FAILURE >>$builddir/$build_txt
      fi
    else
      techo "waitBuild: Can not find $builddir/$build_txt to record result of $res."
    fi

# Record failure if appropriate
    if test $res = 0; then
      techo "Package $1 built."
    else
      techo "Package $1 failed to build."
      if $recordfailure; then
        if $istest; then
          if ! echo "$testFailures " | egrep -q "(^| )$1($| )"; then
            techo "Package $1 failure recorded as a test failure."
            testFailures="$testFailures $1"
            if ! $IGNORE_TEST_RESULTS; then
              anyFailures="$anyFailures $1"
            fi
          fi
        else
          if ! echo "$buildFailures " | egrep -q "(^| )$1($| )"; then
            techo "Package $1 failure recorded as a build failure."
            buildFailures="$buildFailures $1"
            anyFailures="$anyFailures $1"
          fi
        fi
      fi
    fi

# Print URL
    if test -n "$BLDR_PROJECT_URL"; then
      local subdir=`echo $builddir | sed "s?^$PROJECT_DIR/??"`
      techo "See $BLDR_PROJECT_URL/$subdir/$build_txt."
    fi

  fi

# Check for not built
  if test -z "$res"; then
    techo "No pid or result for $1, so assume not built."
    res=99
  fi
  eval $resvarname=$res
  return $res

}

# Set the force tests variable for a given package to be tested
#
# Args
# 1: Package being tested
#
getForceTests() {
  local pkgname=$1
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`
  local bldsvar=`genbashvar $1`_BUILDS
  local bldsval=`deref $bldsvar`
  techo "Checking for installation of $1-$verval for builds, $bldsval." 1>&2
  if ! areAllInstalled $1-$verval $bldsval 1>&2; then
    techo "Not all builds of $1-$verval are installed." 1>&2
    if ! echo "$anyFailures" | egrep -q "(^| )$pkgname($| )"; then
      techo "$pkgname not found in anyFailures." 1>&2
      echo '-f'
    fi
  fi
}

#
# Run tests for a particular package, if builds succeeded.
#
# Args:
# 1: package name (e.g., vorpal)
# 2: name of tests methods (e.g., VpTest)
# Named args (must come first)
#
# -i comma-separated list of build(s) to ignore when deciding to run tests
#    (documentation generating builds always ignored.)
# -v getversion will get version of package, not tests method.  This is useful
# for cases when the tests are stored within the package repo.
# Returns result if built, otherwise 99
#
bilderRunTests() {

# Default option values
# Always ignore the document generating builds.  See README-docs.txt.
  local ignoreBuilds=develdocs
  local usepkgver=false
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "i:v" arg; do
    case $arg in
      i) ignoreBuilds="$OPTARG";;
      v) usepkgver=true;;
    esac
  done
  shift $(($OPTIND - 1))

# Initial handling
  local pkgname=$1
  if test -n "$ignoreBuilds"; then
    techo "bilderRunTests is ignoring '$ignoreBuilds' builds of $pkgname."
  else
    techo "bilderRunTests is not ignoring any builds of $pkgname."
  fi
  local tstsname=`echo $2 | tr 'A-Z.-' 'a-z__'`

# In some cases, the tests are not in their own repo but are part of
# a larger repo.  Assign the pkg version to the tests.
  if $usepkgver; then
    getVersion $pkgname # In this case, no separate repo for tests.
    local verpkgvar=`genbashvar ${pkgname}`_BLDRVERSION
    local vertstsvar=`genbashvar ${tstsname}`_BLDRVERSION
    eval $vertstsvar=`deref $verpkgvar`
  else
    getVersion $tstsname  # Done here as build may not be called
  fi
# If not testing, done.
  if ! $TESTING; then
    techo "Not testing $pkgname."
    return
  fi

# Get the builds to wait on
  local buildsvar=`genbashvar $1`_BUILDS
  local buildsval=`deref $buildsvar`
  local testedBuilds=
# Remove ignored builds
  for bld in `echo $buildsval | tr ',' ' '`; do
    if echo $ignoreBuilds | egrep -qv "(^|,)$bld($|,)"; then
      testedBuilds=$testedBuilds,$bld
    fi
  done
  trimvar testedBuilds ','
  techo "bilderRunTests is waiting on $testedBuilds builds of $pkgname."

# Wait on all builds, see if any tested build failed
  local tbFailures=
  for i in `echo $testedBuilds | tr ',' ' '`; do
    cmd="waitBuild $pkgname-$i"
    techo "$cmd"
    $cmd
    res=$?
    if test $res != 0 && echo $i | egrep -qv "(^|,)$I($|,)"; then
      tbFailures="$tbFailures $i"
    fi
  done
  trimvar tbFailures ' '

# Source test file here even if not needed, as later will call install
  if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/$tstsname.sh; then
    source $BILDER_CONFDIR/packages/$tstsname.sh
  elif test -f $BILDER_DIR/packages/$tstsname.sh; then
    source $BILDER_DIR/packages/$tstsname.sh
  else
    techo "Test package file $tstsname.sh not found."
  fi


# The var $FOOTESTS_RUN is used to indicate whether or not we are running
# footests or whether they were skipped.
  # local runvar=`genbashvar $2`_RUN
  # eval $runvar=false
  if test -n "$tbFailures"; then
    techo "Not running $pkgname tests. Failure of or to build: $tbFailures."
# If not building, then still need version
    return
  fi
  techo "Testing $pkgname."
  # eval $runvar=true
# Build the tests.  They should always be run, as this is called only
# when all builds completed successfully.
  cmd="build$2"
  techo "$cmd"
  $cmd

}

#
# Wait on the completion of a run of tests.  Set result variable
# according to whether tests passed.
#
# Args:
# 1: Name of tests, e.g., vptests
# 2: Name of subject file to look for, e.g., vorpal-txtest.subj
#
# Named args (must come first):
# None
#
# Return true if installed
#
waitTests() {

# Inputs
  tstsnm=$1
  subjfn=$2

# Wait on tests
  cmd="waitBuild -t $tstsnm-all"
  techo "$cmd"
  $cmd
  local res=$?
  techo "$cmd completed with result = $res."

# Store in global variable and return value
  local tstsresvar=`genbashvar $tstsnm`_ALL_RES
  eval $tstsresvar=$res
  local tstsresval=`deref $tstsresvar`
  return $res

}

#
# Determine whether a tested package should be installed
#
# Args:
# 1: Name of tested package, e.g., vorpal
# 2: Name of tests in methods, e.g., VpTests
#
# Named args (must come first):
# -n <tests>   Name of tests if not found from lower-casing $1
#
# Return true if should be installed
#
shouldInstallTestedPkg() {
  techo -2 "shouldInstallTestedPkg called."

# Get options
  local tstsnm=
  while test -n "$1"; do
    case "$1" in
      -n)
        tstsnm=$2
        shift
        ;;
      *)
        break
        ;;
    esac
    shift
  done

# Get package and name of test file
  local pkgname=$1
  local tstsnm=${tstsnm:-"`echo $2 | tr 'A-Z' 'a-z'`"}

# Determine whether to install
  techo "shouldInstallTestedPkg is determining whether to install tested package $pkgname."
  local installPkg=false
  if $TESTING; then

# If tests not run, do not install
    tstspidvar=`genbashvar $2`_ALL_PID
    tstspidval=`deref $tstspidvar`
    local tstsresval=
    if ! $IGNORE_TEST_RESULTS && test -z "$tstspidval"; then
      techo "Test $tstsnm not run.  No installations to do."
      tstsresval=99
      return $tstsresval
    fi

# Determine results of installation/waitTests
    local instcmd="install${2}"
    techo "$instcmd"
    ${instcmd}
    local tstsresvar=`genbashvar $2`_ALL_RES
    tstsresval=`deref $tstsresvar`

    case $tstsresval in
      0)
# If we got here, the tests were run successfully
        techo "Test $tstsnm succeeded.  Installing $pkgname."
        return 0
        ;;
      99)
# If we got here, the tests were not run, but package was built.
        techo "Test $tstsnm not run."
        if $IGNORE_TEST_RESULTS; then
          techo "Ignoring and installing $pkgname."
          return 0
        fi
        techo "Not installing $pkgname."
        return 99
        ;;
      *)
        techo "$tstsnm failed."
        if $IGNORE_TEST_RESULTS; then
          techo "Ignoring results and installing ${pkgname}."
          return 0
        fi
        techo "Not installing ${pkgname} or its tests."
        return 1
        ;;
    esac
  fi
# Not testing
  techo "Not testing $pkgname so installing."
  return 0

}

#
# Record an installation
#
# Args:
# 1: installation directory
# 2: package name
# 3: version
# 4: build name
#
recordInstallation() {
  local installstrval=$2-$3-$4
  local pkgScriptVerVar=`genbashvar $2`_PKGSCRIPT_VERSION
  local pkgScriptVerVal=`deref $pkgScriptVerVar`
  if test -z "$pkgScriptVerVal"; then
    : # Get version
  fi
  local proj=${BILDER_PACKAGE:-"unknown"}
  local record="$installstrval $USER $proj `date +%F-%T` bilder-r$pkgScriptVerVal"
  techo "Recording installation, '$record'."
  echo "$record" >> $1/installations.txt
  installations="$installations $2-$4"
}


#
# Wait for a package to complete building in a subdir, then install it.
#
# Args:
# 1: package name
# 2: build name
# 3: (optional) name to link installation subdir to
# 4: (optional) args for make install
# 5: (optional) environment variables
#
# Named args (must come first):
# -a accept build was correct
# -c directly copy build dir to install dir
# -f force the installation
# -g webdocs
# -m use the arg instead of make
# -L do not create links
# -n do not record the installation
# -p perms Set the permissions (open or closed)
# -r remove the old installation
# -s the name of the installer subdir at the depot
# -t is a test, so call waitTest
#
# Return whether installed
#
bilderInstall() {

# Default option values
  local acceptbuild=false
  local altbuilddir=false
  local builddir=
  local forceinstall=$FORCE_INSTALL
  local doLinks=true
  local bildermake=
  local cpdir=false
  local recordinstall=true
  local perms=
  local removesame=false
  local webdocs=false
  local installersubdir=
  local istest=false
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "ab:cfgLm:np:rs:t" arg; do
    case $arg in
      a) acceptbuild=true;;
      b) builddir="$OPTARG"; altbuilddir=true;;
      c) cpdir=true;;
      f) forceinstall=true;;
      g) webdocs=true;;
      L) doLinks=false;;
      m) bildermake="$OPTARG";;
      n) recordinstall=false;;
      p) perms="$OPTARG";;
      r) removesame=true;;
      s) installersubdir="$OPTARG";;
      t) istest=true;;
    esac
  done
  shift $(($OPTIND - 1))
  local envvars="$5"

# If there was a build, the builddir was set
  if ! $altbuilddir; then
    local builddirvar=`genbashvar $1-$2`_BUILD_DIR
    local builddir=`deref $builddirvar`
  fi
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`
  if test -z "$builddir"; then
    techo "Not installing $1-$verval-$2 since not built."
    return 1
  fi
  local res
  if $acceptbuild; then
    res=0
    techo "Package $1-$verval-$2 build was accepted before."
  else
    if $istest; then
      waitTests $1
    else
      waitBuild $1-$2
    fi
    resvarname=`genbashvar $1_$2`_RES
    res=`deref $resvarname`
    if test "$res" != 0; then
      techo "Not installing $1-$verval-$2 since did not build."
      return 1
    fi
    techo "Package $1-$verval-$2 was built."
  fi

#
# If here, ready to install.  Determine whether to do so.
#
  if $forceinstall; then
    doinstall=true
  else
    case $verval in
      *:*)
        doinstall=false
        RESULT=1
        techo "WARNING: Not installing $1-$verval-$2 as version contains a colon, so not a pure svn version."
        builtNotInstalled="$builtNotInstalled $1-$2"
        ;;
      r[0-9][0-9]*-[0-9][0-9]*)
        doinstall=false
        RESULT=1
        techo "WARNING: Not installing $1-$verval-$2 as version contains a dash, so not a pure svn version."
        builtNotInstalled="$builtNotInstalled $1-$2"
        ;;
      *M)
        doinstall=false
        RESULT=1
        techo "WARNING: Not installing $1-$verval-$2 as version ends with M, so a modification to an svn version."
        builtNotInstalled="$builtNotInstalled $1-$2"
        ;;
      *)
        doinstall=true
        techo "Proceeding to install."
        ;;
    esac
  fi

#
# Install.
#
  if $doinstall; then
# Validation
    if test -z "$builddir" || ! cd $builddir; then
      TERMINATE_ERROR_MSG="Catastrophic error in bilderInstall.  builddir unknown or cannot cd to $builddir."
      cleanup
    fi

# Determine where it will be installed
    local instdirvar=`genbashvar $1-$2`_INSTALL_DIR
    techo -2 instdirvar = $instdirvar
    local instdirval=`deref $instdirvar`
    if test -z "$instdirval"; then
      TERMINATE_ERROR_MSG="Catastrophic error in bilderInstall.  $instdirvar is empty."
      cleanup
    fi
    instsubdirvar=`genbashvar $1-$2`_INSTALL_SUBDIR
    instsubdirval=`deref $instsubdirvar`
# Attempts to find base name for the link using the known installation subdir
# and version.
    # techo "instsubdirval = $instsubdirval."
    if test -n "$instsubdirval"; then
      if test -n "$verval" && echo $instsubdirval | grep -q -- "-${verval}-"; then
        instsubdirbase=`echo $instsubdirval | sed -e "s/-${verval}.*$//"`
      else
        instsubdirbase=`echo $instsubdirval | sed -e "s/-${2}\$//" -e 's/-[^-]*$//'`
      fi
    else
      instsubdirbase=$1
      if test -d $instdirval/$1-$verval-$2; then
        instsubdirval=$1-$verval
      elif test -d $instdirval/$1-$verval; then
        instsubdirval=$1-$verval-$2
      fi
    fi
    # techo "instsubdirbase = $instsubdirbase."
# Disable testing $instsubdirbase for '-' as autotools packages will not
# install with this restriction.
# However, there will be issues with using cleaninstalls.sh.
# Uncomment code or remove completely when a better solution is found.
#    if echo $instsubdirbase | grep -q -- -; then
#      techo "WARNING: Installation subdirbase may not contain -.  Will not install."
#      return 1
#    fi
    techo "Installing $1-$verval-$2 into $instdirval/$instsubdirval at `date` from $builddir."
    if echo $instsubdirval | grep -q /; then
      techo "WARNING: Installation subdir may not contain /.  Will not make links or shortcuts."
      doLinks=false
    fi
# Set link name
    local linkname
    if test -n "$3"; then
      linkname=$3
    else
      if test -n "$2" -a "$2" != ser; then
        linkname=${instsubdirbase}-$2
      else
        linkname=$instsubdirbase
      fi
    fi
    if [[ "$linkname" =~ tests-all ]]; then # Do not link test results.
      techo "Not linking non existent tests installation directory."
      doLinks=false
    fi

# Remove old installation if requested
    if $removesame; then
      if test -d $instdirval/$instsubdirval; then
        # chmod -R u+w $instdirval/$instsubdirval
        cmd="find $instdirval/$instsubdirval -user $USER -exec chmod u+w  '{}' \;"
        techo "$cmd"
        eval "$cmd"
        cmd="rmall $instdirval/$instsubdirval"
        techo "$cmd"
        $cmd
      fi
    else
      techo "Not removing old installation."
    fi

# Construct installation command
    local cmvar=`genbashvar $1`_CONFIG_METHOD
    local cmval=`deref $cmvar`
    bildermake=${bildermake:-"`getMaker $cmval`"}
    techo "Package $1 was configured with $cmval."
    if test "$cmval" = cmake; then
      envvars="$envvars CMAKE_INSTALL_ALWAYS=1"
      trimvar envvars ' '
    fi

# Determine the installation target.  Defined, then to defaults per system.
# This could get rid of the -g arg?
    local insttargvar=`genbashvar $1-$2`_INSTALL_TARGET
    local insttarg=`deref $insttargvar`
    if test -z "$insttarg"; then
      if [[ `uname` =~ CYGWIN ]] && test "$cmval" = qmake; then
        insttarg=${insttarg:-"release-install"}
      else
        insttarg=${insttarg:-"install"}
      fi
    fi

# Complete the command
    if $webdocs; then
      cmd="$bildermake $4"
    else
      if $cpdir; then
# Perform a direct copy of the build dir to the install dir
# no make install performed.
        cmd="\cp -R $builddir $instdirval/$instsubdirval"
      else
        cmd="$bildermake $4 $insttarg"
      fi
    fi

# Add environment
    if test -n "$envvars"; then
      cmd="env $envvars $cmd"
    fi

# Set umask, install, restore umask
    local umaskvar=`genbashvar $1`_UMASK
    local umaskval=`deref $umaskvar`
    if test -z "$umaskval"; then
      TERMINATE_ERROR_MSG="Catastrophic error in bilderInstall.  $umaskvar not set."
      cleanup
    fi
    local origumask=`umask`
    umask $umaskval

# Create installation script, as gets env correct when there are spaces
    local installscript=$FQMAILHOST-$1-$2-install.sh
    techo "Creating installation script, $installscript, for command, \"$cmd\"."
    cat >$installscript << EOF
#!/bin/bash
echo '$cmd'
$cmd
res=\$?
echo Installation of $1-$2 completed with result = \$res.
echo \$res >bilderinstall.res
exit \$res
EOF
    chmod ug+x $installscript
# Use the installation script
    install_txt=$FQMAILHOST-$1-$2-install.txt
    techo "Installing $1-$2 in $PWD using $installscript at `date`." | tee $install_txt
    techo "$installscript" | tee -a $install_txt
    ./$installscript >>$install_txt 2>&1
    RESULT=$?

# If installed, record
    techo "Installation of $1-$verval-$2 concluded at `date` with result = $RESULT."
    if test $RESULT = 0; then
      echo SUCCESS >>$install_txt

# Set the permissions
      case "$perms" in
          open) setOpenPerms $instdirval/$instsubdirval;;
        closed) setClosedPerms $instdirval/$instsubdirval;;
      esac

# Record installation in installation directory
      if $recordinstall; then
        recordInstallation $instdirval $1 $verval $2
if false; then
        local installstrval=$1-$verval-$2
 	local pkgScriptVerVar=`genbashvar $1`_PKGSCRIPT_VERSION
	local pkgScriptVerVal=`deref $pkgScriptVerVar`
        local record="$installstrval $USER $BILDER_PACKAGE `date +%F-%T` bilder-r$pkgScriptVerVal"
        techo "Recording installation, '$record'."
        echo "$record" >> $instdirval/installations.txt
        installations="$installations $1-$2"
fi
      else
        techo "Not recording installation of $1-$verval-$2."
      fi

# Install any patch
      local patchvar=`genbashvar $1`_PATCH
      local patchval=`deref $patchvar`
      if test -n "$patchval"; then
        patchname=`basename $patchval`
        cmd="/usr/bin/install -m 664 $patchval $instdirval/$instsubdirval/$patchname"
        techo "$cmd"
        $cmd
      fi

# Link to common name
      if test -n "$linkname" -a $instsubdirval != '-'; then
# Do not try to link if install directory does not exist,
# as when qmake installs somewhere else
        if $doLinks; then
          if test -d "$instdirval/$instsubdirval"; then
            techo "Linking $instdirval/$instsubdirval to $instdirval/$linkname."
            mkLink $linkargs $instdirval $instsubdirval $linkname
          else
            techo "WARNING: Not linking $instdirval/$instsubdirval to $instdirval/$linkname because $instdirval/$instsubdirval can not be found."
          fi
        fi
      else
        techo "Not making an installation link."
      fi

# Fix perms that libtool sometimes botches
# subdir may not exist if installed at top
      if test -d "$instdirval/$instsubdirval"; then
        case $umaskval in
          000? | 00? | ?)  # printing format can vary.
            # chmod -R g+wX $instdirval/$instsubdirval
# For case where directories end up not being owned by installer
            find $instdirval/$instsubdirval -user $USER -exec chmod g+wX '{}' \;
            ;;
        esac
        case $umaskval in
          0002 | 002 | 2)
            # chmod -R o+rX $instdirval/$instsubdirval
# For case where directories end up not being owned by installer
            find $instdirval/$instsubdirval -user $USER -exec chmod o+rX '{}' \;
            ;;
        esac
      fi

# If disable-shared, remove any .la files, as these can contain dependency
# libs from the Cray compiler wrappers that are wrong for the final static link
      local configscript=`ls *-config.sh 2>/dev/null`
      if test -n "$configscript"; then
        techo "Found $configscript."
        if grep -q disable-shared $configscript; then
          cmd="find $instdirval/$instsubdirval -name 'lib*.la' -delete"
          techo "$cmd"
          $cmd
        fi
      else
        techo "WARNING: Configure script not found."
      fi

# Remove old installations.
# Add -r to deal with '-' being in name of another package.
# Assumes installation by svn revision.
      allinstalls=`(cd $instdirval; \ls -d $instsubdirbase-r* 2>/dev/null)`
      if test -n "$allinstalls"; then
        techo -2 "All installations are $allinstalls"
        if $REMOVE_OLD; then
          for i in $allinstalls; do
            isCurrent=`echo $i | grep $verval`
            if test -n "$isCurrent"; then
              continue
            fi
            if test $i != "$linkname" -a ! -h $instdirval/$i; then
              # echo rmall $instdirval/$i
              # rmall $instdirval/$i
              runnrExec "rmall $instdirval/$i"
            fi
          done
        fi
      else
        techo "No existing installations."
      fi

# Record build time
      techo "Package $1-$2 installed."
      local starttimevar=`genbashvar $1`_START_TIME
      local starttimeval=`deref $starttimevar`
      techo -2 "$starttimevar = $starttimeval"
      local endtimeval=`date +%s`
      local buildtime=`expr $endtimeval - $starttimeval`
      techo "Package $1-$2 took `myTime $buildtime` to build and install." | tee -a $BILDER_LOGDIR/timers.txt

# Copy the package/installer to the depot dir
      if test -n "$installersubdir"; then
        if $POST2DEPOT; then
          techo "Copying package to the depot."
          local installer=
          local installername=
# Assuming installersubdir is the first part of the name of the package
# depotdir does not need subdirs as packages are namespaced
          installerbase=`echo $installersubdir | sed -e 's?^.*/??'`
          local ending=
          local OS=`uname`

          case $OS in
            CYGWIN*WOW64*) endings="-win_x64.exe -win_x64.zip";;
            CYGWIN*) endings="-win_x86.exe -win_x86.zip";;
            Darwin) endings=-Darwin.dmg;;
            Linux) endings='-Linux-*.tar.gz';;
          esac

          local sfx=
          for ending in $endings; do
            installer=`(shopt -s nocaseglob; \ls ${installerbase}-*${ending} 2>/dev/null)`
            if test -z "$installer"; then
              installer=`(shopt -s nocaseglob; \ls ${installerbase}*${ending} 2>/dev/null)`
            fi
            if test -n "$installer"; then
              sfx=`echo $ending | sed 's/^[^\.]*\.//'`
              break
            fi
          done

          installerVersion=`basename $installer | sed -e 's/[^-]*-//' -e 's/-.*$//'`
          local depotdir=$INSTALLER_ROOTDIR/$installersubdir/$installerVersion
          cmd="ssh ${INSTALLER_HOST} ls ${depotdir}"
          if ! $cmd 1>/dev/null 2>&1; then
            cmd="ssh ${INSTALLER_HOST} mkdir ${depotdir}"
            $cmd 1>/dev/null 2>&1
            cmd="ssh ${INSTALLER_HOST} chmod 775 ${depotdir}"
            $cmd 1>/dev/null 2>&1
            cmd="ssh ${INSTALLER_HOST} ls ${depotdir}"
            if ! $cmd 1>/dev/null 2>&1; then
              techo "WARNING: For depot copy, failed to make target directory '${depotdir}' on host '${INSTALLER_HOST}'."
              depotdir=$INSTALLER_ROOTDIR/$installersubdir
              techo "WARNING: For depot copy, falling back to target directory '${depotdir}'."
            else
              techo "For depot copy, made new target directory '${depotdir}' on host '${INSTALLER_HOST}."
            fi
          else
            techo "For depot copy, target directory '${depotdir}' exists on host '${INSTALLER_HOST}'."
          fi

          installername=`basename $installer .${sfx}`-${UQMAILHOST}.${sfx}
          if test -n "$installer"; then
            cmd="scp -v $installer ${INSTALLER_HOST}:${depotdir}/${installername}"
            techo "$cmd"
            if $cmd 1>/dev/null 2>./error; then
              local perms=
              case $umaskval in
                *7)
                  perms=g+w,o-wrx
                  ;;
                *)
                  perms=g+w,o+w
                  ;;
              esac
              cmd="ssh ${INSTALLER_HOST} chmod $perms ${depotdir}/${installername}"
              techo "$cmd"
              $cmd
            else
              techo "WARNING: '$cmd' failed: `cat ./error`"
              rm ./error
            fi
          else
            techo "WARNING: $1 installer not found."
          fi
        else
          for i in INSTALLER_HOST INSTALLER_ROOTDIR; do
	    val=`deref $i`
            techo "$i = $val."
          done
        fi
      else
        techo "installersubdir not set.  No installer to copy to depot."
      fi
    else
      installFailures="$installFailures $1-$2"
      anyFailures="$anyFailures $1-$2"
      techo "Package $1-$2 failed to install."
      echo FAILURE >>$install_txt
    fi
    if test -n "$BLDR_PROJECT_URL"; then
      local subdir=`pwd -P | sed "s?^$PROJECT_DIR/??"`
      techo "See $BLDR_PROJECT_URL/$subdir/$install_txt."
    fi
# umask restoration here so that links and installations.txt okay
    umask $origumask
  fi

  return $RESULT
}

#
# Determine whether a tested package should be installed
#
# Args:
# 1: Name of tested package, e.g., vorpal
# 2: Name of tests in methods, e.g., VpTests
#
# Named args (must come first):
# -i ignore these builds when calling install, comma-separated list
# -n <tests>   Name of tests if not found from lower-casing $2
# -p <perms>   Type of permissions to set (open or closed)
# -r remove the old installation before installing anew
# -s the name of the installer subdir at the depot, passed through to bilderInstall
# -t do not install test pkg
#
# Return true if should be installed
#
bilderInstallTestedPkg() {

  techo -2 "bilderInstallTestedPkg called with args: '$*'."

# Default option values
  local ignorebuilds=
  local tstsnm=
  local perms=
  local installsubdir=
  local notestinstall=true
  local removePkg=false
  local removearg=
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "i:n:p:rs:t" arg; do
    case $arg in
      i) ignorebuilds=$OPTARG;;
      n) tstsnm="$OPTARG";;
      p) perms="$OPTARG";;
      r) removePkg=true; removearg=-r;;
      s) installsubdir="$OPTARG";;
      t) notestinstall=false;;
    esac
  done
  shift $(($OPTIND - 1))

# Determine args for shouldInstallTestedPkg
  if test -z "$tstnm"; then
    tstsnm=`echo $2 | tr 'A-Z' 'a-z'`
  fi
  local tstnmarg=
  if test -n "$tstsnm"; then
    tstnmarg="-n $tstsnm"
  else
    techo "WARNING: in bilderInstallTestedPkg, No separate test name known."
  fi
  local permsarg=
  if test -n "$perms"; then
    permsarg="-p $perms"
  fi
  local subdirarg=
  if test -n "$installsubdir"; then
    subdirarg="-s $installsubdir"
  fi

# Determine the full list of builds (ignored builds will be removed later)
  local bldsvar=`genbashvar $1`_BUILDS
  local bldsval=`deref $bldsvar | tr ',' ' '`
  techo "$bldsvar = $bldsval."

# Check if should install based on tests passing, and if so then go ahead
# and install all builds (except the ignored builds) as well as the tests.
  if test -n "$bldsval" && shouldInstallTestedPkg $tstnmarg $1 $2; then
    if test -n "$ignorebuilds"; then
      for i in `echo $ignorebuilds | tr ',' ' '`; do
        bldsval=`echo $bldsval | sed -e "s/$i//"`
      done
    fi

    local vervar=`genbashvar $1`_BLDRVERSION
    local verval=`deref $vervar`
    for bld in $bldsval; do
      cmd="bilderInstall $removearg $permsarg $subdirarg $1 $bld"
      techo "$cmd"
      $cmd
    done
    if $notestinstall; then
      bilderInstall $removearg -t $tstsnm all
      techo "Calling bilderInstall for $bldsval and $tstsnm. (bilderInstallTestedPkg)"
    else
      techo "Calling bilderInstall for $bldsval. (bilderInstallTestedPkg)"
    fi
    return 0
  fi

# If not already returned at this point then pkg should not be (and was not) isntalled
  techo "Not calling bilderInstall for builds and tests of $1. (bilderInstallTestedPkg)"
  return 1
}

#
# Build a distutils packages.
# Sets ${1}_INSTALL_DIR to $CONTRIB_DIR if not set.
#
# Args:
# 1: package name
# 2: configuration arguments except for prefix
# 3: Environment under which to run setup.py
#
# Named args (must come first):
# -d <dependencies>
# -p <package name>, needed if different from tarball base name
#
bilderDuBuild() {

  if $NOBUILD; then
    return 0
  fi

# Record start time
  local starttimevar=`genbashvar $1`_START_TIME
  local starttimeval=`date +%s`
  eval $starttimevar=$starttimeval

# Default option values
  local dupkg=
  local DEPS=
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "d:p:" arg; do
    case $arg in
      d) DEPS=$OPTARG;;
      p) dupkg=$OPTARG;;
    esac
  done
  shift $(($OPTIND - 1))

# Set non set options
  if test -z "$dupkg"; then
    dupkg=$1
  fi
  if test -z "$DEPS"; then
    local depsvar=`genbashvar $1`_DEPS
    DEPS=`deref $depsvar`
  fi

# Bassi has a hard time with empty strings as args
  if test "$2" = '-'; then
    unset buildargs
  else
    buildargs=$2
  fi

# Get desired version
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`
# If not defined, look for standard and experimental versions
  if test -z "$verval"; then
    local vervar1=
    if $BUILD_EXPERIMENTAL; then
      vervar1=`genbashvar $1`_BLDRVERSION_EXP
    else
      vervar1=`genbashvar $1`_BLDRVERSION_STD
    fi
    verval=`deref $vervar1`
    eval $vervar=$verval
  fi
  if test -z "$verval"; then
    techo "$vervar not defined.  Cannot build."
    return 1
  fi

# See if module can be imported
  local doBuild=false
  local duversion=`python -c "import $dupkg; print $dupkg.__version__" 2>/dev/null`
  if test -n "$duversion"; then
    techo "Distutils package $dupkg has version = $duversion"
    if test $verval != $duversion; then
      doBuild=true
      techo "Different version so will install."
    fi
  else
    techo "Distutils package $dupkg does not have __version__.  Treat as not installed."
    doBuild=true
  fi
  techo -2 "doBuild = $doBuild"

# See whether installation forced
  if test -z "$FORCE_PYINSTALL"; then
    FORCE_PYINSTALL=false
  fi
  if $FORCE_PYINSTALL; then
    doBuild=true
  fi

# Get installation directory.  Should be set above.
  local instdirvar=`genbashvar $1`_INSTALL_DIR
  local instdirval=`deref $instdirvar`
  if test -z "$instdirval"; then
    instdirval=$CONTRIB_DIR
    eval $instdirvar=$instdirval
  fi
  techo -2 "bilderDuBuild: $instdirvar = $instdirval"

# If not yet asked to install check dependencies
  techo -2 "doBuild = $doBuild"
  if shouldInstall -I $instdirval $1-$verval cc4py $DEPS; then
    doBuild=true
  fi
  techo -2 "doBuild = $doBuild"

# If required, build
  if $doBuild; then
    cd $PROJECT_DIR
    local vervar=`genbashvar $1`_BLDRVERSION
    local verval=`deref $vervar`
    cd $BUILD_DIR/$1-${verval}
    if test $? != 0; then
      TERMINATE_ERROR_MSG="Catastrophic failure in bilderDuBuild.  Unable to cd to $BUILD_DIR/$1-${verval}."
      cleanup
    fi
    local bilderbuild_resfile=bilderbuild-$1.res
    rm -f $bilderbuild_resfile
    rm -rf build/*
    local build_txt=$FQMAILHOST-$1-cc4py-build.txt
    techo "Building $1 in $PWD." | tee $build_txt
    if test "$2" = '-'; then
      unset buildargs
    else
      buildargs="$2"
    fi
    local buildscript=$FQMAILHOST-$1-cc4py-build.sh
    cmd="env $3 python setup.py build $buildargs"
    cat >$buildscript <<EOF
#!/bin/bash
$cmd
res=\$?
echo Build of $1-cc4py completed with result = \$res.
echo \$res > $bilderbuild_resfile
exit \$res
EOF
    chmod ug+x $buildscript
    techo "Building $1-cc4py in $PWD using $buildscript at `date`." | tee -a $build_txt
    techo "$cmd"
    techo ./$buildscript | tee -a $build_txt
    ./$buildscript >>$build_txt 2>&1 &
    pid=$!
    if test -n "$BLDR_PROJECT_URL"; then
      local subdir=`pwd -P | sed "s?^$PROJECT_DIR/??"`
      techo "See $BLDR_PROJECT_URL/$subdir/$build_txt."
    fi

# Record build
    addBuildToLists $1 $pid

    return 0
  fi

  return 1

}

#
# Install a distutils packages.  Uses ${1}_INSTALL_DIR for --prefix.
#
# Args:
# 1: package name
# 2: configuration arguments except for prefix
# 3: Environment under which to run setup.py
#
# Named args (must come first):
# -n Do not run python setup.py install
# -p <package name>, needed if different from tarball base name
# -r Stuff to be removed if a successful build, before installing.
#
bilderDuInstall() {

  techo -2 "bilderDuInstall called with '$*'"

# Default option values
  local dupkg=
  local runInstall=true
  local preinstall=
  local removeold=
# Parse options
  set -- "$@"
  OPTIND=1
  while getopts "np:r:" arg; do
    case $arg in
      n) runInstall=false;;
      p) dupkg="$OPTARG";;
      r) removeold="$OPTARG";;
    esac
  done
  shift $(($OPTIND - 1))

# Fill in unset
  if test -z "$dupkg"; then
    dupkg=$1
  fi

# Get names of files
  cd $PROJECT_DIR
  local vervar=`genbashvar $1`_BLDRVERSION
  local verval=`deref $vervar`
  techo -2 "$vervar = $verval."
  # local installstrval=$1-$verval-cc4py

# Wait on the build.  waitBuild writes SUCCESS or FAILURE.
  if ! waitBuild $1; then
    return 1
  fi

# Remove old stuff as requested
  if test -n "$removeold"; then
    for i in $removeold; do
      cmd="rmall ${PYTHON_SITEPKGSDIR}/${i}*"
      techo "$cmd"
      $cmd
    done
  else
   techo "Nothing to remove before installing."
  fi

# Get installation directory
  local instdirvar=`genbashvar ${1}`_INSTALL_DIR
  local instdirval=`deref $instdirvar`
  if test -z "$instdirval"; then
    instdirval=$CONTRIB_DIR
  fi

# Clean out the output
  cd $BUILD_DIR/$1-${verval}
  local install_txt=$FQMAILHOST-$1-cc4py-install.txt
  rm -f $install_txt

  local res
# Install if needed
  if $runInstall; then

# Go to directory and install
    techo "Executing install for $1 in $PWD." | tee -a $install_txt
    if test "$2" = '-'; then
      unset installargs
    else
      installargs="$2"
    fi

# Do the installation.  For cygwin, do not specify installation prefix
# and hope it goes into system.
    case `uname` in
      CYGWIN*)
        sysinstdirval=`cygpath -aw $instdirval`
        ;;
      *)
        sysinstdirval="$instdirval"
        ;;
    esac
    cmd="python setup.py install --prefix='$sysinstdirval' $installargs"
    if test -n "$3"; then
      cmd="env $3 $cmd"
    fi

# Create installation script, as gets env correct when there are spaces
    local installscript=$FQMAILHOST-$1-cc4py-install.sh
    techo "Creating installation script, $installscript, for command, \"$cmd\", in directory `pwd -P`."
    cat >$installscript << EOF
#!/bin/bash
echo "$cmd"
$cmd
res=\$?
echo Installation of $1-cc4py completed with result = \$res.
echo \$res >bilderinstall.res
exit \$res
EOF
    chmod ug+x $installscript
# Use the installation script
    techo "Installing $1-cc4py in $PWD using $installscript at `date`." | tee -a $install_txt
    techo "$cmd"
    techo ./$installscript | tee -a $install_txt
    ./$installscript >>$install_txt 2>&1
    RESULT=$?
  else
    RESULT=0
  fi

# Do the installation
  if test $RESULT = 0; then
    echo SUCCESS >>$install_txt
    recordInstallation $instdirval $1 $verval cc4py
    if test -e $PYTHON_SITEPKGSDIR/$dupkg; then
      setOpenPerms $PYTHON_SITEPKGSDIR/$dupkg
    fi
# Some python packages install egg info
    if test -e $PYTHON_SITEPKGSDIR/${dupkg}-*.egg-info 1>/dev/null 2>&1; then
      setOpenPerms $PYTHON_SITEPKGSDIR/${dupkg}-*.egg-info
    fi
# Some python packages install eggs
    if test -e $PYTHON_SITEPKGSDIR/${dupkg}-*.egg 1>/dev/null 2>&1; then
      setOpenPerms $PYTHON_SITEPKGSDIR/${dupkg}-*.egg
    fi
# Some python packages install pth files
    if test -e $PYTHON_SITEPKGSDIR/${dupkg}.pth 1>/dev/null 2>&1; then
      setOpenPerms $PYTHON_SITEPKGSDIR/${dupkg}.pth
    fi
# Some python packages install executables
    setOpenPerms $CONTRIB_DIR/bin
    techo "Package $1 installed in $instdirval."

# Rebuild time
    local starttimevar=`genbashvar $1`_START_TIME
    local starttimeval=`deref $starttimevar`
    local endtimeval=`date +%s`
    local buildtime=`expr $endtimeval - $starttimeval`
    techo "Package $1 took $buildtime seconds to build and install." | tee -a $BILDER_LOGDIR/timers.txt
  else
    echo FAILURE >>$BUILD_DIR/$1-${verval}/$install_txt
    installFailures="$installFailures $1"
    anyFailures="$anyFailures $1"
    techo "Package $1 failed to install."
  fi
  if test -n "$BLDR_PROJECT_URL"; then
    local subdir=`(cd $BUILD_DIR/$1-${verval}; pwd -P) | sed "s?^$PROJECT_DIR/??"`
    techo "See $BLDR_PROJECT_URL/$subdir/$install_txt."
  fi

# Create the installer on cygwin
  case `uname` in
    CYGWIN*)
      local distdir=$BUILD_DIR/$1-${verval}/dist
      local installer=
      if test -d $distdir; then
        installer=`(cd $distdir; \ls $dupkg-*.exe 2>/dev/null)`
      fi
# If installer not present, try to make it
      if test -z "$installer"; then
        cmd="cd $BUILD_DIR/$1-${verval}"
        techo "$cmd"
        $cmd
        cmd="python setup.py bdist_wininst"
        techo "$cmd" >>$BUILD_DIR/$1-${verval}/$install_txt
        $cmd 2>&1 >>$BUILD_DIR/$1-${verval}/$install_txt
        if test -d $distdir; then
          installer=`(cd $distdir; \ls $1-*.exe 2>/dev/null)`
        fi
      fi
      if test -n "$installer"; then
        techo "Found installer, $installer."
# From here on can be a method with args for file, pypkgs
        local ccbase=`basename "$CC" .exe`
        mkdir -p $CONTRIB_DIR/installers/pypkgs/$ccbase
        cmd="cp $distdir/$installer $CONTRIB_DIR/installers/pypkgs/$ccbase"
        techo "$cmd"
        $cmd
        if test -n "$INSTALLER_HOST" -a -n "$INSTALLER_ROOTDIR"; then
          cmd="ssh $INSTALLER_HOST mkdir -p ${INSTALLER_ROOTDIR}/open/pypkgs/$ccbase"
          techo "$cmd"
          if $cmd; then
            cmd="ssh $INSTALLER_HOST find ${INSTALLER_ROOTDIR}/open/pypkgs -user \$USER -type d -exec chmod g+rwxs,o-rwx '{}' '\;'"
            techo "$cmd"
            eval "$cmd"
            cmd="scp $distdir/$installer ${INSTALLER_HOST}:${INSTALLER_ROOTDIR}/open/pypkgs/$ccbase"
            techo "$cmd"
            $cmd
            cmd="ssh $INSTALLER_HOST chmod g+rwx,o-rwx ${INSTALLER_ROOTDIR}/open/pypkgs/$ccbase/$installer"
            techo "$cmd"
            $cmd
          else
            techo "Command, $cmd, failed."
          fi
        fi
      else
        techo "No installer found in $PWD/dist."
      fi
      ;;
  esac

  return $res

}

#
# Add a line of HTML
#
# Args:
# 1: The number of spaces to indent
# 2: The text
# 3: the color
# 4: the file
#
addHtmlLine() {
if test -z $4; then
  return 1
fi
local i=0; while test $i -lt $1; do
  echo -n '&nbsp;' >> $4
  i=`expr $i + 1`
done
echo -n "<font style=\"color:$3;\">" >> $4
echo "$2</font><br/>" >> $4
}

#
# write out the results of a build step
#
# Args:
# 1: Short name (e.g., config)
# 2: Long name, capitalized (e.g., Configure)
# 3: Successes
# 4: Failures
#
writeStepRes (){
  rm -f $BUILD_DIR/${1}.failures
  if test -n "$3"; then
    echo "$2 successes: $3" >>$SUMMARY
  fi
  if test -n "$4"; then
    echo "$2 failures: $4" >>$SUMMARY
    echo $4 | tr ' ' '\n' > $BUILD_DIR/${1}.failures
  else
     # Leave old formatting as reference.  Remove 10/01/2012.
     # local lcln=`echo $2 | tr 'A-Z' 'a-z'`
     # echo "No $lcln failed." >>$SUMMARY
    echo "$2 failures: None" >>$SUMMARY
  fi
}

#
# Summarize results and creat an abstract (very short summary)
# of results, such that all abstracts can be concatenated
# together for users to get one email per package per build per
# machine group.
#
# Args:
# 1: The installation directory for env mod files. '-' for none.
# 2: The exit code
#
summarize() {


# Compute elapsed time, timestamp
  local END_TIME=`date +%s`
  cd $PROJECT_DIR
  source bilder/mkvars.sh     # To export variables
  local totalmmss=unknown
  if test -z "$START_TIME"; then
    techo "START_TIME not defined.  Was bildinit.sh sourced by the script?"
  else
    local totaltime=`expr $END_TIME - $START_TIME`
    totalmmss=`myTime $totaltime`
  fi
  local timestamp=`date +%F-%H:%M`

# Begin summary
  techo
  techo "  Bilder creating summary $SUMMARY."
  techo "======================================"
  rmall $SUMMARY
  cat <<EOF >$SUMMARY

SUMMARY

$USER executed $BILDER_CMD on $FQHOSTNAME at $BILDER_START.

EOF

# Begin abstract
  techo "  Bilder creating abstract $ABSTRACT."
  techo "======================================"
  rmall $ABSTRACT

  addHtmlLine 0 "$FQMAILHOST ($RUNNRSYSTEM) - `basename $BUILD_DIR` - $timestamp" BLUE $ABSTRACT
  addHtmlLine 2 "Build: ${BUILD_DIR}" BLACK $ABSTRACT
  chmod a+r ${ABSTRACT}
# Email subject
  for i in pidsKilled anyFailures installations; do
    trimvar $i ' '
  done
  local failed=true
  if $TERMINATE_REQUESTED; then
    EMAIL_SUBJECT="FAILED (killed)."
    if test -n "$pidsKilled"; then
      EMAIL_SUBJECT="$EMAIL_SUBJECT  Builds killed = $pkgsBuilding."
    else
      EMAIL_SUBJECT="$EMAIL_SUBJECT  No builds killed."
    fi
    TERMINATE_ERROR_MSG=${TERMINATE_ERROR_MSG:-"Out of time?"}
    EMAIL_SUBJECT="$EMAIL_SUBJECT  $TERMINATE_ERROR_MSG"
    addHtmlLine 4 "Status: ${EMAIL_SUBJECT}" RED $ABSTRACT
  elif test -n "${anyFailures}${testFailures}"; then
    EMAIL_SUBJECT1=
    if test -z "${configFailures}${buildFailures}${installFailures}"; then
      EMAIL_SUBJECT1="Successes - Builds: $buildSuccesses - Installations: $installations.  "
    fi
    EMAIL_SUBJECT="${EMAIL_SUBJECT}FAILED"
    if test -n "$configFailures"; then
      EMAIL_SUBJECT="$EMAIL_SUBJECT - Configurations: $configFailures"
    fi
    if test -n "$buildFailures"; then
      EMAIL_SUBJECT="$EMAIL_SUBJECT - Builds: $buildFailures"
    fi
    if test -n "$installFailures"; then
      EMAIL_SUBJECT="$EMAIL_SUBJECT - Installations: $installFailures"
    fi
    if test -n "$testFailures"; then
      EMAIL_SUBJECT="$EMAIL_SUBJECT - Tests: $testFailures"
    fi
    EMAIL_SUBJECT="${EMAIL_SUBJECT1}$EMAIL_SUBJECT."
  elif test -n "$installations" -o -n "$testSuccesses"; then
    EMAIL_SUBJECT="SUCCESS"
    failed=false
    if test -n "$installations"; then
      EMAIL_SUBJECT="$EMAIL_SUBJECT - Installations: $installations"
    fi
    if test -n "$testSuccesses"; then
      EMAIL_SUBJECT="$EMAIL_SUBJECT - Tests: $testSuccesses"
    fi
    EMAIL_SUBJECT="$EMAIL_SUBJECT."
  else
    EMAIL_SUBJECT="Nothing built or tested.  Appears all up to date."
  fi
  echo "$EMAIL_SUBJECT" >>$SUMMARY
  echo >>$SUMMARY

# Add lines to abstract
  local statusfound=
  if test -n "$buildSuccesses"; then
    addHtmlLine 4 "Successful Builds: $buildSuccesses" GREEN $ABSTRACT
    statusfound=" - successful builds"
  fi
  if test -n "$installations"; then
    addHtmlLine 4 "Successful Installs: $installations" GREEN $ABSTRACT
    statusfound="${statusfound} - successful installs"
  fi
  if test -n "$testSuccesses"; then
    addHtmlLine 4 "Successful Tests: $testSuccesses" GREEN $ABSTRACT
    statusfound="${statusfound} - successful tests"
  fi
  if test -n "$configFailures"; then
    addHtmlLine 4 "Failed Configures: $configFailures" RED $ABSTRACT
    statusfound="${statusfound} - failed configures"
  fi
  if test -n "$buildFailures"; then
    addHtmlLine 4 "Failed Builds: $buildFailures" RED $ABSTRACT
    statusfound="${statusfound} - failed builds"
  fi
  if test -n "$installFailures"; then
    addHtmlLine 4 "Failed Installs: $installFailures" RED $ABSTRACT
    statusfound="${statusfound} - failed installs"
  fi
  if test -n "$testFailures"; then
    statusfound="${statusfound} - failed tests"
    testfaildir=`echo $testFailures | sed -e 's/-all//'`
    if test -d $testfaildir; then
      numTestFailures=`cat $testfaildir/check.failures | wc -l`
      addHtmlLine 4 "Failed Tests: $testFailures -- $numTestFailures tests" RED $ABSTRACT
    else
      addHtmlLine 4 "Failed Tests: $testFailures" RED $ABSTRACT
    fi
  fi
  if test -z "$statusfound"; then
    addHtmlLine 4 "No successes or failures found. Appears up to date." BLACK $ABSTRACT
  fi

# Line-by-line build step results
  writeStepRes config Configure "$configSuccesses" "$configFailures"
  writeStepRes build Build "$buildSuccesses" "$buildFailures"
  writeStepRes install Installation "$installations" "$installFailures"

# Test results
  echo "If the tests fail, there is no installation, use -I instead." >>$SUMMARY
  local testsRun="$testSuccesses $testFailures"
  trimvar testsRun ' '
  if test -n "$testsRun"; then
    echo "Tests run: $testsRun." >>$SUMMARY
    if test -n "$testSuccesses"; then
      trimvar testSuccesses ' '
      echo "Test successes: $testSuccesses." >>$SUMMARY
    fi
    if test -n "$testFailures"; then
      trimvar testFailures ' '
      echo "Test failures: $testFailures." >>$SUMMARY
    fi
  else
    echo "No tests were run." >>$SUMMARY
  fi
  echo >>$SUMMARY

# Write url
  if test -n "$BLDR_PROJECT_URL"; then
    local subfile=`echo $LOGFILE | sed "s?^$PROJECT_DIR/??"`
    techo "See $BLDR_PROJECT_URL/$subfile." | tee -a $SUMMARY
    addHtmlLine 2 "See $BLDR_PROJECT_URL/$subfile." BLACK $ABSTRACT
  fi

# Put Notes in html only
  grep "^NOTE:" $LOGFILE >$BILDER_LOGDIR/notes.txt
  if test -s $BILDER_LOGDIR/notes.txt; then
    cat $BILDER_LOGDIR/notes.txt | while read vline; do
      addHtmlLine 4 "$vline" DARKORANGE $ABSTRACT
    done
  fi

# Add warnings
  grep "^WARNING:" $LOGFILE >$BILDER_LOGDIR/warnings.txt
  if test -s $BILDER_LOGDIR/warnings.txt; then
    echo WARNINGS >>$SUMMARY
    cat $BILDER_LOGDIR/warnings.txt >>$SUMMARY
    cat $BILDER_LOGDIR/warnings.txt | while read vline; do
      addHtmlLine 4 "$vline" RED $ABSTRACT
    done
  else
    echo "NO WARNINGS" >>$SUMMARY
  fi
  echo >>$SUMMARY

# Identification
  cat <<EOF >>$SUMMARY
USER          $USER
Host          $FQHOSTNAME
System:       `uname -a`
BLDRHOSTID:   $BLDRHOSTID
RUNNRSYSTEM:  $RUNNRSYSTEM
BILDER_CHAIN: $BILDER_CHAIN
ORBITER_NAME: $ORBITER_NAME
BILDER_PACKAGE: $BILDER_PACKAGE
BILDER_VERSION: $BILDER_VERSION
BILDER_URL:     $BILDER_URL
BILDERCONF_VERSION: $BILDERCONF_VERSION
BILDER_WAIT_LAST_INSTALL: $BILDER_WAIT_LAST_INSTALL
Top directory:      $PROJECT_DIR
Config directory:   $BILDER_CONFDIR
Build directory:    $BUILD_DIR
Log directory:      $BILDER_LOGDIR
Tarball installdir: $CONTRIB_DIR
Repo installdir:    $BLDR_INSTALL_DIR
JENKINS_FSROOT:     $JENKINS_FSROOT
BLDR_PROJECT_URL:   $BLDR_PROJECT_URL
Total time =  $totalmmss

EOF

# Add versions of built packages (exclude quoted from bildvars.sh)
  grep "[^ ]*_BLDRVERSION =" $LOGFILE | grep -v reverting | grep -v 'WARNING:' | sed '/_BLDRVERSION = "/d' >$BILDER_LOGDIR/versions.txt
  if test -s $BILDER_LOGDIR/versions.txt; then
    echo VERSIONS >>$SUMMARY
    cat $BILDER_LOGDIR/versions.txt >>$SUMMARY
    cat $BILDER_LOGDIR/versions.txt | while read vline; do
      addHtmlLine 4 "$vline" BLACK $ABSTRACT
    done
    echo >>$SUMMARY
  fi

# Environment changes
  if test "$1" != '-'; then
    cmd="printEnvMods $envmodsdir"
    $cmd >>$SUMMARY
  fi
  echo >>$SUMMARY

# Copy abstract to central host
  if $SEND_ABSTRACT && test -n "$ABSTRACT_HOST" -a -n "$ABSTRACT_ROOTDIR"; then

    techo
    techo "  Bilder sending abstract to host $ABSTRACT_HOST."
    techo "======================================"
    techo "Abstracts will appear in $ABSTRACT_HOST:$ABSTRACT_ROOTDIR/$BILDER_PACKAGE." | tee -a $SUMMARY
    local abstractdir=$ABSTRACT_ROOTDIR/$BILDER_PACKAGE

# Check destination directory to copy abstract to
    local destdirok=false
    cmd="ssh $ABSTRACT_HOST test -d $abstractdir"
    techo "$cmd"
    if $cmd 2>&1; then
# Set destination directory is group writable.  Ignore failure.
      cmd="ssh $ABSTRACT_HOST chmod g=rwxs,o=rx $abstractdir 2>/dev/null"
      $cmd
# Check destination directory for being group writable.
      cmd="ssh $ABSTRACT_HOST test -w $abstractdir"
      if $cmd 2>&1; then
        destdirok=true
      else
        techo "WARNING: Cannot Group write perms not set on ${ABSTRACT_HOST}:$abstractdir."
      fi
    else
# Destination directory does not exist, so we create and ensure group write
      cmd="ssh $ABSTRACT_HOST mkdir -p $abstractdir"
      if $cmd 2>&1; then
        ssh $ABSTRACT_HOST chmod g=rwxs,o=rx $abstractdir
        destdirok=true
      else
        techo "WARNING: Cannot create $abstractdir on $ABSTRACT_HOST."
        techo "WARNING: $cmd"
      fi
    fi

    if $destdirok; then
# Create name such that alphabetical listing will have correct grouping
# I *need* underscores to separate fields
     local abstractdest=${FQMAILHOST}_`basename $BUILD_DIR`_${timestamp}-abstract.html
      abstractdest=$ABSTRACT_ROOTDIR/$BILDER_PACKAGE/$abstractdest
      cmd="scp -q ${ABSTRACT} $ABSTRACT_HOST:${abstractdest}"
      techo "$cmd"
      if $cmd 2>&1; then
        techo "Copy of abstract succeeded.  Making group writable."
        cmd="ssh $ABSTRACT_HOST chmod g=rw,o=r $abstractdest"
      else
        techo "WARNING: Failed to copy ${ABSTRACT} to $ABSTRACT_HOST."
      fi
    else
      techo "WARNING: Could not make $abstractdir on $ABSTRACT_HOST."
    fi

  else
    if ! $SEND_ABSTRACT; then
      techo "WARNING: Not copying abstract as not requested."
    elif test -z "$ABSTRACT_HOST"; then
      techo "WARNING: Not copying abstract as ABSTRACT_HOST is undefined."
    else
      techo "WARNING: Not copying abstract as ABSTRACT_ROOTDIR is undefined."
    fi
  fi

# Determine whether quitting
  if test -n "$2"; then
    echo "$BILDER_NAME completed at `date` with result = '$2'." >>$SUMMARY
  else
    echo "$BILDER_NAME completed at `date`." >>$SUMMARY
  fi
  echo "" >>$SUMMARY
  echo "END OF SUMMARY" >>$SUMMARY
  echo "" >>$SUMMARY

}

#
# Email an error
#
# Args
# 1: The error message
#
emailerror() {
  techo ""
  if test -n "$EMAIL"; then
    local subject="$host $BILDER_NAME.sh ERROR: $1"
    runnrEmail "$EMAIL" $BILDER_NAME@$SMFROMHOST "$subject" $LOGFILE
  fi
}

#
# Email the results
#
# Named args
# -s the email subject
#
emailSummary() {

# Parse options
  local subject=
  while test -n "$1"; do
    case "$1" in
      -s) subject="$2"; shift;;
    esac
    shift
  done

# Always construct subject for email as it uses as a marker for finish of build
  subject=${subject:-"$EMAIL_SUBJECT"}
  subject="$UQMAILHOST ($RUNNRSYSTEM-$BILDER_CHAIN) $BILDER_NAME results: $subject"
  echo "$subject" >$BILDER_LOGDIR/$BILDER_NAME.subj

# If no email address, no email; otherwise send email
  if test -z "$EMAIL"; then
    techo "Not emailing as EMAIL not specified."
  else
    runnrEmail "$EMAIL" $BILDER_NAME@$SMFROMHOST "$subject" $SUMMARY
  fi
}

#
# Cleanup builds
#
cleanup() {
  techo "cleanup called for $BILDER_NAME.  Killing all pending builds."
  TERMINATE_REQUESTED=true
  pidsKilled="$PIDLIST"
  trimvar pidsKilled ' '
  if test -n "$PIDLIST"; then
    for PID in $PIDLIST; do
      techo "kill $PID"
      kill $PID 2>/dev/null
    done
  fi
  finish "-" 1
}

#
# Set the args for building docs
#
getSphinxMathArg() {
  if declare -f defineMathJaxLocCmake > /dev/null; then
    defineMathJaxLocCmake
  else
    # Need to define the common URL
    echo "WARNING: MathJax location unknown."
  fi
}

#
# Given a list of packages to be built plus a list of
# their dependencies, find the subdepencies, remove
# from both lists, concatenate the results first two lists
# as the new list of packages to be build, and the subdependencis
# as the new dependencies.  This is applied recursively until
# there are no subdependencies, with the result bein a list
# of packages to be built in dependency order.
#
# Args:
#  1: comma separated list of already analyzed packages
#  2: comma separated list packages that are the deps of $1
# No package appears twice in either list or in both lists
# Both lists are in dependency order
#
getDeps() {

# Get list of packages to be analyzed
  # techo "getDeps 1 = $1." 1>&2
  allpkgs=`echo "$1" | tr ',' ' '`
  trimvar allpkgs ' '
  newpkgs=`echo $2 | tr ',' ' '`
  trimvar newpkgs ' '
  techo "getDeps: allpkgs = '$allpkgs'." 1>&2
  techo "getDeps: newpkgs = '$newpkgs'." 1>&2
  local rempkgs="$newpkgs"

# Get all dependencies of these packages
  local alldeps=
  local pkg=
  local dep=
  for pkg in $newpkgs; do
    local deps=
    if deps=`grep "^${pkg} " stateddeps$$.txt`; then
      deps=`echo "$deps" | sed "s/^${pkg} //"`
    else
      local pkgfile=`echo $pkg | tr '[A-Z]' '[a-z]'`.sh
      if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/$pkgfile; then
        pkgfile=$BILDER_CONFDIR/packages/$pkgfile
      elif test -f $BILDER_DIR/packages/$pkgfile; then
        pkgfile=$BILDER_DIR/packages/$pkgfile
      else
        TERMINATE_ERROR_MSG="Catastrophic error in getDeps.  Bilder package file, $pkgfile, not found."
# Cannot use cleanup here, as the print gives the dependencies
        techo "$TERMINATE_ERROR_MSG" 1>&2
        exit 1
      fi
      cmd="source $pkgfile"
      techo "$cmd" 1>&2
      $cmd 1>&2
      local buildsvar=`genbashvar $pkg`_BUILDS
      builds=`deref $buildsvar | tr ',' ' '`
      # techo "$buildsvar = $builds." 1>&2
      local deps=
# If first package has no builds, then neither it nor its dependents
# matter at this point, so pull out of resulting packages
      if test -z "$builds" -o "$builds" = NONE; then
        techo "Package $pkg has no builds.  No further analysis needed." 1>&2
        rempkgs=`echo ' '$rempkgs' ' | sed -e "s/ $pkg / /"`
        techo "$pkg " >>stateddeps$$.txt
        continue
      fi
# Otherwise collect its deps
      local depsvar=`genbashvar $pkg`_DEPS
      deps=`deref $depsvar | tr ',' ' '`
      techo "Package $pkg dependencies = '$deps'." 1>&2
      techo "$pkg $deps" >>stateddeps$$.txt
    fi
# Add deps to alldeps if not yet present
    if test -n "$deps"; then
      for dep in $deps; do
        alldeps=`echo ' '$alldeps' ' | sed -e "s/ $dep / /"`
      done
      alldeps="$alldeps $deps"
    fi
  done
  allpkgs="$allpkgs $rempkgs"
  trimvar allpkgs ' '
  trimvar alldeps ' '
# Remove dependencies from allpkgs, so each package appears
# at most once in both lists.
  if test -n "$alldeps"; then
    for dep in $alldeps; do
      allpkgs=`echo ' '$allpkgs' ' | sed -e "s/ $dep / /"`
    done
  fi
  # techo "To be built packages = '$allpkgs'." 1>&2
  # techo "All dependencies = '$alldeps'." 1>&2

# Recurse with these deps
  local deppkgs=
  if test -n "$alldeps"; then
    deppkgs=`getDeps "$allpkgs" "$alldeps"`
  else
    deppkgs="$allpkgs"
  fi
  local respkgs=`echo $deppkgs | sed 's/;.*$//'`
  trimvar respkgs ' '
  local pkgs2=
  if echo $deppkgs | grep -q ';'; then
    pkgs2=`echo $deppkgs | sed 's/^.*;//'`
  fi
  trimvar pkgs2 ' '
  if test -n "$pkgs2"; then
    respkgs="$respkgs;$pkgs2"
  fi

  echo "$respkgs"

}

#
# Get the additional packages to be built as those after the
# first package plus all dependencies of those.
#
# Args:
#  1: comma separated package list
#
getAddlPkgs() {
  local firstpkg=`echo $1 | sed 's/,.*$//'`
  local rempkgs=`echo $1 | sed -e "s/${firstpkg},*//" -e 's/,/ /g'`
  local pkgfile=`echo $firstpkg | tr '[A-Z]' '[a-z]'`.sh
  local deps=
  if deps=`grep "^${firstpkg} " stateddeps$$.txt`; then
    deps=`echo "$deps" | sed "s/^${firstpkg} //"`
  else
    if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/$pkgfile; then
      source $BILDER_CONFDIR/packages/$pkgfile 1>&2
    elif test -f $BILDER_DIR/packages/$pkgfile; then
      source $BILDER_DIR/packages/$pkgfile 1>&2
    else
      TERMINATE_ERROR_MSG="Catastrophic error in getAddlPkgs.  Bilder package file, $pkgfile, not found."
# Cannot use cleanup here, as the print gives the dependencies
      techo "$TERMINATE_ERROR_MSG" 1>&2
      exit 1
    fi
    if test -e $PROJECT_DIR/${WAIT_PACKAGE}.conf; then
      source $PROJECT_DIR/${WAIT_PACKAGE}.conf
    fi
    local buildsvar=`genbashvar $firstpkg`_BUILDS
    builds=`deref $buildsvar | tr ',' ' '`
    local deps=
# If first package has no builds, then neither it nor its dependents
# matter at this point, so just return empty
    if test -z "$builds" -o "$builds" = NONE; then
      echo "Package $firstpkg has no builds.  No further analysis needed." 1>&2
      trimvar rempkgs ' '
      echo $rempkgs
      return
    fi
    local depsvar=`genbashvar $firstpkg`_DEPS
    deps=`deref $depsvar | tr ',' ' '`
    echo "Package $firstpkg to-build dependencies = '$deps'." 1>&2
    echo "$firstpkg $deps" >>stateddeps$$.txt
  fi
# Concat rempkgs and deps to get the additional packages to be built
  local addlpkgs="$rempkgs $deps"
  if test -n "$addlpkgs"; then
    local pkg=
    for pkg in $addlpkgs; do
      local subpkgs=`getAddlPkgs $pkg`
      if test -n "$subpkgs"; then
# Pull dependencies out of list to be appended
        for subpkg in $subpkgs; do
          addlpkgs=`echo ' '$addlpkgs' ' | sed "s/ ${subpkg} / /"`
        done
      fi
# Now append
      addlpkgs="$addlpkgs $subpkgs"
      trimvar addlpkgs ' '
    done
  fi
  echo "$firstpkg $addlpkgs"
}

#
# build the chain for a given package
#
# Args:
#  1: comma separate package list
#
# Named args:
#  -a: analyze only
#
buildChain() {

# Get options
  local analyzeonly=false
  while test -n "$1"; do
    case "$1" in
      -a)
        analyzeonly=true
        ;;
      *)
        break
        ;;
    esac
    shift
  done
  if ! $analyzeonly; then
    USING_BUILD_CHAIN=true
  fi
  techo -2 "buildChain start: PATH=$PATH."

# Source any .conf file
  if test -e $PROJECT_DIR/${WAIT_PACKAGE}.conf; then
    source $PROJECT_DIR/${WAIT_PACKAGE}.conf
  fi

# Look for dependencies to create build chain
  techo "Analyzing Build Chain."
  local analyze=true
  if $analyze; then
    rmall stateddeps$$.txt
    touch stateddeps$$.txt
    SOURCED_PKGS=
    # techo "buildChain: 1 = $1."
    local startsec=`date +%s`
    hifirst=`getDeps "" $1`
    # hifirst=`getAddlPkgs $1`
    local endsec=`date +%s`
    local elapsedsec=`expr $endsec - $startsec`
    techo "Build chain analysis took $elapsedsec seconds."
    rm stateddeps$$.txt
    trimvar hifirst ' '
    chain=`echo $hifirst | awk '{for (i=NF;i>=1;i--) printf $i" "} END{print ""}'`
    trimvar chain ' '
    techo ""
    techo "Package(s) $1 dependencies = '$hifirst'." | tee $BILDER_LOGDIR/${1}-chain.txt
    techo "Inverse order = '$chain'." | tee -a $BILDER_LOGDIR/${1}-chain.txt
    if $analyzeonly; then
      return
    fi
    sleep 3 # Give time to look.
  else
    techo "Dependency analysis of $1 not needed."
  fi

# If Python has no builds, then determine its vars here
  if test -z "$PYTHON_BUILDS"; then
    source $BILDER_DIR/bilderpy.sh
  fi

# Build the chain
  for pkg in $chain; do

# Find length of underline and the make header for package section
    equalsend=
    dashend=
    i=0
    while test $i -le `echo $pkg | wc -c`; do
      equalsend="${equalsend}="
      dashend="${dashend}-"
      let i++
    done
    techo ""
    techo "  Bilder Examining $pkg"
    techo "===================${equalsend}"

    cd $PROJECT_DIR # Make sure at top

# Determine package file
    pkgfile=`echo $pkg | tr '[A-Z]' '[a-z]'`.sh
    if test -n "$BILDER_CONFDIR" -a -f $BILDER_CONFDIR/packages/$pkgfile; then
      pkgfile="$BILDER_CONFDIR/packages/$pkgfile"
    elif test -f $BILDER_DIR/packages/$pkgfile; then
      pkgfile="$BILDER_DIR/packages/$pkgfile"
    else
      TERMINATE_ERROR_MSG="Catastrophic error in buildChain: Bilder package file, $pkgfile, not found."
# Cannot use cleanup here, as the print gives the dependencies
      techo "$TERMINATE_ERROR_MSG" 1>&2
      exit 1
    fi

# Look for commands and execute
    techo "Looking for build command in $pkgfile."
    cmd=`grep -i "^ *build${pkg} *()" $pkgfile | sed 's/(.*$//'`
    if test -z "$cmd"; then
      TERMINATE_ERROR_MSG="Catastrophic error in buildChain: build method for $pkg not found."
# Cannot use cleanup here, as the print gives the dependencies
      techo "$TERMINATE_ERROR_MSG" 1>&2
      exit 1
    fi
    if ! declare -f $cmd 1>/dev/null; then
      cmd2="source $pkgfile"
      techo "$cmd2" 1>&2
      $cmd2 1>&2
    fi
    techo "--------> Executing $cmd <--------"
    $cmd
    techo "---------------------------------${dashend}"
    cmd=`grep -i "^ *test${pkg} *()" $pkgfile | sed 's/(.*$//'`
    if test -n "$cmd"; then
      techo "--------> Executing $cmd <--------"
      $cmd
      techo "--------------------------------${dashend}"
    else
      techo "WARNING: test method for $pkg not found."
    fi
    cmd=`grep -i "^ *install${pkg} *()" $pkgfile | sed 's/(.*$//'`
    if test -z "$cmd"; then
      TERMINATE_ERROR_MSG="Catastrophic error in buildChain: install method for $pkg not found."
      cleanup
    fi
    techo "--------> Executing $cmd <--------"
    $cmd
    techo "-----------------------------------${dashend}"
  done

}

