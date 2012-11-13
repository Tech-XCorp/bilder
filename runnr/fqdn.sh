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
  local fqdn
  if ! fqdn=`hostname -f 2>/dev/null`; then
    fqdn=`hostname`
  fi
  case $fqdn in
# ALCF
    *.*.alcf.anl.gov)
      FQMAILHOST=`echo $FQHOSTNAME | sed -e 's/.alcf.anl.gov//' -e 's/^.*\.//'`.alcf.anl.gov
      DOMAINNAME=${DOMAINNAME:-"alcf.anl.gov"}
      RUNNRSYSTEM=${RUNNRSYSTEM:-"BGP"}
      ;;
# NERSC (many machines do not return fqdn)
    cvrsvc[0-9]*)
      FQHOSTNAME=${FQHOSTNAME:-"$fqdn.nersc.gov"}
      FQMAILHOST=${FQMAILHOST:-"carver.nersc.gov"}
      ;;
    dirac[0-9]*)
      FQHOSTNAME=${FQHOSTNAME:-"$fqdn.nersc.gov"}
      FQMAILHOST=${FQMAILHOST:-"dirac.nersc.gov"}
      ;;
    freedom[0-9]*)
      FQMAILHOST=${FQMAILHOST:-"freedom.nersc.gov"}
      RUNNRSYSTEM=${RUNNRSYSTEM:-"XT4"}
      ;;
    hopper[01][0-9]*)
      FQHOSTNAME=${FQHOSTNAME:-"$fqdn.nersc.gov"}
      FQMAILHOST=${FQMAILHOST:-"hopper.nersc.gov"}
      RUNNRSYSTEM=${RUNNRSYSTEM:-"XE6"}
      ;;
    nid[0-9]*)
      FQHOSTNAME=${FQHOSTNAME:-"$fqdn.nersc.gov"}
      FQMAILHOST=${FQMAILHOST:-"franklin.nersc.gov"}
      RUNNRSYSTEM=${RUNNRSYSTEM:-"XT4"}
      ;;
    node[0-9]*.*) # Catchall for systems with nodes named node0, node1, ...
      FQHOSTNAME=${FQHOSTNAME:-"$fqdn"}
      if test -z "$FQMAILHOST"; then
        if test -x "/sbin/route"; then
          local gwip=`/sbin/route -n | grep 'UG[ \t]' | awk '{print $2}'`
        else
          local gwip=`route -n | grep 'UG[ \t]' | awk '{print $2}'`
        fi
        local gwhn=`rsh $gwip hostname -f | sed 's/[0-9]*\././'`
        FQMAILHOST="$gwhn"
      fi
      ;;
  esac
}

bilderFqdn

