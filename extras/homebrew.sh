Homebrew installation steps

$Id$

See http://ascarter.net/2010/02/22/homebrew-for-os-x.html for
reasons for this method of installation.   In this method, brew
must be run by root and all files are owned by root.  Since
sudo is then used, you may want the lines,

Defaults umask = 0002
Defaults umask_override

in /etc/sudoers (done with visudo).

** STEPS TO SET UP HOMEBREW **

GET HOMEBREW

sudo -s
mkdir -p /opt/homebrew
chgrp -R admin /opt
chmod -R 775 /opt
chmod -R 2775 /opt/homebrew
cd /opt
curl -L http://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C homebrew
sudo chmod -R a+rX /opt/homebrew
sudo find /opt/homebrew -type l -exec chmod -h a+r '{}' \;

ADD IT TO YOUR PATH

echo "/opt/homebrew/bin" > /etc/paths.d/homebrew
echo "/opt/homebrew/share/man" > /etc/manpaths.d/homebrew
chmod a+r /etc/paths.d/homebrew /etc/manpaths.d/homebrew

exit

GET SOME PACKAGES
sudo brew install wget
sudo brew install imagemagick
sudo brew install hg

# These may help if you get sudo incorrect.
sudo chmod -R a+rX /opt/homebrew
sudo find /opt/homebrew -type l -exec chmod -h a+r '{}' \;

# To remove brew, go to the top of the installation and do
sudo rm -rf .git* CONTRIBUTING.md README.md bin/brew Cellar
sudo rm share/man/man1/brew.1 # Perhaps others

