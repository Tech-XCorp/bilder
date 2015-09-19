#!/bin/sh
#
# email handler that runs invokejenkins.sh
#
# From args get
#   Standard emails (e.g., qar)
#   job (e.g., vorpalall in /etc/aliases adds -j vorpalall-test)
#   token
#   baseurl
#
# Copy stdin to a file
# Pull out from address, verify that it is txcorp.com, if not error
#   If okay, add to emails to receive results
#
# Grep out of file:
#   ^JenkinsBranch: (to get svnbranch, required)
#   ^JenkinsCause:  (to get cause, not required)
#   ^JenkinsTarget: (to get target, not required)
#
# Remove file
#
# If any required parameters are missing, exit error
#
# Construct invokejenkins.sh command
# Execute invokejenkins.sh command
# Return error code from above command

