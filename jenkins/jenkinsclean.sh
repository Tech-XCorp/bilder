#!/bin/sh

# The artifacts we want to save are mk*all.sh and what is
# removed below, except that jenkins uses comma separators

artifacts='jenkinsbild.log,builds*/bilderenv.txt,builds*/*-summary.txt,builds*/*.log,builds*/*-chain.txt,*/*-preconfig.sh,*/preconfig.txt,builds*/*/*/*-config.sh,builds*/*/*/*-config.txt,builds*/*/*/*-build.sh,builds*/*/*/*-build.txt,builds*/*/*/*-install.sh,builds*/*/*/*-install.txt,builds*/*/*/*-test.sh,builds*/*/*/*-test.txt,*tests/*-config.sh,*tests/*-config.txt,*tests/*-build.sh,*tests/*-build.txt,*tests/*-install.sh,*tests/*-install.txt,*tests/runtxtest*.txt,*tests/check*.txt,*tests/check.*'
echo "Removing artifacts, $artifacts."
bashartifacts=`echo $artifacts | sed 's/,/ /g'`
cmd="rm -f $bashartifacts"
echo "$cmd"
eval "$cmd"

