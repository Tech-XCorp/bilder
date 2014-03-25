#!/bin/sh
#
# Wrapper script for the Microsoft Visual C++ compiler (cl) to allow it
# to work with Cygwin based makefiles.
#
# http://comments.gmane.org/gmane.os.cygwin/16874

# cmd="/c/Program\ Files/Microsoft\ Visual\ Studio/VC98/Bin/cl"
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

