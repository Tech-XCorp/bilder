######################################################################
#
# $Id$
#
# General stuff for extracting options
#
######################################################################

#
# Method to print out general and script specific options
#
bilderUsage() {

# Get options
  set -- "$@"
  OPTIND=1
  SKIP_HEADER=false
  while getopts "s" arg; do
    case $arg in
      s) SKIP_HEADER=true;;
    esac
  done
  shift $(($OPTIND - 1))

  if $SKIP_HEADER; then
    echo
  else
    cat >&2 <<EOF
Usage: $0 [options]
EOF
  fi

  cat >&2 <<EOF
BILDER OPTIONS
  -a ................ Update non-subversion packages
  -A <addl_sp> ...... Add this to the supra search path.
  -b <build_dir> .... Build in <build_dir>.
  -B <force builds>.. Force build of package (comma-delimited list)
  -c ................ Configure packages but don't build.
  -C ................ Create installers.
  -d ................ Create debug builds (limited package support).
  -D <builds> ....... Default doc builds (subset of url,lite,full,develdocs).
  -e <addr> ......... Email log to specified recipients.
  -E <env pairs> .... Comma-delimited list of environment var=value pair.
  -F ................ Force installation of packages that have local
                        modifications.
  -g ................ Allow use of gfortran with version <4.3
  -G ................ Just get packages.  Do not configure or build anything.
  -h ................ Print this message.
  -H ................ Send the \$BILDER_PROJECT-abstract.html file
                      to the abstract host if defined.
  -i <install_dir> .. Set comma delimited list of installation directories
                        for code in subdirs, expected to be svn repos; install
                        in first directory unless command line contains -2,
                        in which case install in the last directory.
                        <install_dir> defaults to \$HOME/software if not set.
  -I ................ Install even if tests fail (ignore test results).
  -j <n> ............ Maximum value of arg to make with -j.
  -k <tarball_dir> .. Set installation directory for code in tarballs,
                        expected to be found in one of the pkg repo subdirs;
                        <tarball_dir> defaults to <install_dir> if not set.
  -K <val> .......... Run cleaninstalls.sh -lrR -k <val> to clean broken links
                      and update installations.txt.
  -l <mpi launcher> . The executable that launches an MPI job.
  -L ................ Directory for logs (if different from build).
  -m <hostfile> ..... File to source for machine specific defs.
  -M ................ Maximally thread.
  -N ................ Build repo packages as Release with stripped executables.
  -o ................ Install mpi if not on cygwin. Use
                        -E USE_MPI=<package-build> to specify which mpi.
                        openmpi-nodl is default.
  -O ................ Install optional packages = ATLAS, parallel visit, ...
  -p <path> ......... Specify a supra-search-path.
  -P ................ Do not post to depot regardless of other settings.
  -r ................ Remove other installations of a package upon successful
                        installation of that package.
  -R ................ Build Release with executables that are stripped and are
                        signed and licensed when applicable.
  -s ................ Rebuild packages if package script has been modified
                        since last build.
  -S ................ Build static.
  -t ................ Run tests.
  -T ................ Set tests to run with internal preprocessor
  -u ................ Do "svn up" at start.
  -U ................ Do not get (direct access or svn up) tarballs.
  -v <level> ........ Verbose: print debug information from bilder
                        according to level (2 is good for understanding bilder).
  -w <wait days>      Wait this many days before doing a new installation.
  -W <disable builds> Build without these packages (comma delimited list)
                        e.g., -W nubeam,plasma_state.
  -X ................ Build experimental (new) versions of packages.
  -y ................ Disable cuda?  yes
  -z ................ Clean git or hg repos.
  -Z ................ Do not execute the definable bilderFinalAction.
EOF

  if declare -f extrausage > /dev/null; then extrausage; fi
  exit $1
}

#
# Method for processing the arguments
#
processBilderArgs() {
  case "$1" in
    a) NONSVNUP=true;;
    A) ADDL_SUPRA_SP=$OPTARG;;
    b) BUILD_DIR=$OPTARG;;
    B) FORCEBUILD_PKGS=${FORCEBUILD_PKGS},$OPTARG;;
    c) NOBUILD=true;;
    C) BUILD_INSTALLERS=true;;
    d) BUILD_DEBUG=true;;  # This is for operating at the package level
    D) DOCS_BUILDS=$OPTARG
# JRC: Below is problematic as the builds can be concatenated and comma
# delimited.
       # case $DOCS_BUILDS in
       #  develdocs|lite|full|url) ;;
       #  *) techo "Catastrophic error. -D must take one of the following options: develdocs, lite, full, url."
       #       exit 13;;
       # esac;;
       ;;
    e) EMAIL=${EMAIL},$OPTARG;;
    E) BILDER_ENV=${BILDER_ENV},$OPTARG;;
    F) FORCE_INSTALL=true;;
    g) GFORTRAN_GOOD=true;;
    G) JUST_GET_PACKAGES=true;;
    h) bilderUsage 0;;
    H) SEND_ABSTRACT=true;;
    i) BLDR_INSTALL_DIR=$OPTARG;;
    I) IGNORE_TEST_RESULTS=true;;
    j) JMAKE=$OPTARG;;
    k) CONTRIB_DIR=$OPTARG;;
    K) CLEAN_INSTALLS=$OPTARG;;
    l) MPI_LAUNCHER=$OPTARG;;
    L) BILDER_LOGDIR=$OPTARG;;
    m) export MACHINE_FILE=$OPTARG;;  # Give to subshells
    M) MAX_THREADS=true;;
    N) REPO_BUILD_TYPE=Release;;
    o) case `uname` in
	 CYGWIN*) ;;
	       *) BUILD_MPIS=true;;
       esac;;
    O) BUILD_OPTIONAL=true;;
    p) SUPRA_SP=$OPTARG;;
    P) POST2DEPOT=false;;
    r) REMOVE_OLD=true;;
    R) CREATE_RELEASE=true;;
    s) BUILD_IF_NEWER_PKGFILE=false;;
    S) SER_EXTRA_LDFLAGS="--static $SER_EXTRA_LDFLAGS"    # For serial builds
       PAR_EXTRA_LDFLAGS="--static $PAR_EXTRA_LDFLAGS";;  # For parallel builds;
    t) TESTING=true;;
    T) USE_INTERNAL_TXPP=true;;
    u) SVNUP=true;;
    U) SVNUP_PKGS=false;;
    v) VERBOSITY=$OPTARG;;  # The option formerly known as debug
    V) INSTALL_VISIT=true;;
    w) BILDER_WAIT_DAYS=$OPTARG;;
    W) NOBUILD_PKGS=${NOBUILD_PKGS},$OPTARG;;
    X) BUILD_EXPERIMENTAL=true;;
    y) SCI_ENABLE_CUDA=false;;
    z) CLEAN_GITHG_SUBREPOS=true;;
    Z) DO_FINAL_ACTION=false;;
    2) techo "WARNING: -2 option will be removed Oct. 18, 2014. Use -FI instead."
       IS_SECOND_INSTALL=true;;
   \?) bilderUsage 1;;
    *)  # To take care of any extra args
      if test -n "$OPTARG"; then
        eval $arg=\"$OPTARG\"
      else
        eval $arg=found
      fi
      ;;
  esac
}

#
# Set all the default variable values, parse the options,
# set secondary variable values.
#
setBilderOptions() {

# Record how started and time
  BILDER_CMD="$0 $*"
  BILDER_START=`date`

# Universal defaults
# Use - instead of :- to allow BILDER_CTEST_MODEL to be empty.
  BILDER_CTEST_MODEL=${BILDER_CTEST_MODEL-"Experimental"}
  BILDER_LOGDIR=
  BILDER_WAIT_DAYS=0
  BUILD_DEBUG=false
  BUILD_DIR=$PROJECT_DIR/builds
  BUILD_EXPERIMENTAL=false
  BUILD_IF_NEWER_PKGFILE=true
  BUILD_INSTALLERS=${BUILD_INSTALLERS:-"false"}
  BUILD_MPIS=false
  BUILD_OPTIONAL=false
  BUILD_TARBALLS=true
  CLEAN_INSTALLS=
  CREATE_RELEASE=false
  DEFAULT_INSTALL_DIR=${DEFAULT_INSTALL_DIR:-"$HOME/software"}
  SCI_ENABLE_CUDA=true
  DOCS_BUILDS=
  DO_FINAL_ACTION=true
  FORCE_INSTALL=false
  FORCE_PYINSTALL=false
  GFORTRAN_GOOD=false
  IGNORE_TEST_RESULTS=false
  INSTALL_VISIT=false
  IS_SECOND_INSTALL=false
  JUST_GET_PACKAGES=false
  MAX_THREADS=false
  NOBUILD=false
  POST2DEPOT=${POST2DEPOT:-"true"}
  REMOVE_OLD=false
  REPO_BUILD_TYPE=${REPO_BUILD_TYPE:-"RelWithDebInfo"}
  RM_BUILD=true
  SEND_ABSTRACT=false
  SVNUP=false
  SVNUP_PKGS=true # Whether to svn up pkgs
  TARBALL_BUILD_TYPE=${TARBALL_BUILD_TYPE:-"Release"}
  TESTING_DEVELDOCS=${TESTING_DEVELDOCS:-"false"}
  TESTING=false
  USE_INTERNAL_TXPP=false
  VERBOSITY=1
  export BUILD_EXPERIMENTAL  # Needed by setinstald.sh
  export VERBOSITY

#######################################################

# Get options
  BILDER_ARGS="aA:b:B:cCdD:e:E:FgGhHi:Ij:k:K:L:l:m:MNoOp:PrRsStTuUv:VW:w:XyzZ2$EXTRA_BILDER_ARGS"

  set -- "$@"
  # techo "* = $*."
  OPTIND=1
  while getopts "$BILDER_ARGS" arg; do
    if declare -f processExtraArgs > /dev/null; then
      processExtraArgs $arg
    fi
    processBilderArgs $arg
  done
# Duplicated outside the function call for scoping
  BILDER_OPTIND=$OPTIND
  techo -2 "BILDER_OPTIND = $BILDER_OPTIND."
  shift $(($BILDER_OPTIND - 1))
  BILDER_TARGET="$*"
  techo -2 "BILDER_TARGET = $BILDER_TARGET."
  BILDER_CMD_NO_TARGET=$BILDER_CMD
  if test -n "$BILDER_TARGET"; then
    BILDER_CMD_NO_TARGET=`echo $BILDER_CMD | sed -e "s/\(.*\)$BILDER_TARGET/\1/"`
    techo -2 "BILDER_CMD_NO_TARGET = $BILDER_CMD_NO_TARGET"
  fi
  techo -2 "BILDER_CMD = $BILDER_CMD"

# Ensure BILDER_NAME defined
# Allow calling routine to specify the name
  if test -z "$BILDER_NAME"; then
    BILDER_NAME=`basename $0 .sh`
  fi
  if test -z "$BILDER_NAME"; then
    BILDER_NAME=unknown
  fi
  techo -2 "BILDER_NAME = $BILDER_NAME."

# Record invocation line for reuse
  if test -n "$BILDER_NAME"; then
    cat >$PROJECT_DIR/${BILDER_NAME}-redo.sh <<EOF
#!/bin/bash
cmd="${BILDER_CMD_NO_TARGET}"
target="${BILDER_TARGET}"
if [ \$# = 0 ]; then
  echo '#' The last bilder run was
  echo \$cmd \$target
  echo '#' To redo that run execute: ${BILDER_NAME}-redo.sh redo
  echo '#' To run with default targets, execute: ${BILDER_NAME}-redo.sh default
  echo '#' To change targets, execute: ${BILDER_NAME}-redo.sh '<new target>'
  exit 0
fi
if [ "\$1" = redo -o "\$1" = run ]; then
  echo "Executing \$cmd \$target"
  exec \$cmd \$target
elif [ "\$1" = default ]; then
  echo "Executing \$cmd"
  exec \$cmd
else
  echo "Executing \$cmd \$1"
  exec \$cmd \$1
fi
EOF
    chmod a+x $PROJECT_DIR/${BILDER_NAME}-redo.sh
  fi

# Ensure presence of build and log directories.  Time stamp the start.
  checkDirWritable $BUILD_DIR
  BUILD_DIR=`(cd $BUILD_DIR; pwd -P)`
  BILDER_LOGDIR=${BILDER_LOGDIR:-"$BUILD_DIR"}
  checkDirWritable $BILDER_LOGDIR
  BILDER_LOGDIR=`(cd $BILDER_LOGDIR; pwd -P)`
  echo $BILDER_START >$BILDER_LOGDIR/$BILDER_NAME.start

# Rotate the log now that have build directory
# Start the new versions and timer files now
# that we have the build directory
  LOGFILE=$BILDER_LOGDIR/${BILDER_NAME}.log
  rotateFile $LOGFILE
  SUBJFILE=$BILDER_LOGDIR/${BILDER_NAME}.subj
  rotateFile $SUBJFILE
  rotateFile $BILDER_LOGDIR/cleaninstalls.log

# Record invocation line (now that log is correct)
  techo "Executing $BILDER_CMD in $PROJECT_DIR on `hostname` at $BILDER_START."
  techo "PID = $$."
  techo "Logs will appear in $BILDER_LOGDIR."
  if test -d $BILDER_DIR/runr; then
    techo "WARNING: [bildopts.sh] Obsolete directory, $BILDER_DIR/runr, present.  Remove?"
  fi

  SUMMARY=$BILDER_LOGDIR/${BILDER_NAME}-summary.txt
  ABSTRACT=$BILDER_LOGDIR/${BILDER_NAME}-abstract.html
# A summary file will always be generated, but an abstract file
# will only be generated when bilder is invoked with the -H
# argument.  However, as the files are rotated, their numbers
# need to be kept consistent.
  if test -e $SUMMARY -a ! -e $ABSTRACT; then
# In this case, a summary file exists but an abstract file does
# not.  Create temporary abstract file so that the rotation will
# occur, then remove.
    rotateFile $SUMMARY
    touch $ABSTRACT
    rotateFile $ABSTRACT
    rmall ${ABSTRACT}1
  else
# Both a summary and abstract file were previously generated.
# Alternatively, neither were # generated when the build directory
# is new.
    rotateFile $SUMMARY
    rotateFile $ABSTRACT
  fi

# Warn if old build directories lying around
  case $BUILD_DIR in
    */builds-i | */builds-v)
      for i in builds builds2 builds-volatile builds-internal buildsv buildsi; do
        if test -d $PROJECT_DIR/$i; then
          techo "WARNING: [bildopts.sh] Old build directory, $PROJECT_DIR/$i, found.  Remove?"
        fi
      done
      case `uname` in
        CYGWIN*)
          projname=`echo $BILDER_NAME | sed "s/mk//" | sed "s/all//"`
          if test -d /winsame/$USER/$projname/$i; then
            techo "WARNING: [bildopts.sh] Old build directory, /winsame/$USER/$projname/$i, found.  Remove?"
          fi
        ;;
      esac
  esac

  BUILD_ATLAS=${BUILD_ATLAS:-"$BUILD_OPTIONAL"}
  NONSVNUP=${NONSVNUP:-"$SVNUP"}
  CLEAN_GITHG_SUBREPOS=${CLEAN_GITHG_SUBREPOS:-"$SVNUP"}
# Auxiliary variables
  TARBALL_BUILD_TYPE_LC=`echo $TARBALL_BUILD_TYPE | tr 'A-Z' 'a-z'`
  TARBALL_BUILD_TYPE_UC=`echo $TARBALL_BUILD_TYPE | tr 'a-z' 'A-Z'`
  REPO_BUILD_TYPE_LC=`echo $REPO_BUILD_TYPE | tr 'A-Z' 'a-z'`
  REPO_BUILD_TYPE_UC=`echo $REPO_BUILD_TYPE | tr 'a-z' 'A-Z'`

# On second installations, force installation and ignore test results
  if $IS_SECOND_INSTALL; then
    FORCE_INSTALL=true
    IGNORE_TEST_RESULTS=true
  fi

# Trim cumulative variables
  trimvar BILDER_ENV ','
  trimvar EMAIL ','
  trimvar NOBUILD_PKGS ','
  trimvar FORCEBUILD_PKGS ','

# Check that findProjectDir is consistent
  techo "Checking for consistency of findProjectDir."
  sed -n '/^findProjectDir(/,/^}/p' $PROJECT_DIR/$BILDER_NAME.sh >fbd1.out
  sed -n '/^findProjectDir(/,/^}/p' $BILDER_DIR/findProjectDir.sh >fbd2.out
  if diff fbd1.out fbd2.out; then
    techo "findProjectDir is consistent."
  else
    techo "WARNING: [bildopts.sh] Inconsistency between"
    techo "WARNING: [bildopts.sh]     findProjectDir in $BILDER_NAME.sh"
    techo "WARNING: [bildopts.sh]   and"
    techo "WARNING: [bildopts.sh]     bilder/findProjectDir.sh"
    techo "WARNING: [bildopts.sh] Please make these consistent."
  fi
  rm -f fbd1.out fbd2.out

# Remove old versions and times
  rmall $BILDER_LOGDIR/versions.txt
  rmall $BILDER_LOGDIR/timers.txt

# Remove files in BUILD_DIR that are now placed in BILDER_LOGDIR
# techo "BUILD_DIR = $BUILD_DIR"
  if test $BUILD_DIR != $BILDER_LOGDIR; then
    obsoletefiles=`(cd $BUILD_DIR; ls versions.txt timers.txt ${BILDER_NAME}.{log*,summary*,start,subj,end,host} PostBilderToOrbiter.log* runnrsvnup.out* svnup.out* 2>/dev/null)`
# cmd="ls $BUILD_DIR"
# techo "$cmd"
# $cmd
    contents=`$cmd`
    if test -n "$obsoletefiles"; then
      techo "Removing obsolete files, $obsoletefiles, in $BUILD_DIR."
      (cd $BUILD_DIR; rmall $obsoletefiles)
    else
      techo "No obsolete files in $BUILD_DIR.  Contents = $contents."
    fi
  else
    techo "Build directory is log directory."
  fi

# Set environment
  if test -n "$BILDER_ENV"; then
    for i in `echo $BILDER_ENV | sed 's/,\([A-Za-z_][0-9A-Za-z_]*=\)/ \1/g'`; do
      cmd="export $i"
      techo "$cmd"
      $cmd
    done
  fi
# techo exit; exit

# Set args
  if test -n "$EMAIL"; then
    EMAIL_ARG="--with-email=$EMAIL"
  fi
  if test -n "$MPI_LAUNCHER"; then
    MPI_LAUNCHER_ARG="--with-mpi-launcher=$MPI_LAUNCHER"
  fi

  if $TESTING; then
    TESTING_BUILDS=${TESTING_BUILDS:-"true"}
    techo "Tests will be run.  You must have the results directories checked out for installation.  If a package does not install (due to failing tests) its dependents might not build."
  else
    TESTING_BUILDS=${TESTING_BUILDS:-"false"}
    techo "Tests will NOT be run."
  fi
  BILDER_USE_CTEST=${BILDER_USE_CTEST:-"false"}

# Parse out first or second half of variable
  SECOND_INSTALL_DIR=
  if $IS_SECOND_INSTALL; then
    BLDR_INSTALL_DIR=`echo $BLDR_INSTALL_DIR | sed 's/^.*,//'`
  else
    if echo $BLDR_INSTALL_DIR | grep -q ','; then
      SECOND_INSTALL_DIR=`echo $BLDR_INSTALL_DIR | sed 's/^.*,//'`
    fi
    BLDR_INSTALL_DIR=`echo $BLDR_INSTALL_DIR | sed 's/,.*$//'`
  fi
# Use installdir and contrib dir separately, or whichever was set
  BLDR_INSTALL_DIR=${BLDR_INSTALL_DIR:-"$DEFAULT_INSTALL_DIR"}
  INSTALL_BASENAME=`basename $BLDR_INSTALL_DIR`
  CONTRIB_DIR=${CONTRIB_DIR:-"$BLDR_INSTALL_DIR"}

# Check ability to write into installation directory
  checkDirWritable $BLDR_INSTALL_DIR
  BLDR_INSTALL_DIR=`(cd $BLDR_INSTALL_DIR; pwd -P)`
  if test -n "$SECOND_INSTALL_DIR"; then
    checkDirWritable $SECOND_INSTALL_DIR
    SECOND_INSTALL_DIR=`(cd $SECOND_INSTALL_DIR; pwd -P)`
    if test "$SECOND_INSTALL_DIR" = "$BLDR_INSTALL_DIR"; then
      SECOND_INSTALL_DIR=
    fi
  fi

# The documentation directories are under the installation directory
  USERDOCS_DIR=$BLDR_INSTALL_DIR/userdocs
  mkdir -p $USERDOCS_DIR
  DEVELDOCS_DIR=$BLDR_INSTALL_DIR/develdocs
  mkdir -p $DEVELDOCS_DIR

# Check ability to write into contrib directory
  checkDirWritable -c $CONTRIB_DIR
  CONTRIB_DIR=`(cd $CONTRIB_DIR; pwd -P)`
  export CONTRIB_DIR

# Clean directories if requested
  if test -n "$CLEAN_INSTALLS"; then
    # printInstallationStatus numpy $CONTRIB_DIR pre-cleaninstalls
    rotateFile $BILDER_LOGDIR/cleaninstalls.log
    CLEAN_OPTS="-lrR -k $CLEAN_INSTALLS"
    cmd="$BILDER_DIR/cleaninstalls.sh $CLEAN_OPTS $CONTRIB_DIR $BLDR_INSTALL_DIR $USERDOCS_DIR $DEVELDOCS_DIR 1>$BILDER_LOGDIR/cleaninstalls.log 2>&1"
    techo "$cmd"
    eval "$cmd"
    # printInstallationStatus numpy $CONTRIB_DIR post-cleaninstalls
  fi

# Convert to cygwin as appropriate
  case `uname` in
    CYGWIN*)
      MIXED_INSTALL_DIR=`cygpath -am $BLDR_INSTALL_DIR`
      MIXED_CONTRIB_DIR=`cygpath -am $CONTRIB_DIR`
      NATIVE_INSTALL_DIR=`cygpath -aw $BLDR_INSTALL_DIR`
      NATIVE_CONTRIB_DIR=`cygpath -aw $CONTRIB_DIR`
      if test -n "$SECOND_INSTALL_DIR"; then
        MIXED_SECOND_INSTALL_DIR=`cygpath -am $SECOND_INSTALL_DIR`
        NATIVE_SECOND_INSTALL_DIR=`cygpath -am $SECOND_INSTALL_DIR`
      fi
      ;;
    *)
# If not on windows these dirs are just the unix dirs
      MIXED_INSTALL_DIR=$BLDR_INSTALL_DIR
      MIXED_CONTRIB_DIR=$CONTRIB_DIR
      NATIVE_INSTALL_DIR=$BLDR_INSTALL_DIR
      NATIVE_CONTRIB_DIR=$CONTRIB_DIR
      MIXED_SECOND_INSTALL_DIR=$SECOND_INSTALL_DIR
      NATIVE_SECOND_INSTALL_DIR=$SECOND_INSTALL_DIR
      ;;
  esac

# Set supra-search-path if empty
  if test -z "$SUPRA_SP"; then
    SUPRA_SP="$BLDR_INSTALL_DIR"
    if test -n "$SECOND_INSTALL_DIR"; then
      SUPRA_SP="$SUPRA_SP":"$SECOND_INSTALL_DIR"
    fi
    if test "$BLDR_INSTALL_DIR" != "$CONTRIB_DIR"; then
      SUPRA_SP="$SUPRA_SP":"$CONTRIB_DIR"
    fi
    SUPRA_SP="$SUPRA_SP":"$USERDOCS_DIR"
  fi
  SUPRA_SP="$SUPRA_SP":"$ADDL_SUPRA_SP"
  trimvar SUPRA_SP ':'
  case `uname` in
    CYGWIN*)
      for i in `echo $SUPRA_SP | tr ':' ' '`; do
        SUPRA_SP_CMAKE="$SUPRA_SP_CMAKE"\;`cygpath -am $i`
      done
      trimvar SUPRA_SP_CMAKE ';'
      ;;
    *)
      SUPRA_SP_CMAKE=`echo "$SUPRA_SP" | sed 's/:/;/g'`
      ;;
  esac
  CONFIG_SUPRA_SP_ARG=--with-supra-search-path=$SUPRA_SP
  CMAKE_SUPRA_SP_ARG="-DSUPRA_SEARCH_PATH:PATH='$SUPRA_SP_CMAKE'"

  if $FORCE_INSTALL; then
    techo -2 "Modified packages will be installed."
  fi

  if test -n "$NOBUILD_PKGS"; then
    nobldpkgs=`echo $NOBUILD_PKGS | tr ',a-z-' ' A-Z-'`
    techo "Not building $nobldpkgs."
    for i in $nobldpkgs; do
      eval ${i}_BUILDS=NONE
    done
  fi

  if test -n "$FORCEBUILD_PKGS"; then
    forcebldpkgs=`echo $FORCEBUILD_PKGS | tr ',a-z-' ' A-Z-'`
    techo "Forcing builds of $forcebldpkgs from the command line."
    for i in $forcebldpkgs; do
     local forcevar=`genbashvar ${i}`_FORCEBUILD
     eval $forcevar=true
    done
  fi

}

# By default, set the options, but allow not doing so.
SET_BILDER_OPTIONS=${SET_BILDER_OPTIONS:-"true"}
if $SET_BILDER_OPTIONS; then
  setBilderOptions $*
  techo -2 "OPTIND = $OPTIND.  BILDER_OPTIND = $BILDER_OPTIND."
# Have to shift args at this level.  OPTIND apparently has method scope.
  shift $(($BILDER_OPTIND - 1))
fi

