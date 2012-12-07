#!/bin/bash
git clone git::gitorious.org/qt/qt3d.git qt3d
cd qt3d
git checkout --track -b qt4 origin/qt4
mkdir ser && cd ser
qmake ../qt3d.pro
