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

# Check for already done
  if test -n "$FQHOSTNAME"; then
    return
  fi

# Try getting with hostname
  local fqdn
  if ! fqdn=`hostname -f 2>/dev/null`; then
    fqdn=`hostname`
  fi
# If that is unqualified, try host.
  if ! [[ $fqdn =~ \. ]]; then
    fqdn=`host $fqdn | sed 's/ .*$//'`
  fi
  FQHOSTNAME=$fqdn
  # echo "bilderFqdn called.  fqdn = $fqdn.  FQHOSTNAME = $FQHOSTNAME."

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

# Otherwise assume domainname is last part and strip off trailing
# numbers to get mailhost
  DOMAINNAME=`echo $FQHOSTNAME | sed -e 's/^[^\.]*\.//'`
  FQMAILHOST=`echo $FQHOSTNAME | sed -e 's/\..*$//' -e 's/[0-9]*$//'`.$DOMAINNAME

}

bilderFqdn

