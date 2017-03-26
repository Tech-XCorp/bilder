#!/bin/sh
######################################################################
#
# @file    wrapmsvc.sh
#
# @brief   Wrapper script for the Microsoft Visual C++ compiler (cl) to
#          allow it to work with Cygwin based makefiles.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# http://comments.gmane.org/gmane.os.cygwin/16874
#
######################################################################

cmd=cl

for option; do
  case $option in
    -I/*)
      path=`expr $option : '-I/\(.*\\)'`
      cmd="$cmd \"-I`cygpath -m $path`\""
      ;;
    /*)
      # path=`expr $option : '/\(.*\\)'`
      path=`cygpath -u $option`
      cmd="$cmd $path"
      ;;
    *)
      cmd="$cmd $option"
      ;;
  esac
done

echo "$cmd"
eval "$cmd"

