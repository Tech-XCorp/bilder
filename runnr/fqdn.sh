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

  # techo "[$FUNCNAME]: FQHOSTNAME = $FQHOSTNAME."
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
    fqtmp=`host $fqdn | sed 's/ .*$//'`
    echo "[$FUNCNAME]: fqtmp = $fqtmp."
    if test $fqtmp != Host; then
      fqdn=$fqtmp
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

# Special case for cori at nersc
  if [[ $FQHOSTNAME =~ ^cori[0-9]* ]] && ! [[ $FQHOSTNAME =~ nersc.gov$ ]]; then
    FQHOSTNAME=${FQHOSTNAME}.nersc.gov
  fi
  # techo "FQHOSTNAME = $FQHOSTNAME."

# Otherwise assume domainname is last part.
  DOMAINNAME=`echo $FQHOSTNAME | sed -e 's/^[^\.]*\.//'`
# FQMAILHOST will be determined elsewhere, as depending on system,
# it may or may not have trailing numbers stripped.

}

bilderFqdn

