#!/bin/bash
#
# Version and build information for qscintilla
#
# $Id: qscintilla.sh 5963 2012-05-04 22:00:36Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

QSCINTILLA_BLDRVERSION=${QSCINTILLA_BLDRVERSION:-"gpl-2.3.2"}

######################################################################
#
# Other values
#
######################################################################

QSCINTILLA_BUILDS=${QSCINTILLA_BUILDS:-"ser"}
QSCINTILLA_DEPS=qt

######################################################################
#
# Launch qscintilla builds.
#
######################################################################

buildQScintilla() {

# If qscintilla dll present, reinstall.
  # if false; then
  techo
  local libdir=$CONTRIB_DIR/QScintilla-${QSCINTILLA_BLDRVERSION}-ser/lib
  for sfx in dll so dylib; do
    case $sfx in
      dll) prfx=;;
      *) prfx=lib;;
    esac
    echo -n "Checking for $libdir/${prfx}qscintilla2.$sfx ..."
    if test -f $libdir/${prfx}qscintilla2.$sfx; then
      techo "found."
      cmd="$BILDER_DIR/setinstald.sh -ri $CONTRIB_DIR QScintilla,ser"
      techo "$cmd"
      $cmd
      break
    else
      techo "not found."
    fi
  done
  # fi

# Unpack in place
  if bilderUnpack -i QScintilla; then

# Make libraries static
# If you want to change the configuration then edit the file
# qscintilla.pro in the Qt4 directory. For example, if you
# want to build a static library, edit the value of CONFIG and
# replace dll with staticlib, and edit the value of DEFINES and
# remove QSCINTILLA_MAKE_DLL.
# 2011-05-19, JRC: this now done by the patch
    # cmd="sed -i.bak -e s/dll/staticlib/ -e s/QSCINTILLA_MAKE_DLL// $BUILD_DIR/QScintilla-${QSCINTILLA_BLDRVERSION}/ser/Qt4/qscintilla.pro"
    # techo "$cmd"
    # $cmd

# Extra system build args
    local QSCINTILLA_MAKE_ARGS
    case `uname` in
      Linux)
        QSCINTILLA_MAKE_ARGS="$JMAKEARGS"
        ;;
      *)	# make -j can fail on Darwin
        QSCINTILLA_MAKE_ARGS=""
        ;;
    esac

# We cannot just define QSCINTILLA_INSTALL_DIR for pick up by qscintilla.pro,
# as then the post-install links and recording are not done right.
# So we define it as a local variable and use it at invocation.
    qscinstdir=$CONTRIB_DIR/QScintilla-${QSCINTILLA_BLDRVERSION}-ser
    case `uname` in
      CYGWIN*)
        qscinstdir=`cygpath -am $qscinstdir`
        ;;
    esac

# qmake generates Makefiles by default, hence use bilderConfig
# QMAKESPECARG seems necessary on windows.
# QScintilla does not understand prefix
# qscintilla_release.pro file mucks up the installation paths
   if bilderConfig -i -q "Qt4/qscintilla.pro" QScintilla ser "$QMAKESPECARG" "" "QSCINTILLA_INSTALL_DIR=$qscinstdir"; then
# Build
      bilderBuild QScintilla ser "$QSCINTILLA_MAKE_ARGS"
    fi
  fi

}

######################################################################
#
# Test qscintilla
#
######################################################################

testQScintilla() {
  techo "Not testing qscintilla."
}

######################################################################
#
# Install qscintilla
#
######################################################################

installQScintilla() {
  if false; then
  local qscinstdir=$CONTRIB_DIR/QScintilla-${QSCINTILLA_BLDRVERSION}-ser
  case `uname` in
    CYGWIN*)
      qscinstdir=`cygpath -am $qscinstdir`
      ;;
  esac
  fi
# QScintilla does not understand prefix, so we have to set it here
  # if bilderInstall QScintilla ser "" "INSTALL_ROOT=$qscinstdir"; then
  if bilderInstall -r QScintilla ser; then
    cmd="mkLink $CONTRIB_DIR QScintilla-${QSCINTILLA_BLDRVERSION}-ser QScintilla"
    techo "$cmd"
    $cmd
  fi
}

