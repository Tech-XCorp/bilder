#!/bin/bash
#
# Version and build information for OpenSplice
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

OPENSPLICE_BLDRVERSION=${OPENSPLICE_BLDRVERSION:-"5.4.1"}

# Built from package only
######################################################################
#
# Other values
#
######################################################################

OPENSPLICE_BUILDS=${OPENSPLICE_BUILDS:-"ser"}
OPENSPLICE_UMASK=002


######################################################################
#
# Launch opensplice builds.
#
######################################################################

buildOpensplice() {
  if bilderUnpack -i opensplice; then
    if bilderConfig -m " " opensplice ser; then
      bilderBuild -k -m "source configure; make clean; make; make install" opensplice ser
    fi
  fi
}


######################################################################
#
# Test opensplice
#
######################################################################

testOpensplice() {
  techo "Not testing opensplice."
}

######################################################################
#
# Install opensplice
#
######################################################################
installOpensplice() {
  # If there was a build, the builddir was set
  local builddirvar=`genbashvar opensplice-ser`_BUILD_DIR
  local builddir=`deref $builddirvar`
  local vervar=`genbashvar opensplice`_BLDRVERSION
  local verval=`deref $vervar`
  local instsubdirvar=`genbashvar opensplice-ser`_INSTALL_SUBDIR
  local instsubdirval=`deref $instsubdirvar`
  local instdirvar=`genbashvar opensplice`_INSTALL_DIR
  local instdirval=`deref $instdirvar`

  if test -z "$builddir"; then
    techo "Not installing opensplice-$OPENSPLICE_BLDRVERSION-ser since not built."
    # Check if opensplice install is available in the install dir and
    # set OSPL_HOME env var, needed for SimD build
    if test -L $instdirval/opensplice -o -d $instdirval/opensplice; then
      local ospldir=`(cd $instdirval/opensplice; pwd -P)`
      export OSPL_HOME=$ospldir
    fi
    return 1
  fi
  local res
  waitBuild opensplice-ser
  resvarname=`genbashvar opensplice_ser`_RES
  res=`deref $resvarname`
  if test "$res" != 0; then
    techo "Not installing opensplice-$OPENSPLICE_BLDRVERSION-ser since did not build."
    return 1
  fi
  techo "opensplice-$OPENSPLICE_BLDRVERSION-ser was built."
  
  #
  # If here, ready to install.  Determine whether to do so.
  #
  techo "Proceeding to install."
  # Validation
  if test -z "$builddir"; then
    techo "Catastrophic error.  builddir unknown or cannot cd to $builddir."
    exit 1
  fi
  techo "Installing opensplice-$OPENSPLICE_BLDRVERSION-ser into $instdirval at `date` from $builddir."

  # Set umask, install, restore umask
  local umaskvar=`genbashvar opensplice`_UMASK
  local umaskval=`deref $umaskvar`
  if test -z "$umaskval"; then
    techo "Catastrophic error.  $umaskvar not set."
    exit 1
  fi
  local origumask=`umask`
  umask $umaskval

  cmd="rmall $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser"
  $cmd
  cmd="mkdir $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser"
  $cmd
  cmd="cp -R $builddir/install/HDE $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser/HDE"
  techo "$cmd" | tee install.out
  $cmd 1>>install.out 2>&1
  cmd="cp -R $OPENSPLICE_PATCH $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser/"
  techo "$cmd" | tee install.out
  $cmd 1>>install.out 2>&1
  RESULT=$?
  # If installed, record
  techo "Installation of opensplice-$OPENSPLICE_BLDRVERSION-ser concluded at `date` with result = $RESULT."
  if test $RESULT = 0; then
    techo "Replace @@INSTALLDIR@@ with $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser in $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser/HDE/x86_64.linux2.6/release.com" | tee install.out
    cmd="sed -i \"s#@@INSTALLDIR@@#$instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser#g\" $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser/HDE/x86_64.linux2.6/release.com"
    techo "$cmd" | tee install.out
    eval $cmd

    # Source the release.com file, so the opensplice env vars are
    # available for other packages that need it
    techo "Sourcing release.com to set the opensplice enironment variables" | tee install.out
    cmd="source $instdirval/opensplice-$OPENSPLICE_BLDRVERSION-ser/HDE/x86_64.linux2.6/release.com"

    echo SUCCESS >>install.out

    # Record installation in installation directory
    techo "Recording installation of opensplice-$OPENSPLICE_BLDRVERSION-ser."
    cmd="${PROJECT_DIR}/bilder/setinstald.sh -b $BILDER_PACKAGE -i $CONTRIB_DIR opensplice,ser"
    techo "$cmd"
    $cmd

    # Link to common name
    local linkname
    linkname=opensplice
    if test -n "$linkname" -a $instsubdirval != '-'; then
      # Do not try to link if install directory does not exist
      local subdir
      subdir=opensplice-$OPENSPLICE_BLDRVERSION-ser/HDE/x86_64.linux2.6
      if test -d "$instdirval/$instsubdirval"; then
        techo "Linking $instdirval/$subdir to $instdirval/$linkname"
        mkLink $linkargs $instdirval $subdir $linkname
      else
        techo "WARNING: Not linking $instdirval/$subdir to $instdirval/$linkname because $instdirval/$instsubdirval can not be found or installation subdir contains /."
      fi
    else
      techo "Not making an installation link."
    fi

    # Fix perms that libtool sometimes botches
    # subdir may not exist if installed at top
    if test -d "$instdirval/$instsubdirval"; then
      case $umaskval in
        000? | 00? | ?)  # printing format can vary.
          chmod -R g+wX $instdirval/$instsubdirval
            ;;
      esac
      case $umaskval in
        0002 | 002 | 2)
          chmod -R o+rX $instdirval/$instsubdirval
          ;;
      esac
    fi

    # Record build time
    techo "opensplice-ser installed."
    local starttimevar=`genbashvar opensplice`_START_TIME
    local starttimeval=`deref $starttimevar`
    decho "$starttimevar = $starttimeval"
    local endtimeval=`date +%s`
    local buildtime=`expr $endtimeval - $starttimeval`
    techo "opensplice-ser took `myTime $buildtime` to build and install." | tee -a $BILDER_LOGDIR/timers.txt

  else
    installFailures="$installFailures $1-$2"
    anyFailures="$anyFailures $1-$2"
    techo "$1-$2 failed to install."
    echo FAILURE >>install.out
  fi
  # umask restoration here so that links and installations.txt okay
  umask $origumask

  # Check if opensplice install is available in the install dir and
  # set OSPL_HOME env var, needed for SimD build
  if test -L $instdirval/opensplice -o -d $instdirval/opensplice; then
    local ospldir=`(cd $instdirval/opensplice; pwd -P)`
    export OSPL_HOME=$ospldir
    techo "OSPL_HOME = $OSPL_HOME"
  fi

return $RESULT
}

