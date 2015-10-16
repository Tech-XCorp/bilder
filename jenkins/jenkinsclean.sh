#!/bin/sh

# The artifacts we want to save are mk*all.sh and what is
# removed below, except that jenkins uses comma separators

# These artifacts are already created at clean time
keepartifacts='jenkinsbild.log,builds*/*.log'
# These artifacts can be cleaned
rmartifacts='builds*/bilderenv.txt,builds*/*-summary.txt,builds*/*-chain.txt,*/*-preconfig.sh,*/preconfig.txt,builds*/*/*/*-config.sh,builds*/*/*/*-config.txt,builds*/*/*/*-build.sh,builds*/*/*/*-build.txt,builds*/*/*/*-install.sh,builds*/*/*/*-install.txt,builds*/*/*/*-test.sh,builds*/*/*/*-test.txt,*tests/*-config.sh,*tests/*-config.txt,*tests/*-build.sh,*tests/*-build.txt,*tests/*-install.sh,*tests/*-install.txt,*tests/runtxtest*.txt,*tests/check*.txt,*tests/check.*'
echo "Removing artifacts, $rmartifacts in $PWD."
bashartifacts=`echo $rmartifacts | sed 's/,/ /g'`
cmd="rm -f $bashartifacts"
echo "$cmd"
echo "Not executing."
# eval "$cmd"

