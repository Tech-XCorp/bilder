#!/bin/bash
#
# $Id$
#
# Get other repos that aren't normally needed for
#
######################################################################

if test -e $SCRIPT_DIR/bilder/runnr/runnrfcns.sh; then
  source $SCRIPT_DIR/bilder/runnr/runnrfcns.sh
fi

host=$UQMAILHOST

#---------------------------------------------------------------

#
# checkout or update a repository
#
# Args:
# 1: The local directory where the repo will (or already does) reside
# 2: The repository URL
# 3: The repo branch to check out (git only, optional)
#
# Named args (must come first):
# -g: We are working with (or creating) a git repo (svn is the default)
#
# Returns 0 on success non-zero on failure
#
getRepo() {

# Get options
  local repotype="SVN"
  while test -n "$1"; do
    case "$1" in
      -g)
        repotype="GIT"
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  local localDir=$1
  local repoUrl=$2
  local gitBranch=$3
  if test -d $localDir; then
    cd $localDir
    if test $repotype == "SVN"; then
      echo "Running svn up on $PWD"
      svn up
      res=$?
    elif test $repotype == "GIT"; then
      echo "Running git pull on $PWD"
      git pull
      res=$?
    else
      echo "Unknown repository type, $repotype, do not know how to update"
      res=1
    fi
    cd ..
  else
    if test $repotype == "SVN"; then
      svn co $repoUrl $localDir
      res=$?
    elif test $repotype == "GIT"; then
      if test -z "$gitBranch"; then
        git clone $repoUrl $localDir
        res=$?
      else
        git clone --no-checkout $repoUrl $localDir
	res=$?
	if test $res = 0; then
          cd $localDir
          res=$?
	fi
	if test $res = 0; then
          git checkout -b "${gitBranch}" "origin/${gitBranch}"
          res=$?
	  cd ..
	fi
      fi
    else
      echo "Unknown repository type, $repotype, do not know how to create"
      res=1
    fi
  fi
  return $res
}

#
# checkout or update a list of repositories
# Requires that repo_root be set to the head of all repositories in the list
# Assumes that each repo has a trunk to check out.
#
# Args:
# 1: A space-separated list of repository names
#
getRepos() {
  local repoList=$1
  for repo_name in $repoList; do
    repo=${repo_root}"/"${repo_name}"/trunk"
    getRepo $repo_name $repo
  done
}

getResults() {
  testdir=$1
  cd $1
  resrootdir=`svn info | grep URL: | cut -f2- -d: | sed s@/code@/results@g | sed s/tests/results/g`
  resname=`echo $testdir | sed s/tests/results/g `
  hostversions=`svn ls $resrootdir | grep $host `
  if test -z $hostversions; then
      echo "No accepted results found for $testdir on machine $host"
      echo Searched: $resrootdir
  else
      echo "Available versions: $hostversions"
  fi
  for hv in $hostversions; do
    svn co $resrootdir/$hv $resname-$hv
  done
  cd ..
}

