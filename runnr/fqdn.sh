##########
#
# File:    fqdn.sh
#
# Purpose: Set the fully qualified domain name for systems that
#          do not return this from hostname or hostname -f.  This
#          can set FQHOSTNAME, FQMAILHOST, DOMAINNAME, RUNNRSYSTEM
#
# Version: $Id$
#
##########

bilderFqdn() {

  techo "[$FUNCNAME]: FQHOSTNAME = $FQHOSTNAME."
# Check for already done
  if test -n "$FQHOSTNAME" && ! test $FQHOSTNAME = Host; then
    return
  fi

# Try getting with hostname
  local fqdn
  if ! fqdn=`hostname -f 2>/dev/null`; then
    fqdn=`hostname`
  fi
# If that is unqualified, try host.
  if ! [[ $fqdn =~ \. ]]; then
    # fqtmp=`host $fqdn | sed 's/ .*$//'`
    # if test $fqtmp = Host; then # At place that does not give fqdn
    if fqtmp=`host $fqdn | grep "has address"`; then
      fqdn=`echo $fqtmp | sed -e 's/ .*$//'`
    elif host $fqdn | grep -q "not found"; then
      echo "$fqdn not found by host."
      if `uname` != Darwin; then
        ip=`hostname -i`
        fqdn=`host $ip | sed -e 's/^.* //' -e 's/\.$//'`
      fi
    else
      fqdn=`host $fqdn | sed 's/ .*$//'`
    fi
  fi
  FQHOSTNAME=$fqdn
  # techo "[$FUNCNAME]: fqdn = $fqdn."

# For systems with nodes named node0, node1, ... or login0, login1, ...,
# strip that off to get the system name (FQMAILHOST)
  for prehn in login node; do
    if [[ $FQHOSTNAME =~ ^${prehn} ]]; then
      # echo matches $prehn
      FQMAILHOST=`echo $FQHOSTNAME | sed -e "s/${prehn}[^\.]*\.//"`
      DOMAINNAME=`echo $FQMAILHOST | sed -e 's/^[^\.]*\.//'`
      return
    fi
  done

# Otherwise domainname is last part.
  DOMAINNAME=`echo $FQHOSTNAME | sed -e 's/^[^\.]*\.//'`

# And mail host found by stripping trailing numbers and dashes
  if test $DOMAINNAME = nersc.gov; then
    UQHOSTNAME=`echo $FQHOSTNAME | sed -e 's/\..*$//' -e 's/[0-9]*$//'`
    UQMAILHOST=`echo $UQHOSTNAME | sed -e 's/eth$//' -e 's/-$//' -e 's/[0-9]*$//'`
    FQMAILHOST=${UQMAILHOST}.$DOMAINNAME
  fi

}

bilderFqdn

