#!/bin/sh
######################################################################
#
# @file    extrepodrive.sh
#
# @brief   Get other repos that aren't normally needed for Bilder.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

usage() {
    echo "Usage: $0 [options]"
    echo "  -h      print this message"
    echo "  -a      checkout or update all repos in the list of repositories"
    echo "          (Default shown below)"
    echo "  -l      specify a repo list (space delimited)"
    echo "          repository will be of form: <repository_root><repo_name><trunk>"
    echo "  -r      specify a different repository root"
    echo "  -t      attempt to get the accepted_results for the tests (see below)"
    echo
    echo "Default repository root: " $repo_root
    echo "All repos in defaults: "
    echo " " $repos
    echo "All tests to get accepted results for: "
    echo " " $tests
    exit 0
}

while getopts "ahl:r:s:t" arg; do
  case "$arg" in
    h) usage;;
    a) GET_ALL=true;;
    l) GET_ALL=true; repos=$OPTARG;;
    r) repo_root=$OPTARG;;
    t) GET_RESULTS=true;;
    *) echo Option $arg not recognized.
       usage;;
  esac
done

## Get external repos
if $GET_ALL; then
   getRepos "$repos"
## Get the results for the appropriate host and version
elif $GET_RESULTS; then
  for test_name in $tests; do
        getResults $test_name
  done
else
      usage
fi
