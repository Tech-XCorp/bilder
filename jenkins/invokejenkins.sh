#!/bin/sh

# https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Builds

usage() {
  cat >&2 <<EOF
Usage: invokebuild.sh [options]
Options:
  -b <svnbranch>.. The branch to build
  -c <cause> ..... Jenkins puts this as the cause of the build
  -e <email> ..... Where to email the results
  -h ............. Print this message.
  -j <job> ....... The Jenkins job, e.g., vorpal-test
  -t <target> .... The target for the build
  -T <token> ..... The job remote invocation token
  -u <baseurl> ... The base url, e.g., carys.org:8300
EOF
  exit $1
}

svnbranch=
cause=
email=
job=
target=
token=
baseurl=

while getopts "b:c:e:hj:t:T:u:" arg; do
  case $arg in
    b) svnbranch=$OPTARG;;
    c) cause=$OPTARG;;
    e) email=${email},$OPTARG;;
    h) usage 0;;
    j) job=$OPTARG;;
    T) token=$OPTARG;;
    t) target=$OPTARG;;
    u) baseurl=$OPTARG;;
  esac
done

# Required parameters
argerr=0
if test -z "$baseurl"; then
  echo "Must specify baseurl with -u"
  argerr=`expr $argerr + 1`
fi
if test -z "$job"; then
  echo "Must specify job with -j"
  argerr=`expr $argerr + 1`
fi
if test -z "$token"; then
  echo "Must specify token with -T"
  argerr=`expr $argerr + 1`
fi
if test $argerr -gt 1; then
  usage 1
fi

prms=
if test -n "$cause"; then
  prms="&cause=Cause+$cause"
fi
if test -n "$email"; then
  prms="${prms}&email=$email"
fi
if test -n "$svnbranch"; then
  prms="${prms}&svnbranch=$svnbranch"
fi
if test -n "$target"; then
  prms="${prms}&target=$target"
fi
url="http://$baseurl/job/$job/buildWithParameters?token=${token}${prms}"

echo "Will post to $url"

cmd="curl $url"
echo "$cmd"
# eval "$cmd"
