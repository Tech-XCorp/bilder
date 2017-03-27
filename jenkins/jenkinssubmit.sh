#!/bin/sh
######################################################################
#
# @file    jenkinssubmit.sh
#
# @brief   Launch a test job on Jenkins.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Builds
#
# To launch a test job on the Jenkins server through an http post using
# JSON to define parameters. The JSON currently can set 3 parameters:
#
#    {"parameter": [
#       {"name": "${JENKINS_PREFIX}Branch", "value": "test-branch"},
#       {"name": "${JENKINS_PREFIX}AddlArgs", "value": ""}
#       {"name": "${JENKINS_PREFIX}Target", "value": ""},
#       {"name": "${JENKINS_PREFIX}Email", "value": ""}
#    ]}
#
# The defaults are given is the above example.
######################################################################

myname=`basename $BASH_SOURCE`

usage() {
  cat >&2 <<EOF
Usage: jenkinssubmit.sh [options]
Options:
  -a <args>.... Additional args for the build
  -b <name>.... Branch of vorpalall to use in the test job
  -d .......... Debug (print command but do not execute)
  -e <address>. Email address that should get the bilder results
  -h .......... Print this help and exit
  -t <name>.... The build target(s)
Required environment variables (should be set by sourcing script)
  JENKINS_URL ...... The URL for job submission
  JENKINS_USER ..... user:password for jenkins submission
  JENKINS_DEFTARG .. default target for jenkins submission
  JENKINS_ADDLARGS . any additional Bilder args for the test job
Optional environment variables
  JENKINS_PREFIX ... The prefix for the variables for jenkins job submission.
EOF
  exit $1
}

# Make sure basic parameters are set
for sfx in URL USER DEFTARG; do
  var=JENKINS_${sfx}
  val=${!var}
  if test -z "$val"; then
    echo "$var not set.  Cannot continue."
    usage 1
  fi
done
if ! which curl 1>/dev/null 2>&1 </dev/null; then
  echo "curl not found.  Cannot continue."
  usage 1
fi

# First check that we are in a branch of the project repo.
# Otherwise,
jenkinsSvnUrl=`svn info | grep ^URL: | sed 's@URL: *@@'`
echo $jenkinsSvnUrl | grep -q branches
isBranch=$?
jbranch=
if test $isBranch = 0; then
  jbranch=`echo $jenkinsSvnUrl | sed -e 's@http.*/branches/@@'`
  echo "[$myname] Found branch ($jbranch). Continuing."
  JENKINS_BRANCH="branches/$jbranch"
else
  JENKINS_BRANCH="trunk"
fi

# Default values
DEBUG=false
JENKINS_ADDLARGS="-v2"  # Add innocuous args
JENKINS_TARGET="$JENKINS_DEFTARG"
JENKINS_EMAIL="qar@txcorp.com"

while getopts "a:b:de:ht:" arg; do
  case "$arg" in
    a) JENKINS_ADDLARGS="$OPTARG";;
    b) JENKINS_BRANCH="$OPTARG"
       JENKINS_BRANCH=$(echo $JENKINS_BRANCH | sed -e 's,^\^/,,') ;;
    d) DEBUG=true;;
    e) JENKINS_EMAIL="$OPTARG";;
    h) usage 0;;
    t) JENKINS_TARGET="$OPTARG";;
   \?) usage 1;;
  esac
done
shift $(($OPTIND - 1))
if test -n "$1"; then
  echo "$1 not understood."
  usage 1
fi

# Error checking
if test -z "$JENKINS_BRANCH"; then
  echo "[$0] Branch not specified and not in a branch."
  usage 1
fi

BRANCH_DEV=`id -un`

# Create Jenkins Request
echo "[$myname] Jenkins Job Parameters:"
echo "[$myname]    branch    = $JENKINS_BRANCH"
echo "[$myname]    server    = $JENKINS_URL"
echo "[$myname]    addlargs  = $JENKINS_ADDLARGS"
echo "[$myname]    target    = $JENKINS_TARGET"
echo "[$myname]    email     = $JENKINS_EMAIL"
echo "[$myname]    prefix    = $JENKINS_PREFIX"
echo "[$myname]    developer = $BRANCH_DEV"
# Determine the command
JENKINS_PREFIX=${JENKINS_PREFIX:-"test"}
json="{\"parameter\": [{\"name\": \"${JENKINS_PREFIX}Branch\", \"value\": \"$JENKINS_BRANCH\"},{\"name\": \"${JENKINS_PREFIX}AddlArgs\", \"value\": \"$JENKINS_ADDLARGS\"},{\"name\": \"${JENKINS_PREFIX}Target\", \"value\": \"$JENKINS_TARGET\"},{\"name\": \"${JENKINS_PREFIX}Email\", \"value\": \"$JENKINS_EMAIL\"},{\"name\": \"${JENKINS_PREFIX}Developer\", \"value\": \"$BRANCH_DEV\"}]}"
cmd="curl -F json='$json' -u $JENKINS_USER $JENKINS_URL"
echo "[$myname]    command = $cmd"
# Ask whether to submit
echo -n "[$myname] Submit? [y/N]: "
read okToSubmit
if ! test "$okToSubmit" == "y"; then
  echo "[$myname] Not Submitted."
  exit 0
fi

# Submit
echo Executing "$cmd"
$DEBUG || returnHtml=`curl -F json="$json" -u $JENKINS_USER $JENKINS_URL`
res=$?
if test $res = 0; then
  echo "[$myname] SUCCESS.  Received '$returnHtml'."
else
  echo "[$myname] ERROR.  Return code of curl is $res.  Received '$returnHtml'."
fi

