# Add needed newlines to the configure script
#
# $Id: addnewlines.sed 3935 2011-07-30 12:45:37Z cary $
#
# Removes duplicating spaces
s/  *$//
# Remove spaces at end of line
s/  */ /g
# Put newline after any single quote followed by a space.
# Assumes all configuration variables are trim'd.
s/' /' \\\
  /g
# Put newline before key words of distutils
s/ build / \\\
  build /
s/ install / \\\
  install /
s/ bdist_wininst / \\\
  bdist_wininst /
s/^env /env \\\
  /
# But no before python, as it follow a '
# s/ python / \\\
#   python /
