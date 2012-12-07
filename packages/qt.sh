# #!/bin/bash
#
# Version and build information for qt.  Latest source packages
# available from http://get.qt.nokia.com/qt/source/.
# 20121125: Moved to http://qt-project.org/downloads.
#
# These have to be unpacked and repacked for Bilder standards.  E.g.:
#   tar xzf qt-everywhere-opensource-src-4.8.3.tar.gz
#   mv qt-everywhere-opensource-src-4.8.3 qt-4.8.3
#   tar cjf qt-4.8.3.tar.bz2 qt-4.8.3
# OR
#   tar xzf qt-everywhere-opensource-src-5.0.0-beta2.tar.gz
#   mv qt-everywhere-opensource-src-5.0.0-beta2 qt-5.0.0b2
#   tar cjf qt-5.0.0b2.tar.bz2 qt-5.0.0b2
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

case `uname`-`uname -r` in
  Darwin-12.2.*) QT_BLDRVERSION_STD=4.8.3;;
  *) QT_BLDRVERSION_STD=4.8.1;;
esac
QT_BLDRVERSION_EXP=4.8.3

######################################################################
#
# Other values
#
######################################################################

QT_BUILDS=${QT_BUILDS:-"ser"}
QT_DEPS=bzip2

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/qt/bin

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
  if bilderUnpack -i qt; then

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
      Linux)
# Adding to the LD_RUN_PATH gets rpath set for the qt libs.
# Adding to the LD_LIBRARY_PATH gets around the missing QtCLucene link bug.
# To get around bash space separation of string, we separate env settings
# with a comma.
        local extras_libdir=
        if test -e $CONTRIB_DIR/extras/lib; then
          extras_libdir=$CONTRIB_DIR/extras/lib
        fi
        # QT_ENV="LD_RUN_PATH=${CONTRIB_DIR}/mesa-mgl/lib:${extras_libdir}:$LD_RUN_PATH LD_LIBRARY_PATH=$BUILD_DIR/qt-$QT_BLDRVERSION/ser/lib:${extras_libdir}:$LD_LIBRARY_PATH"
        QT_ENV="LD_RUN_PATH=${CONTRIB_DIR}/mesa-mgl/lib:$LD_RUN_PATH LD_LIBRARY_PATH=$BUILD_DIR/qt-$QT_BLDRVERSION/ser/lib:$LD_LIBRARY_PATH"
        if test -n "${extras_libdir}"; then
          QT_PHONON_ARGS="$QT_PHONON_ARGS -L$extras_libdir"
        fi
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
# Then add.  Needed for configuration, but not for build.
#  -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include
#  -I/usr/include/gstreamer-0.10 -I/usr/include/libxml2
        local incdir=
        local libdir=
        for i in gstreamer libxml2; do
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
          if test -n "$libdir"; then
            QT_PHONON_ARGS="$QT_PHONON_ARGS -L$libdir"
          fi
        done
# glib a little special to deal with versions
        incdir=`ls -1d /usr/include/glib-* 2>/dev/null | tail -1`
        if test -n "$incdir"; then
          local glibbn=`basename $incdir`
          QT_PHONON_ARGS="$QT_PHONON_ARGS -I$incdir -I/usr/lib64/$glibbn/include"
# Adjust for possible change to typedef in glib
          if grep -q 'union *_GMutex' $incdir/glib/gthread.h; then
            techo "Adjusting Qt for change in gthread.h."
            local qtgtypedefs=$BUILD_DIR/qt-$QT_BLDRVERSION/ser/src/3rdparty/webkit/Source/JavaScriptCore/wtf/gobject/GTypedefs.h
            cmd="sed -i.bak 's/struct _GMutex/union _GMutex/' $qtgtypedefs"
            techo "$cmd"
            eval "$cmd"
          fi
        else
          techo "WARNING: [qt.sh] May need to install glib-devel."
        fi
        local gstprobe=`find /usr/include -name gstappsrc.h`
        if test -z "$gstprobe"; then
          techo "WARNING: [qt.sh] May need to install gstreamer-plugins-base-devel."
        fi
        ;;
      Darwin)
        local PLATFORM=macx-g++
# jpeg present, but qt cannot find headers
        QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -platform macx-g++ -no-gif"
        case `uname -r` in
          10.*)
            case `uname -m` in
              i386) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -arch x86_64";;
            esac
            ;;
        esac
        case $QT_BLDRVERSION in
          5.*) ;;
          *) QT_PLATFORM_ARGS="$QT_PLATFORM_ARGS -cocoa";;
        esac
        ;;
    esac

# PyQt will not build on Linux when Qt is built without phonon, so restoring.
# Phonon is also required for WebKit, which the composers need.
# On Linux, this requires glib-devel and gstreamer-plugins-base-devel
    QT_WITH_PHONON=${QT_WITH_PHONON:-"true"}
    if ! $QT_WITH_PHONON; then
      techo "NOTE: Building Qt without phonon."
      QT_PHONON_ARGS=-no-phonon
    fi

# Version dependent args.
# make -j does not work with 5, apparently.
    case $QT_BLDRVERSION in
      5.*)
        QT_VERSION_ARGS="-no-c++11"
        ;;
      *)
        QT_VERSION_ARGS="-buildkey bilder -no-libtiff -no-scripttools -webkit $QT_PHONON_ARGS"
        QT_MAKEJ_USEARGS="$QT_MAKEJ_ARGS"
        ;;
    esac

# Restore dbus and xmlpatterns or get wrong one
    # techo "Before qt's bilderConfig, QT_SER_INSTALL_DIR=$QT_SER_INSTALL_DIR."
    if bilderConfig -i qt ser "$QT_PLATFORM_ARGS $QT_VERSION_ARGS -confirm-license -make libs -make tools -fast -opensource -opengl -no-separate-debug-info -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-tds -no-javascript-jit $QT_SER_OTHER_ARGS" "" "$QT_ENV"; then
      # techo exit; exit
# Make clean seems to hang
      bilderBuild -k qt ser "$QT_MAKEJ_USEARGS" "$QT_ENV"
    else
# Remove linked file if present
      if $QT_GXX_LINKED; then
        rm ${CONTRIB_DIR}/bin/g++
      fi
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

# Fix up various problems with QT installations
#
fixQtInstall() {
# Remove linked file if present
  if $QT_GXX_LINKED; then
    rm ${CONTRIB_DIR}/bin/g++
  fi
# Fix the bad node that Qt leaves behind on a Darwin installation.
# (Seems not to do this on an overinstallation?)
  case `uname` in
    Darwin)
      local badnode="$CONTRIB_DIR/qt-$QT_BLDRVERSION-ser/lib/QtTest.framework/Versions/4/4"
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
# Set the perms to open for Qt.
  setOpenPerms $CONTRIB_DIR/qt-$QT_BLDRVERSION-ser
}

installQt() {

  local qt_tried=false
  if test -n "$QT_SER_PID"; then
    qt_tried=true
  fi
  if bilderInstall -r qt ser; then
    fixQtInstall
    findQt
  elif $qt_tried; then
    cat <<EOF | tee -a $LOGFILE
Qt failed to build.  Bilder will try the following:
  cd $BUILD_DIR/qt-$QT_BLDRVERSION/ser
  make -i install
and then follow with the usual installation.
EOF
    cd $BUILD_DIR/qt-$QT_BLDRVERSION/ser
    make -i install 2>&1 | tee qt-install2.txt
    bilderBuild qt ser "$QT_MAKEJ_ARGS"
    if bilderInstall -r qt ser; then
      fixQtInstall
      findQt
    else
      techo "Extra build steps failed."
    fi
  fi
  # techo "Quitting at end of qt.sh."; exit

}

