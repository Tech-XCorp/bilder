#!/bin/sh
######################################################################
#
# @file    getvsvars.sh
#
# @brief   Documentation goes here.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

# Set the version of vs
vsver=9

deref() {
  eval echo $`echo $1`
}

# Get the windows variables
cat >getvsvars.bat <<EOF
@echo off
echo PATHOLD="%PATH%"
call "%VS${vsver}0COMNTOOLS%vsvars32.bat" >NUL:
echo PATHNEW="%PATH%"
echo LIBPATH_VS${vsver}="%LIBPATH%"
echo LIB_VS${vsver}="%LIB%"
echo INCLUDE_VS${vsver}="%INCLUDE%"
EOF
cmd /c getvsvars.bat | tr -d '\r' >vsvarswin.sh
source vsvarswin.sh

# Get the path difference
PATHOLDM=`echo "$PATHOLD" | sed -e 's?\\\\?/?g'`
PATHNEWM=`echo "$PATHNEW" | sed -e 's?\\\\?/?g'`
PATH_VAL=`echo "$PATHNEWM" | sed -e "s?$PATHOLDM??g"`
# echo "$PATH_VAL" | sed -e "s?;?\
# ?g" > path.txt

# Convert the paths to cygwin
rm -f path.txt
echo "$PATH_VAL" | tr ';' '\n' | sed '/^$/d' | while read line; do
  cygpath -au "$line": >> path.txt
done
PATH_CYG=`cat path.txt | tr -d '\n' | sed 's/:$//'`
echo PATH_CYG = "$PATH_CYG"
eval PATH_VS${vsver}="\"$PATH_CYG\""
echo PATH_VS9 = $PATH_VS9

