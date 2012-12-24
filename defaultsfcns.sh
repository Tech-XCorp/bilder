#
# $Id$
#
# Defines the following functions
#
# setBilderOsVars: set bilder args based on hosts
#
# setBilderDirsVars: set remaining Bilder default args after knowing host
#                   information, based on directory existence, OS, ...
#
######################################################################

#---------------------------------------------------------------
# Set the Bilder args based on OS.  For now, only CYGWIN.
#---------------------------------------------------------------

setBilderOsVars() {

  case `uname` in

# For CYGWIN machine file must be passed in. COMPKEY derives from that
    CYGWIN*)
      CONTRIB_ROOTDIR=${CONTRIB_ROOTDIR:-"/winsame"}
      INSTALL_ROOTDIR=${INSTALL_ROOTDIR:-"/winsame"}
      USERINST_ROOTDIR=${USERINST_ROOTDIR:-"/winsame/$USER"}
      MACHINEFILE=${MACHINEFILE:-"cygwin.vs9"}
      local winsfx=`echo $MACHINEFILE | sed -e 's/^.*\.//'`
      INSTALL_SUBDIR_SFX=-$winsfx
      ;;

    Darwin)
      # if ! MAX_MAKEJ=`hwprefs cpu_count 2>/dev/null`; then
        # MAX_MAKEJ=`sysctl -n hw.ncpu`
      # fi
      ;;

    Linux)
      if uname -a | grep -q Ubuntu; then
        MACHINEFILE=${MACHINEFILE:-"ubuntu-x86_64"}
      fi
      # MAX_MAKEJ=`grep ^processor /proc/cpuinfo | wc -l`
      ;;

  esac

# Default -j value for make is half the number of processors,
# but not less than 1, and not greater than MKJMAX.
if false; then
  if test -n "$MAX_MAKEJ"; then
    MAKEJ_DEFVAL=`expr $MAX_MAKEJ / 2`
    if test $MAKEJ_DEFVAL -le 0; then
      MAKEJ_DEFVAL=1
    fi
    if test -n "$MKJMAX"; then
      if test  "$MAKEJ_DEFVAL" -gt "$MKJMAX"; then
        MAKEJ_DEFVAL=$MKJMAX
      fi
    fi
    MKJARG="-j $MAKEJ_DEFVAL"
  fi
fi

}

#
# Define Installation and build dirs
#
#
setBilderDirsVars() {

#----------------
# Build location
#----------------

# Build directory
  # techo "BUILD_ROOTDIR = $BUILD_ROOTDIR.  BUILD_SUBDIR = $BUILD_SUBDIR."
  BUILD_SUBDIR=${BUILD_SUBDIR:-"$PROJECT_SUBDIR"}
  if test -n "$BUILD_ROOTDIR" -a -z "$BUILD_DIR"; then
    BUILD_DIR="$BUILD_ROOTDIR"
    if test "$BUILD_SUBDIR" != "."; then
      BUILD_DIR=$BUILD_DIR/$BUILD_SUBDIR
    fi
  fi
  BUILD_DIR=`echo $BUILD_DIR | sed 's?//?/?g'`

#------------------
# Take from Jenkins if that is defined.
#------------------

  USERINST_ROOTDIR=${USERINST_ROOTDIR:-"$JENKINS_FSROOT"}

#------------------
# Contrib/tarball location
#------------------

  if test -z "$CONTRIB_DIR"; then
    if $COMMON_CONTRIB; then
      CONTRIB_DIR=$CONTRIB_ROOTDIR
    else
      CONTRIB_DIR=${USERINST_ROOTDIR:-"$HOME"}
    fi
    # echo "USE_COMMON_INSTDIRS = $USE_COMMON_INSTDIRS."
    if $USE_COMMON_INSTDIRS; then
      CONTRIB_DIR=$CONTRIB_DIR/software${INSTALL_SUBDIR_SFX}
    else
      CONTRIB_DIR=$CONTRIB_DIR/contrib${INSTALL_SUBDIR_SFX}
    fi
    CONTRIB_DIR=`echo $CONTRIB_DIR | sed 's?//?/?g'`
  fi

#------------------
# Install location
#------------------

  if test -z "$BLDR_INSTALL_DIR"; then
    if $COMMON_INSTALL; then
      BLDR_INSTALL_DIR=$INSTALL_ROOTDIR
    else
      BLDR_INSTALL_DIR=${USERINST_ROOTDIR:-"$HOME"}
    fi
    # echo "USE_COMMON_INSTDIRS = $USE_COMMON_INSTDIRS."
    if $USE_COMMON_INSTDIRS; then
      BLDR_INSTALL_DIR=$BLDR_INSTALL_DIR/software${INSTALL_SUBDIR_SFX}
    elif $INSTDIR_IS_INTERNAL; then
      BLDR_INSTALL_DIR=$BLDR_INSTALL_DIR/internal${INSTALL_SUBDIR_SFX}
    else
      BLDR_INSTALL_DIR=$BLDR_INSTALL_DIR/volatile${INSTALL_SUBDIR_SFX}
      SCRIPT_ADDL_ARGS="-rI $SCRIPT_ADDL_ARGS"
    fi
    BLDR_INSTALL_DIR=`echo $BLDR_INSTALL_DIR | sed 's?//?/?g'`
  fi

}

#------------------------------------------------------
# Set all Bilder default args, from most specific to most general:
# machine, OS, general.  In particular, define the variables
#   COMPKEY
#   COMPVER
#   BUILD_ROOTDIR, BUILD_SUBDIR
#   INSTALL_ROOTDIR, INSTALL_SUBDIR
#   CONTRIB_ROOTDIR, CONTRIB_SUBDIR
#------------------------------------------------------

setAllBilderDefVars() {
# Set vars based on host if defined
  if declare -f setBilderHostVars 1>/dev/null 2>&1; then
    setBilderHostVars
  fi
# Set Bilder vars based on os
  setBilderOsVars
  # techo "After setBilderOsVars: COMMON_CONTRIB = $COMMON_CONTRIB."
# Set remaining Bilder vars, primarily for various directories
  setBilderDirsVars
  # techo "After setBilderDirsVars: COMMON_CONTRIB = $COMMON_CONTRIB."
}

#
# Create the command
# Args:
#
runBilderCmd() {

#------------------------------------------------------
# Construct the flags for the
#   machine and the build, tarball, and install directories
# If COMPKEY and COMPVER is defined, then use those labels
# otherwise they are blank
# See machine-locations.sh to understand where the variables come from
#------------------------------------------------------

#
# Create all script args
#
  if test -n "$BUILD_DIR"; then
    local builddir_arg="-b $BUILD_DIR"
  fi
  if test -n "$CONTRIB_DIR"; then
    local tarballdir_arg="-k $CONTRIB_DIR"
  fi
  if test -n "$BLDR_INSTALL_DIR"; then
    local installdir_arg="-i $BLDR_INSTALL_DIR"
  fi

# Create list of packages to ignore for convenience
  local env_arg
  unset env_arg
  if test -e "$ENV_VARS_FILE"; then
    env_arg="env `cat $ENV_VARS_FILE`"
  fi

# Create list of packages to ignore for convenience
  if test -e "$BILDER_NOBUILD_FILE"; then
    local nobuild_arg="-W `cat $BILDER_NOBUILD_FILE`"
  fi

# Allow the setting of a EXTRA_ARGS from a file
  if test -e "$EXTRA_ARG_FILE"; then
    local EXTRA_ARGS="$EXTRA_ARGS `cat $EXTRA_ARG_FILE`"
  fi

# Find script
# Do not strip leading ./ as if on basic script, then needed for next one
  script=`echo $SCRIPT_NAME | sed -e "s/-default.sh\$/.sh/"`
  local SCRIPT_BASE=`echo $script | sed -e 's/.sh$//' -e 's?^\./??g'`

# For email, it is to difficult to figure out the proper mail address
# and laptops typically do not have email to user set up properly.
# To ameliorate, allow setting through an environment variable if
# not otherwise defined.
  if test -z "$MAIL_ADDRESS" -a -n "$DOMAINNAME"; then
    MAIL_ADDRESS=${USER}@${DOMAINNAME}
  fi
  if test -n "$MAIL_ADDRESS"; then
    email_arg="-e $MAIL_ADDRESS"
  fi

# Build command
  if test -n "$MACHINEFILE"; then
    machinefile_args="-m $MACHINEFILE"
  fi

# Construct command
  # local scriptargs=`echo $BILDER_ARGS $EXTRA_ARGS $MKJARG $machinefile_args $builddir_arg $tarballdir_arg $installdir_arg $nobuild_arg $email_arg $SCRIPT_ADDL_ARGS $BILDER_ADDL_ARGS | sed 's/  */ /'`
  local scriptargs=`echo $BILDER_ARGS $EXTRA_ARGS $machinefile_args $builddir_arg $tarballdir_arg $installdir_arg $nobuild_arg $email_arg $BILDER_ADDL_ARGS $SCRIPT_ADDL_ARGS | sed 's/  */ /'`
  if test -n "$QUEUE_TIME"; then
    if $USE_NOHUP; then
      runnrscript=$SCRIPT_BASE-runnr.sh
cat >$runnrscript <<EOF
#!/bin/bash
source $PWD/bilder/runnr/runnrfcns.sh
runnrRun -t $script $QUEUE_TIME '$scriptargs'
EOF
      chmod a+x $runnrscript
      cmd="./$runnrscript"
    else
      cmd="runnrRun -t $script $QUEUE_TIME '$scriptargs'"
    fi
  else
    cmd="$script $scriptargs"
  fi
  if test -n "$env_arg"; then
    cmd="$env_arg $cmd"
  fi

# Construct name of output file for nohup
  if $USE_NOHUP; then
    local inst_subdir=`basename $BLDR_INSTALL_DIR`
    ofilename=$SCRIPT_BASE-$UQMAILHOST-$inst_subdir.out
  fi

# Print and/or execute the command
  if $PRINTONLY; then
    echo "Command is"
  fi
  local res=
# Nohup has different command printout
  if $USE_NOHUP; then
    echo "nohup $cmd >$ofilename 2>&1 </dev/null &"
    if $PRINTONLY; then
      res=0
    else
      nohup $cmd 1>$ofilename 2>&1 </dev/null &
      pid=$!
      cat >&2 <<EOF
Launched background job with PID = $pid.
To see output:
  tail -f $ofilename
EOF
      res=0
    fi
  else
# Other cases print out same command
    echo "$cmd"
    if $PRINTONLY; then
      res=0
    else
      eval "$cmd"
      res=$?
    fi
  fi
  techo "runBilderCmd exiting with $res."
  return $res

}

