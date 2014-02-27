## ######################################################################
##
## File:	runnrfcns.sh
##
## Purpose: Define helper functions for running simulations.
##
## Version: $Id$
##
## ######################################################################

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
# Remove everything
#
# Args: anything to be removed
#
rmall() {
  rm -rf -- $*
}

#
# Trim the value of a variable to remove consecutive occurences of a char
#
# Args:
# 1: The variable to modify
# 2: The char
#
trimvar() {
  local varname=$1
  local trimchar="$2"
  local varval
  eval varval=\"`deref $varname`\"
  varval=`echo $varval | sed -e "s/${trimchar}${trimchar}/${trimchar}/g" -e "s/^${trimchar}//" -e "s/${trimchar}\$//"`
  eval $varname="\"$varval\""
}

#
# Echo a string and tee it to the log
#
# Args:
#   1: the string to echo.
#
# Named args (must come first)
#   -1 Print only for verbosity of 1 or greater
#   -2 Print only for verbosity of 2 or greater
#   -n Do not print newline
#
techo() {
# Get options
  set -- "$@"
  OPTIND=1
  eol='\n'
  pverbosity=0
  VERBOSITY=${VERBOSITY:-0}

  while getopts ":n12" arg; do
    case $arg in
      n) unset eol;;
      1) pverbosity=1;;
      2) pverbosity=2;;
    esac
  done
  shift $(($OPTIND - 1))
# Print
  if test $VERBOSITY -ge $pverbosity; then
    if test -n "$LOGFILE"; then
      printf -- "${1}${eol}" | tee -a $LOGFILE
    else
      printf -- "${1}${eol}"
    fi
  fi
}

#
# Rotate a file
#
# 1: the file
#
rotateFile() {
  local fname=$1
  if test -z "$fname"; then
    echo "Catastrophic error.  No fname specified.  Quitting."
    exit 1
  fi
  if test ! -f $fname; then
    echo "No file, $fname.  Not rotating."
    return
  fi
  fnamedir=`dirname $fname`
# Cannot use techo here until file rotated
  # techo "Rotating $fname."
# Remove logs older than $FIRSTREMOVE
  local FIRSTREMOVE=8
  local sfx=`echo $fname | sed 's/^.*\./\./'`
# Should we put number before suffix for browsability?
  # local fnamebase=`basename $fname $sfx`
  local fnums=`(cd $fnamedir; ls -1 ${fnamebase}[0-9]* 2>/dev/null | sort -rn | sed "s/${fnamebase}//g")`
  if test -n "$fnums"; then
    for i in $fnums; do
      if test $i -ge $FIRSTREMOVE; then
        cmd="rm -f ${fname}$i"
        $cmd
      else
        : # Should be able to break here
      fi
    done
  fi
# Rotate logs up
  local j=$(($FIRSTREMOVE - 1))
  while test $j -ge 1; do
    if test -f ${fname}$j; then
      cmd="mv ${fname}$j ${fname}$(($j + 1))"
      # techo "$cmd"
      $cmd
    fi
    j=$(($j - 1))
  done
  cmd="mv $fname ${fname}1"
  # techo -2 "$cmd"
  $cmd
  techo -2 "$fname rotated."
}

#
# Cleanup queue or job
#
runnrCleanup() {
  techo "$0 received kill signal.  Killing all pending builds..."
  runnrRmQJob
}

# Define method for running a command
runnrExec() {
  if test -z "$1"; then
    echo runnrExec: No command given.  Quitting.
    exit 1
  fi
  techo "$1"
  local output=`$1`
  res=$?
  if test $res != 0; then
    echo "Failure of $1 with result $?.  Quitting."
    exit 1
  fi
  echo $output
  return 0
}


#
# Set the following variables:
#  FQHOSTNAME:  fully qualified hostname (different per node on a cluster)
#               e.g., nid00025.nersc.gov, login1.intrepid.alcf.anl.gov
#  UQHOSTNAME:  unqualified hostname (different per node on a cluster)
#               e.g., nid00025, login1
#  FQMAILHOST:  fully qualified mail host (same on all nodes of a cluster)
#               e.g., franklin.nersc.gov, intrepid.alcf.anl.gov
#  UQMAILHOST:  unqualified mail host (same on all nodes of a cluster)
#               e.g., franklin, intrepid
#  DOMAINNAME:  That part of the FQMAILHOST that defines the facility.
#  BLDRHOSTID:  A unique identifier for the host even if a laptop.  In not
#               a laptop, then just the FQMAILHOST
#  MAILSRVR:    if set, the server to send mail through
#  SMFROMHOST:  The from host for sendmail, MAILSRVR if not empty, otherwise
#               FQMAILHOST
#  SENDMAIL:    the full path to sendmail
#  INSTALLER_HOST:    Host to accept installers.  Passwordless login needed.
#  INSTALLER_ROOTDIR: Root directory under which installers are put.
#
runnrGetHostVars() {

# Warn if old runr stuff lying around
  local runnrdebug=${DEBUG:-"false"}
  mydir=`dirname $BASH_SOURCE`
  mydir=`(cd $mydir; pwd -P)`
  if test -d ../runr; then
    local runrdir=`(cd ../runr; pwd -P)`
    $runnrdebug && echo "WARNING: $runrdir (obsolete) should be removed"'!'
  fi

# Set variables associated with system: RUNNRSYSTEM and IS_64BIT
  if test -z "$RUNNRSYSTEM"; then
    case `uname` in
      CYGWIN*)
        if test `uname -m` = x86_64 || [[ `uname` =~ WOW ]]; then
          IS_64BIT=true
          RUNNRSYSTEM=Win64
        else
          IS_64BIT=true
          RUNNRSYSTEM=Win32
        fi
        ;;
      Darwin)
        mach=`uname -m`
        IS_64BIT=true
        case $mach in
          "Power Macintosh")
            mach=ppc
            ;;
        esac
        rev=`uname -r | sed 's/\.[0-9]*$//'`
        RUNNRSYSTEM=Darwin_${rev}-${mach}
        ;;
      Linux)
# Linux has processor in 'uname -r'
        # RUNNRSYSTEM=`uname`_`uname -r`-$ccbase
        mach=`uname -m`
        if test $mach = x86_64; then
          IS_64BIT=true
        else
          IS_64BIT=false
        fi
# Strip any machine off rev so not duplicated
        rev=`uname -r | sed "s/\.$mach//"`
# Get only major-minor of rev
        local majmindist=`echo $rev | sed 's/^\([0-9]*\.[0-9]\).*$/\1/'`
        local contains=false
        for pd in el fc; do
          if [[ $rev =~ \.${pd}[0-9] ]]; then
            # echo $rev contains $pd
            contains=true
            break
          fi
        done
        if $contains; then
          local dist=`echo $rev | sed "s/^.*\.\(${pd}[0-9]\)/\1/"`
          majmindist=${majmindist}.${dist}
        fi
        RUNNRSYSTEM=Linux_${majmindist}-${mach}
        ;;
      *)
        echo "WARNING: RUNNRSYSTEM not known."
        ;;
    esac
  fi

# Look for anything in the configuration directory
  if test -n "$BILDER_CONFDIR" -a -f "$BILDER_CONFDIR/bilderrc"; then
    cmd="source $BILDER_CONFDIR/bilderrc"
    $runnrdebug && echo "$cmd"
    $cmd
  fi

# Additionally look in runnr dir
  RUNNR_DIR=${RUNNR_DIR:-"$mydir"}
  if test -x $RUNNR_DIR/fqdn.sh; then
    cmd="source $RUNNR_DIR/fqdn.sh"
    $runnrdebug && echo "$cmd"
    $cmd
  fi

# Standard methods for setting FQHOSTNAME
  if test -z "$FQHOSTNAME"; then
    if ! FQHOSTNAME=`hostname -f 2>/dev/null`; then
      if test -f /usr/ucb/hostname; then
        FQHOSTNAME=`/usr/ucb/hostname`
      else
        FQHOSTNAME=`hostname`
      fi
    fi
  fi
  UQHOSTNAME=`echo $FQHOSTNAME |  sed 's/\..*//'`	# Unqualified name

#
# Get the domainname
#

# For others try to get domainname from last two elements
  DOMAINNAME=${DOMAINNAME:-"`echo $FQHOSTNAME | grep -q '\.[^\.]*\.[^\.]*'`"}
  # techo "DOMAINNAME = $DOMAINNAME."
  if test -z "$DOMAINNAME" && [[ `uname` =~ CYGWIN ]]; then
    DOMAINNAME=`ipconfig /all | grep -i "Primary Dns Suffix" | sed -e 's/^.*: //'`
    # techo "ipconfig gives DOMAINNAME = $DOMAINNAME."
    if test -n "$DOMAINNAME"; then
      FQHOSTNAME=${UQHOSTNAME}.${DOMAINNAME}
    else
      $runnrdebug &&  echo "WARNING: Windows with ipconfig not defining Primary Dns Suffix."
    fi
  fi
  # techo "FQHOSTNAME = $FQHOSTNAME."
  # techo "WARNING: Quitting in runnrGetHostVars.sh."; exit

# If still empty, need to qualify through this list
  # echo "FQHOSTNAME = $FQHOSTNAME"
  if test -z "$DOMAINNAME" && echo $FQHOSTNAME | grep -q '\.[^\.]*\.[^\.]*$'; then
    # techo "Extracting domainname."
    # DOMAINNAME=`echo $FQHOSTNAME | sed -e 's/^.*\.\([^\.]+\.[^\.]+\)/\1/'`
    DOMAINNAME=`echo $FQHOSTNAME | sed -e 's/^.*\.\([^\.]*\.[^\.]*\)/\1/'`
  fi
  # techo "DOMAINNAME = $DOMAINNAME. BILDER_CONFDIR = $BILDER_CONFDIR."
  if test -z "$DOMAINNAME"; then
    echo "WARNING: runnrGetHostVars unable to determine the domain name."
  fi

# Make any adjustments to MAILSRVR, INSTALLER_HOST, INSTALLER_ROOTDIR,
# FQMAILHOST, BLDRHOSTID
  if test -f $DOMAINS_DIR/${DOMAINNAME}; then
    cmd="source $DOMAINS_DIR/${DOMAINNAME}"
    $runnrdebug && echo "$cmd"
    $cmd
  elif test -f $BILDER_CONFDIR/domains/${DOMAINNAME}; then
    cmd="source $BILDER_CONFDIR/domains/${DOMAINNAME}"
    $runnrdebug && echo "$cmd"
    $cmd
  elif test -f $BILDER_DIR/domains/${DOMAINNAME}; then
    cmd="source $BILDER_DIR/domains/${DOMAINNAME}"
    $runnrdebug && echo "$cmd"
    $cmd
  else
    $runnrdebug &&  echo "Domains file not found."
  fi

# Get any private queue information
  if test -f $BILDER_CONFDIR/bilderqs; then
    cmd="source $BILDER_CONFDIR/bilderqs"
    $runnrdebug && echo "$cmd"
    $cmd
  fi

# Use defaults to set any unset names
# Where mail is to come from, one value for all login nodes
  FQMAILHOST=${FQMAILHOST:-"$FQHOSTNAME"}
  FQWEBHOST=${FQWEBHOST:-"$FQMAILHOST"}
# Sendmail host: used for return address
  SMFROMHOST=${FQMAILHOST}
# Unique id for a laptop
  BLDRHOSTID=${BLDRHOSTID:-"$FQMAILHOST"}
  if test -z "$UQMAILHOST"; then
    UQMAILHOST=`echo $FQMAILHOST |  sed 's/\..*//'`
  fi

# Select mailing program
  if test -z "$SENDMAIL"; then
    for i in /usr/sbin /usr/lib; do
      if test -x $i/sendmail; then
        SENDMAIL=$i/sendmail
        break
      fi
      if [[ `uname -s` == *CYGWIN* ]]; then
        SENDMAIL=blat.exe
      fi
    done
  fi

}

#
# Return the queue target on a per-machine basis.
# Possible values are
#   direct: jobs should just be run, as on systems with no queue or when
#     already on a headnode.
#   headnode: the queue submission command puts the job on a headnode
#   computenode: the queue submission command puts the job on a computenode
#
runnrGetQTarget() {
# Special cases go here
  local qtarget=$RUNNR_QTARGET
  FORCE_NO_QUEUE=${FORCE_NO_QUEUE:-"false"}
  if $FORCE_NO_QUEUE; then
    techo "FORCE_NO_QUEUE = $FORCE_NO_QUEUE, so not using queue." 1>&2
    qtarget=direct
  else
    case $FQMAILHOST in
      *.alcf.anl.gov)
        qtarget=computenode
        ;;
    esac
  fi
  if test -z "$qtarget"; then
    if test -n "$PBS_O_WORKDIR"; then
# Already on headnode if this defined
      techo "PBS job, so already past queue." 1>&2
      qtarget=direct
    elif which qsub 1>/dev/null 2>&1; then
      techo "qsub = `which qsub`" 1>&2
# If qsub found, assume system is a cluster with a headnode
      qtarget=headnode
    else
      techo "qsub not found so not using queue." 1>&2
      qtarget=direct
    fi
  fi
  echo $qtarget
}

#
# Echo the qsub command.  Also sets the variable, QTARGET, which
# is either headnode for clusters and linux systems or computenode
# for Blue Gene like systems.
#
# Args
# 1: number of processors
# 2: walltime
# 3: jobname
# 4: queue
# 5: account
#
runnrGetQSubCmd() {

# Get the target
  local qtarget=`runnrGetQTarget`
# Return empty if direct
  case $qtarget in
    direct)
      return 0
      ;;
  esac

# Get args
  if test -n "$1"; then
    local ncpus=$1
  else
    echo Must specify number of processors as first argument.
    return 1
  fi
  if test -n "$2"; then
    local walltime=$2
  else
    echo Must specify walltime as first argument
    return 1
  fi
  local jobname=$3
  local queue=$4
  local account=$5

# Determine what file to source from domain name
if false; then
  if test -z "$queue" -o -z "$account"; then
    if test -f $BILDER_CONFDIR/$DOMAINNAME; then
      source $BILDER_CONFDIR/$DOMAINNAME
      if declare -f runnrSetQInfoByDomain 1>/dev/null 2>&1; then
        runnrSetQInfoByDomain
      fi
    fi
  fi
fi

# Set variables from new names
  account=${account:-"$RUNNR_ACCOUNT"}	# ComPASS
  queue=${queue:-"$RUNNR_QUEUE"}
  if test -z "$queue"; then
    techo "Catastrophic failure: Queue unknown.  Quitting." 1>&2
    exit 1
  fi

# Construct the resources
# We assume that resources look like: walltime=4:00:00,nodes=1:ppn=8
# But at NERSC, they look like: walltime=4:00:00,mppwidth=8
# So we will key off RUNNR_PPN.  If it is not empty, we use
# the first form.  Otherwise, we use the second.
  local qresources="walltime=$walltime"
  if test -n "$RUNNR_PPN"; then
    local tmp=`expr $ncpus - 1`
    local nodes=`expr $tmp / $RUNNR_PPN + 1`
    qresources="${qresources},nodes=${nodes}:ppn=$RUNNR_PPN"
  else
    local ncpusvar=${RUNNR_NCPUSVAR:-"ncpus"}
    qresources="${qresources},${ncpusvar}=$ncpus"
  fi

# Various qsub lines
  local qsubcmd
  case $qtarget in
    headnode)
      local qsubcmd=qsub
      if test -n "$jobname"; then
        qsubcmd="$qsubcmd -N $jobname"
      fi
      if test -n "$account"; then
        qsubcmd="$qsubcmd -A $account"
      fi
      qsubcmd="$qsubcmd -q $queue -l $qresources -j oe -V"
      ;;
    computenode)
      local qsubcmd=qsub
      if test -n "$jobname"; then
        qsubcmd="$qsubcmd -N $jobname"
      fi
      if test -n "$account"; then
        qsubcmd="$qsubcmd -A $account"
      fi
# This needs fixing for intrepid/surveyor
      qsubcmd="$qsubcmd -q $queue -l $qresources -j oe -V"
      ;;
  esac

# Return command
  echo $qsubcmd

}

#
# Return the queue delete on a per-machine basis.
#
runnrGetQDelCmd() {
# Special cases go here
  local qdelcmd
  case $FQMAILHOST in
    *.alcf.anl.gov)
      qdelcmd=qdel
      ;;
  esac
  if test -z "$qdelcmd"; then
    if test -n "$PBS_O_WORKDIR"; then
# Already on headnode if this defined
      :
    elif which qsub 1>/dev/null 2>&1; then
# If qsub found, assume system is a cluster with a headnode
      qdelcmd=qdel
    else
      :
    fi
  fi
  echo $qdelcmd
}

#
# Return the queue status on a per-machine basis.
#
runnrGetQStatCmd() {
  :
}

#
# Remove a job from a queue
#
# Args:
# 1: The job to remove, defaults to $RUNNR_QJOB
#
runnrRmQJob() {
  local qdelcmd=`runnrGetQDelCmd`
  local qjob=${1:-"$RUNNR_QJOB"}
  if test -n "$qjob" -a -n "$qdelcmd"; then
    cmd="$qdelcmd $qjob"
    techo "$cmd"
    $cmd
  elif test -n "$RUNNR_JOB_PID"; then
    kill $RUNNR_JOB_PID
  fi
  echo $0 exiting.
  exit 99
}

#
# runnrRun: Run a command either by queue (if present) or by
# execution and waiting for a specified time
#
# Args:
# 1: The script name
# 2: The time in HH:MM:SS
# 3: The args for the script
# 4: The number of processors (defaults to 8)
#
# Named args:
# -t  Do tail on pid
#
runnrRun() {

# Get options
  local dotail=false
  # techo "1 = '$1'."

  while test -n "$1"; do
    case "$1" in
      -t) dotail=true;;
      --) shift; break;;
      -?) techo "Unknown option: $1.";;
      *)  break;;
    esac
    shift
  done
  # echo "$1 does not match ^-."

# Local copies of args
  local script=$1
  local runtime=$2
  local scriptargs="$3"
  local nprocs=${4:-"8"}
# Cannot use techo -2 yet, as verbosity not known
  # techo -2 "script = $script."
  # techo -2 "runtime = $runtime."
  # techo -2 "scriptargs = $scriptargs."
  # techo -2 "nprocs = $nprocs."
  scriptbase=`basename $script .sh`

# Rotate the log and summary
  BILDER_LOGDIR=${BILDER_LOGDIR:-"$BUILD_DIR"}
  BILDER_LOGDIR=${BILDER_LOGDIR:-"`pwd -P`/builds"}
  rotateFile $BILDER_LOGDIR/$scriptbase.log
  rotateFile $BILDER_LOGDIR/$scriptbase.subj
  rotateFile $BILDER_LOGDIR/${scriptbase}-summary.txt

# Times
  local qmh=`echo $runtime | sed -e 's/:..$//'`
  local maxhrs=`echo $qmh | sed 's/:.*$//'`
  local maxmns=`echo $qmh | sed 's/^.*://'`
  local totmns=`expr $maxhrs \* 60 + $maxmns`
  local totsecs=`expr $totmns \* 60`
  techo "totsecs = $totsecs"

# Determine queueing commands
  local qtarget=`runnrGetQTarget`
  local qsubcmd=`runnrGetQSubCmd $nprocs $runtime $scriptbase`
  techo "qtarget = '$qtarget'"
  techo "qsubcmd = '$qsubcmd'"

# Remove conclusion signifiers
  rm -f $BILDER_LOGDIR/$scriptbase.{host,start,end}

# Trap exits to clean up
  trap 'runnrCleanup; exit' 1 2 15

# Build everything
  techo "Building and testing."
  local completed=true
  local tailpid=
  local res=
  if test -n "$qsubcmd"; then
    techo "Running in the queue."
# Put args in a file to be picked up by the script
    echo " $scriptargs" >$scriptbase.args
    local cmd="$qsubcmd $script"
    techo "$cmd"
    # techo exit; exit
    RUNNR_QJOB=`$cmd`	# Global needed for error out.
    RUNNR_QJOB_NUM=`echo $RUNNR_QJOB | sed 's/\..*//'`
    if test -z "$RUNNR_QJOB"; then
      techo "Catastrophic error. No queue job number.  Quitting"
      exit 1
    fi
    techo "Submitted to queue at `date`.  RUNNR_QJOB = $RUNNR_QJOB. RUNNR_QJOB_NUM = $RUNNR_QJOB_NUM."

# Wait for startup file
    local jobstatus=
    until test "$jobstatus" = R; do
      sleep 10
      jobstatus=`qstat $RUNNR_QJOB | sed -n '3p' | sed 's/  */ /g' | cut -d ' ' -f 5`
      if [[ "$jobstatus" =~ "Unknown Job" ]]; then
        techo "Job, $RUNNR_QJOB, is unknown.  Quitting."
        unset jobstatus
        unset RUNNR_JOB_PID
        exit 1
      elif test "$jobstatus" = "C"; then
        techo "Job, $RUNNR_QJOB, is complete.  Quitting."
        unset jobstatus
        unset RUNNR_JOB_PID
        exit 1
      fi
      techo "jobstatus = $jobstatus at `date`."
    done
    techo "Running at `date`. Job status is '$jobstatus'."
    local startsecs=`date +%s`
    jobhost=`qstat -f $RUNNR_QJOB | grep exec_host`
    techo "Running on $jobhost."

    if $dotail; then
# Cannot use $PROJECT_DIR/$scriptbase.out, as not immediately of that
# name when running in queue
# File might not show up immediately
      local count=0
      while ! test -f $BILDER_LOGDIR/$scriptbase.log; do
        sleep 1
        count=`expr $count + 1`
        if test $count -ge 60; then
          break
        fi
      done
      if test $count -lt 60; then
        tail -f $BILDER_LOGDIR/$scriptbase.log &
        tailpid=$!
      fi
    fi

# Look for end of job
    while test -n "$jobstatus"; do
      sleep 10
      jobstatus=`qstat $RUNNR_QJOB | sed -n '3p' | sed 's/  */ /g' | cut -d ' ' -f 5`
      if [[ "$jobstatus" =~ "Unknown Job" ]]; then
        unset jobstatus
        techo "Job, $RUNNR_QJOB, is unknown."
      fi
      if test "$jobstatus" = E -o "$jobstatus" = C; then
        techo "Job, $RUNNR_QJOB, ending at `date`."
      fi
    done
    techo "Job, $RUNNR_QJOB, completed at `date`."
    if $dotail; then
      test -n "$tailpid" && kill $tailpid
      cat $BILDER_LOGDIR/${scriptbase}-summary.txt
    fi
    endsecs=`date +%s`
    runsecs=`expr $endsecs - $startsecs`
    if test $runsecs -gt $totsecs; then
      completed=false
      res=1
    else
      if test -f $BUILD_DIR/bilder.res; then
        res=`cat $BUILD_DIR/bilder.res`
      elif test -f $PROJECT_DIR/builds/bilder.res; then
        res=`cat $PROJECT_DIR/builds/bilder.res`
      else
        techo "bilder.res found in neither $BUILD_DIR nor $PROJECT_DIR/builds."
      fi
    fi

  else

# Not a queue job
    techo "Not running in a queue."
    cmd="$script $scriptargs"
    techo "$cmd"
    techo "BILDER_LOGDIR = $BILDER_LOGDIR."
# Increment output number
    local outnum=0
    if test -f $PROJECT_DIR/outnum; then
      outnum=`cat $PROJECT_DIR/outnum`
    fi
    outnum=`expr $outnum + 1`
    echo $outnum >$PROJECT_DIR/outnum
# BILDER_LOGDIR may not exist at first.
    # mkdir -p $BILDER_LOGDIR
    $cmd 1>$PROJECT_DIR/$scriptbase.out$outnum 2>&1 </dev/null &
    local RUNNR_JOB_PID=$!
    techo "Running with RUNNR_JOB_PID = $RUNNR_JOB_PID at `date`."

# Set timing for job to end
    local startsecs=`date +%s`
    local mustendsecs=`expr $startsecs + $totsecs + 600` # Add some grace
# Wait for completion files
    techo "Looking for $BILDER_LOGDIR/$scriptbase.subj and $BILDER_LOGDIR/$scriptbase.end"

    if $dotail; then
if false; then
# File might not show up immediately
      local count=0
      while ! test -f $BILDER_LOGDIR/$scriptbase.log; do
        sleep 1
        count=`expr $count + 1`
        if test $count -ge 60; then
          break
        fi
      done
      if test $count -lt 60; then
        tail -f $BILDER_LOGDIR/$scriptbase.log &
        tailpid=$!
      fi
else
      tail -f $PROJECT_DIR/$scriptbase.out$outnum &
      tailpid=$!
fi
    fi

    local completed=true
    until test -f $BILDER_LOGDIR/$scriptbase.subj -a -f $BILDER_LOGDIR/$scriptbase.end; do
      sleep 10
      local cursecs=`date +%s`
      if test $cursecs -gt $mustendsecs; then
        $dotail && kill $tailpid
        techo "Out of time at `date`."
        techo "$BILDER_LOGDIR/$scriptbase.subj and $BILDER_LOGDIR/$scriptbase.end did not show up."
        if test -n "$RUNNR_JOB_PID"; then
          cmd="kill $RUNNR_JOB_PID"
          techo "$cmd"
          $cmd
        fi
        completed=false
        break
      fi
    done
    if $completed; then
      $dotail && test -n "$tailpid" && kill $tailpid
      techo "$BILDER_LOGDIR/$scriptbase.subj and $BILDER_LOGDIR/$scriptbase.end found."
    fi

# Wait for job to clear
# Non queue job
    techo "Waiting for pid = $RUNNR_JOB_PID to end."
    wait $RUNNR_JOB_PID
    res=$?
    techo "Job with pid = $RUNNR_JOB_PID completed at `date`."
    sleep 10

  fi
  endsecs=`date +%s`
  RUNNR_JOB_TIME=`expr $endsecs - $startsecs`

# Completed
  unset RUNNR_JOB_PID
  techo "runnrRun exiting with $res."
  return $res

}

#
# runnrRunTwice: Run a script potentially twice, the first time
# with given args.  Then if that is not run due to being a too
# recent installation, run a second time with the second installation
# directory.
#
# Args:
# 1: The script name
# 2: The time in HH:MM:SS
# 3: The args for the script
# 4: The number of processors, if specified
# 5: A regex that indicates a successful installation.  When this is found
#    in the subject line after the first installation, the second installation
#    is not attempted.  Defaults to "*SUCCESS*".
#
# Named args:
# -t  Do tail on pid
#
runnrRunTwice() {

  techo "runnrRunTwice entered."

# Get options: just passed to runnrRun
  local runnropts=
  # set -- $*
  OPTIND=1
  while getopts "t" arg; do
    case $arg in
      t) runnropts="$runnropts $arg";;
    esac
  done
  shift $(($OPTIND - 1))

# Local copies of args
  local script=$1
  script=${script:-"$RUNNR_SCRIPT"}
  local runtime=$2
  runtime=${runtime:-"$RUNNR_RUNTIME"}
  local scriptargs=$3
  scriptargs=${scriptargs:-"$RUNNR_SCRIPT_ARGS"}
  local nprocs=$4
  nprocs=${nprocs:-"$RUNNR_NUM_PROCS"}
  local successregex=${5:-"SUCCESS"}

# Run the script the first time
  cmd="runnrRun $runnropts $script $runtime '$scriptargs' $nprocs"
  techo "First run: $cmd"
  eval "$cmd"
  local RUNNR_SCRIPT_BASE=`basename $script .sh`
  BILDER_LOGDIR=${BILDER_LOGDIR:-"$BUILD_DIR"}
  BILDER_LOGDIR=${BILDER_LOGDIR:-"`pwd -P`/builds"}
  if test -f $BILDER_LOGDIR/$RUNNR_SCRIPT_BASE.subj; then
    local subjStr=`cat $BILDER_LOGDIR/$RUNNR_SCRIPT_BASE.subj`
  else
    techo "Catastrophic failure.  $BILDER_LOGDIR/$RUNNR_SCRIPT_BASE.subj did not appear.  Quitting."
    exit
  fi
  techo "runnrRun $script $runtime \"$scriptargs\" concluded with '$subjStr'"

#
# Example of regex usage from http://aplawrence.com/Linux/bash-regex.html:
#   if [[ "$input" =~ 'foo(.*)' ]]; then
#     echo $BASH_REMATCH is what I wanted
#     echo but just ${BASH_REMATCH[1]}
#   fi
  if [[ "$subjStr" =~ "$successregex" ]]; then
    techo "Successful installation ('$successregex' found).  Returning."
    return
  fi
  techo "First installation did not report SUCCESS."
  techo "Will do second installation."

#
# We do not redo tests if the first run failed, as opposed to simply
# not installing as the number of days had not passed
  local notbuilt=true
  if [[ "$subjStr" =~ "FAILED" ]]; then
    notbuilt=false
  fi

# Give some time for I/O to complete.
  sleep 60
# Do second installation.
  techo "Will install in second directory and remove old."
# Use second installation directory, remove old installastion, no wait days
  local newargs="-r2 "`echo $scriptargs | sed -e 's/-w *[0-9]* //'`
  if $notbuilt; then
    techo "Nothing attempted on first installation.  Will test on second installation."
# Do tests but (I) install regardless of results.
    newargs="-I $newargs"
  else
    techo "First installation failed.  Will not test on second installation."
# Do not test (Remove t from any arg strings or as a lone arg).
    newargs=`echo $newargs | sed -e 's/ -t / /' -e 's/\( -[[:alnum:]]*\)t/\1/'`
  fi
  cmd="runnrRun $runnropts $script $runtime '$newargs'"
  techo "Second run: $cmd"
  eval "$cmd"

}

#
# Email the results.  Assumes that the variable SENDMAIL contains
# the full path to sendmail.
#
# Args
# 1: to address
# 2: from address
# 3: subject
# 4: file containing message
#
runnrEmail() {
  local mailsrvrargs
  if test -n "$MAILSRVR"; then
    mailsrvrargs="-server $MAILSRVR"
  fi
  if test -n "$SENDMAIL"; then
    techo "Emailing $1 from $2 with subject '$3' the file, $4 using SENDMAIL=$SENDMAIL."
    if [[ $SENDMAIL == *blat* ]]; then
      if test -n "$BILDER_LOGDIR"; then
        local blatlog=$BILDER_LOGDIR/blat.log
        blatlog=`cygpath -am $blatlog`
      else
        blatlog="blat.log"
      fi
      rotateFile $blatlog
      local embody=`cygpath -am $4`
      local cmd="$SENDMAIL $embody -f $2 -to $1 $mailsrvrargs -debug -log $blatlog -s '$3'"
      techo "$cmd"
      eval "$cmd"
    else
if true; then
# Message must contain To, or get implicit destination error with mailman
# Need -f or get domain does not exist and not delivered
if true; then
      local msg=`cat $4`
      local cmd="$SENDMAIL -f $2 -t"
      techo "$cmd"
      $cmd <<END
From: $2
To: $1
Subject: $3

$msg
END
else
      techo "(echo 'To: $1\nSubject $3\n'; cat $4) | eval \"$cmd\" - $mailsrvrargs"
fi
else
# Attempt to use mail to allow sendmail server arg.
# Does not work on OSX, because it uses postfix?
      local cmd="mail -f $2 -s '$3' $1 - $mailsrvrargs"
      techo "(echo To: $1; cat $4) | eval \"$cmd\""
      (echo To: $1; cat $4) | eval "$cmd"
fi
    fi
  else
    techo "Not emailing as SENDMAIL not defined."
  fi
}

# Get the host variables
runnrGetHostVars
# echo "runnrfcns.sh: FQHOSTNAME = $FQHOSTNAME."
# echo "runnrfcns.sh: DOMAINNAME = $DOMAINNAME."
# echo "runnrfcns.sh: FQMAILHOST = $FQMAILHOST."
# echo exit; exit

