# Add needed newlines to the configure script
#
# $Id: addnewlines.sed 3935 2011-07-30 12:45:37Z cary $
#
# Removes duplicating spaces
s/  *$//
# Remove spaces at end of line
s/  */ /g
# Put newline in front of any path ending in cmake
# Not needed?  Fails for paths with blanks in them?
# s/ \([[:graph:]]*cmake\)/\
# \1/
# Put newline in front of any cmake variable
s/ \(-[D] *[a-zA-Z0-9_:]*=\)/\
\1/g
# Put newline in front of the cmake -G variable
s/ \(-G ['"]\)/\
\1/g
# Put newline in front of any atlas variable
s/ \(-[CF] i[cf] \)/\
\1/g
s/ \(-Fa \)/\
\1/g
# Put newline in front of any path ending in configure
s/ \([[:graph:]]*configure\)/\
\1/g
# Put newline in front of any variable being set
s/ \([a-zA-Z][a-zA-Z0-9_]*=\)/\
\1/g
# Put newline in front of any configure setting
s/ \(--[a-zA-Z][a-zA-Z0-9_-]*\)/\
\1/g
# Put newline in front of qmake vars.
# This has to be very specific to not pick up compiler flags
s/ \(-buildkey \)/\
\1/g
s/ \(-confirm-\)/\
\1/g
s/ \(-fast \)/\
\1/g
s/ \(-make \)/\
\1/g
s/ \(-no-\)/\
\1/g
s/ \(-open\)/\
\1/g
s/ \(-phonon \)/\
\1/g
s/ \(-platform \)/\
\1/g
s/ \(-webkit\)/\
\1/g
# Put newline in front of any path ending in <package>
# Need end space to not ruin rpath declarations for Python
s/ \([[:graph:]]*@PACKAGE@ \)/\
\1/
# Put newline in front of any path ending in <package>-<version>
# Need end space to not ruin rpath declarations for Python
s/ \([[:graph:]]*@PACKAGE@-@VERSION@ \)/\
\1/g
# Put newline after any single quote followed by a space.  Assumes
# all configuration variables are trim'd.
s/' /'\
/g
# Put newline in front of absolute path
s? /?\
/?g
