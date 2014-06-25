# #!/bin/bash
#
# Build information for qt.
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in qt_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/qt_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setQtNonTriggerVars() {
  QT_UMASK=002
}
setQtNonTriggerVars

######################################################################
#
# Launch qt builds.
#
######################################################################

buildQt() {

# Qt requires g++ to have that precise name
# If different, link it into contrib's bin dir.
  QT_GXX_LINKED=false

# QT must be built in place
  if ! bilderUnpack -i qt; then
    return
  fi

# Set the link as needed
  case `uname` in
    Linux | Darwin)
      if test "$(basename $PYC_CXX)" != g++ -a ! -f ${CONTRIB_DIR}/bin/g++; then
        QT_GXX_LINKED=true
        mkdir -p ${CONTRIB_DIR}/bin
        ln -s `which $PYC_CXX` ${CONTRIB_DIR}/bin/g++
        addtopathvar PATH $CONTRIB_DIR/bin
      fi
      ;;
  esac

# Get variables.  Per platform.  Just do mac for now.
  local QT_PLATFORM_ARGS=
  local QT_ENV=
  local QT_PHONON_ARGS=-phonon
  case `uname` in

    CYGWIN*)
      case $CC in
        *cl)
          case ${VISUALSTUDIO_VERSION} in
            9)  QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -spec win32-msvc2008";;
            10) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -spec win32-msvc2010";;
            11) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -spec win32-msvc2012";;
          esac
          ;;
        *mingw*)
          ;;
      esac
      ;;

    Darwin)
# jpeg present, but qt cannot find headers
      QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -spec macx-g++ -r -qt-libpng"
      case `uname -r` in
        13.*)
# This will need to be clang
          QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform macx-g++ -no-gif"
          ;;
        1[0-2].*)
          case `uname -m` in
            i386) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -arch x86_64";;
            *)
              QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform macx-g++ -no-gif"
              ;;
          esac
          ;;
      esac
      case $QT_BLDRVERSION in
        5.*) ;;
        *) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -cocoa";;
      esac
      ;;

    Linux)
# Adding to the LD_RUN_PATH gets rpath set for the qt libs.
# Adding to the LD_LIBRARY_PATH gets around the missing QtCLucene link bug.
# To get around bash space separation of string, we separate env settings
# with a comma.
      QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -spec linux-g++ -r -system-libpng"
      QT_ENV="LD_RUN_PATH=${CONTRIB_DIR}/mesa-mgl/lib:$LD_RUN_PATH LD_LIBRARY_PATH=$BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD/lib:$LD_LIBRARY_PATH"
      case `uname -m` in
        x86_64)
          QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform linux-g++-64"
          ;;
        *)
          QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform linux-g++"
          ;;
      esac

# Need the following for phonon (and for webkit):
#   glib
#   gstreamer-devel
#   gstreamer-plugins-base-devel
#   libxml2
# For some systems, like the Crays, we have to build our own version of
# glib, gstreamer, and xml2, which we do using extras/gstreamer.sh.
# Look for that, and if present add the appropriate flags.
# These should perhaps be Bilderized, but the resulting separate-dir
# installation would make the qt flags a bit more complications
      local extras_libdir=
      if test -e $CONTRIB_DIR/extras/lib; then
        extras_libdir=$CONTRIB_DIR/extras/lib
      fi
      if test -n "${extras_libdir}"; then
        QT_PHONON_ARGS="$QT_PHONON_ARGS -L$extras_libdir"
      fi

# Add system include directories if present.  This should not be duplication,
# as the above should be built only when these are not found.
# The paths on redhat are:
#  -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include
#  -I/usr/include/gstreamer-0.10 -I/usr/include/libxml2
      local incdir=
      local libdir=
# qt will not compile with gstreamer-1.0, so specifically look for 0.10
      for i in gstreamer-0.10 libxml2; do
# Get the latest
        incdir=`ls -1d /usr/include/$i{,-*} 2>/dev/null | tail -1`
        if test -z "$incdir"; then
          incdir=`ls -1d $CONTRIB_DIR/extras/include/$i{,-*} 2>/dev/null | tail -1`
        fi
        if test -n "$incdir"; then
          QT_PHONON_ARGS="$QT_PHONON_ARGS -I$incdir"
        else
          techo "WARNING: [qt.sh] May need to install ${i}-devel."
        fi
# Looks like this is not used?
        # if test -n "$libdir"; then
          # QT_PHONON_ARGS="$QT_PHONON_ARGS -L$libdir"
        # fi
      done
# glib a little special to deal with versions
      incdir=`ls -1d /usr/include/glib-* 2>/dev/null | tail -1`
      if test -n "$incdir"; then
        QT_PHONON_ARGS="$QT_PHONON_ARGS -I$incdir"
      else
        techo "WARNING: [qt.sh] May need to install glib-devel."
      fi
# On different distros, this include directory can be in different places
      local glibbn=`basename $incdir`
      if test "i686" == `uname -m`; then
        srchdirs="lib lib64 lib/x86_64-linux-gnu"
      else
        srchdirs="lib64 lib/x86_64-linux-gnu lib"
      fi
      local glibincdir=
      for l in $srchdirs; do
        if test -d /usr/$l/$glibbn/include; then
          glibincdir=/usr/$l/$glibbn/include
          break
        fi
      done
      if test -n "$glibincdir"; then
        QT_PHONON_ARGS="$QT_PHONON_ARGS -I$glibincdir"
      else
        techo "WARNING: [qt.sh] glib word-size include dir not found."
        techo "WARNING: [qt.sh] May need to install glib-devel."
      fi
      local gstprobe=`find /usr/include -name gstappsrc.h`
      if test -z "$gstprobe"; then
        techo "WARNING: [qt.sh] May need to install gstreamer-plugins-base-devel."
      fi
# Adjust for possible change to typedef in glib
      if grep -q 'union *_GMutex' $incdir/glib/gthread.h; then
        techo "Adjusting Qt for change in gthread.h."
        local qtgtypedefs=$BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD/src/3rdparty/webkit/Source/JavaScriptCore/wtf/gobject/GTypedefs.h
        cmd="sed -i.bak 's/struct _GMutex/union _GMutex/' $qtgtypedefs"
        techo "$cmd"
        eval "$cmd"
      fi
      ;;

  esac
  trimvar QT_PLATFORM_ARGS ' '

# PyQt will not build on Linux when Qt is built without phonon, so restoring.
# Phonon is also required for WebKit, which the composers need.
# On Linux, this requires glib-devel and gstreamer-plugins-base-devel
  QT_WITH_PHONON=${QT_WITH_PHONON:-"true"}
  if ! $QT_WITH_PHONON; then
    techo "NOTE: Building Qt without phonon."
    QT_PHONON_ARGS=-no-phonon
  fi

# Version dependent args
# qt-5 configures differently
# make -j does not work with 4.8.6, apparently.
  case $QT_BLDRVERSION in
    5.*)
      QT_VERSION_ARGS="-developer-build"
      ;;
    4.8.6)
      QT_VERSION_ARGS="-buildkey bilder -no-libtiff -declarative -webkit $QT_PHONON_ARGS"
      ;;
    4.*)
      QT_VERSION_ARGS="-buildkey bilder -no-libtiff -declarative -webkit $QT_PHONON_ARGS"
      QT_MAKEJ_USEARGS="$QT_MAKEJ_ARGS"
      ;;
  esac

# Restore dbus and xmlpatterns or get wrong one
  local qtotherargs=`deref QT_${QT_BUILD}_OTHER_ARGS`
  if bilderConfig -i qt $QT_BUILD "$QT_PLATFORM_ARGS $QT_VERSION_ARGS -confirm-license -make libs -make tools -fast -opensource -opengl -no-separate-debug-info -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-tds -no-javascript-jit -nomake docs -nomake examples -nomake demos $qtotherargs" "" "$QT_ENV"; then
# Make clean seems to hang
    bilderBuild -k qt $QT_BUILD "$QT_MAKEJ_USEARGS" "$QT_ENV"
  else
# Remove linked file if present
    if $QT_GXX_LINKED; then
      rm -f ${CONTRIB_DIR}/bin/g++
    fi
  fi
}

######################################################################
#
# Test qt
#
######################################################################

testQt() {
  techo "Not testing qt."
}

######################################################################
#
# Install qt
#
######################################################################

#
# Fix up various problems (bad links) with QT installations
# We used to change the installation names of qt in VisIt, but now
# VisIt takes care of that in its build system.
#
fixQtInstall() {
# Remove linked file if present
  if $QT_GXX_LINKED; then
    rm -f ${CONTRIB_DIR}/bin/g++
  fi
# Fix the bad node that Qt leaves behind on a Darwin installation.
# (Seems not to do this on an overinstallation?)
  case `uname` in
    Darwin)
      local badnode="$CONTRIB_DIR/qt-$QT_BLDRVERSION-$QT_BUILD/lib/QtTest.framework/Versions/4/4"
      if test -L $badnode; then
        techo "NOTE: Removing leftover link from qt installation, $badnode."
        cmd="chmod -h u+rwx $badnode"
        techo "$cmd"
        $cmd
        cmd="rm $badnode"
        techo "$cmd"
        $cmd
      fi
      if test -L $badnode; then
        techo "WARNING: Unable to remove leftover link, $badnode, from qt installation.  Must be done as root."
      fi
      ;;
  esac
}

#
# Install Qt
#
installQt() {
  local qt_tried=false
  local qtpid=`deref QT_${QT_BUILD}_PID`
  if test -n "$qtpid"; then
    qt_tried=true
  fi
  if bilderInstall -r -p open qt $QT_BUILD; then
    fixQtInstall
  elif $qt_tried; then
    cat <<EOF | tee -a $LOGFILE
Qt failed to build.  Bilder will try the following:
  cd $BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD
  make -i install
and then follow with the usual installation.
EOF
    cd $BUILD_DIR/qt-$QT_BLDRVERSION/$QT_BUILD
    make -i install 2>&1 | tee qt-install2.txt
    bilderBuild qt $QT_BUILD "$QT_MAKEJ_ARGS"
    if bilderInstall -r -p open qt $QT_BUILD; then
      fixQtInstall
    else
      techo "Extra build steps failed."
    fi
  fi
}

