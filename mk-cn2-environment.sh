#!/bin/bash

#========================================================================================================================"
# mk-cn2-environment.sh 
#
# by brian mullan (bmullan.mail@gmail.com)
#
# Purpose:
#
# Install the apt tool to speed up apt's thru multiple threads/connections to the repositories
# Install a local Ubuntu-Mate Desktop Environment (DE) into a VM or an LXC container
# Install misc useful apps/tools for future users of this DE container
#
# Note: this will take 5-10 minutes depending on speed of host PC/server
#
#
#========================================================================================================================
# Copyright (c) 2016 Brian Mullan
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#======================================================================================================================="

#
#
#
read -p "Press any key to use LXD to create a Clone/Copy of the CN1 (Ubuntu-Mate) Desktop Environment into container named cn2..."
#
#
#
#

# NOTE: the setup-lxd.sh script will have passed 1 parameter to this script and that is the USER id we need to save it for later

userID=$1

# Note I am currently using Ubuntu 16.04 (xenial) for both Host & Containers so if you change to 16.04 etc tomorrow adjust the
# following appropriately

# add Canonical Partner repositories

echo "deb http://archive.canonical.com/ubuntu xenial partner" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://archive.canonical.com/ubuntu xenial partner" | sudo tee -a /etc/apt/sources.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list

sudo apt update
sudo apt upgrade -y

#======================================================================================================

# "Make sure 'software-properties' is installed for add-apt-repository won't work..."

sudo apt install software-properties-common -y

#Install miscellaneous

sudo apt install pulseaudio alsa-base alsa-utils linux-sound-base gstreamer1.0-pulseaudio gstreamer1.0-alsa libpulse-dev libvorbis-dev -y

sudo apt install fail2ban -y

# the following is a work-around for a problem with the avahi-daemon in a container
# source for work-around tip: https://gist.github.com/jpouellet/c0d0698d669f1f364ab3

# note:  some error messages will be displayed but after these statements complete
#        avahi should be working
sudo apt install avahi-daemon avahi-utils -y
sudo systemctl disable avahi-daemon
sudo systemctl stop avahi-daemon
sudo apt autoremove
sudo apt install -f avahi-daemon avahi-utils -y

# avahi should now work ok

#============================================================
# " Install xfce4 (re xubuntu) into this CN2 container..."

# Install a minimal XUBUNTU desktop environment for Guacamole RDP User to work with.

sudo apt install xubuntu-desktop -y

# Configure the Xsession file default desktop environment to make ALL future Users default xsession to be xubuntu

sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session


#======================================================================
# "Install misc useful sw apps/tools for the future users..."
#
# "gdebi - to support cli .DEB installs (if a sudo user)"
# "nano - my favorite quick/easy cli text editor"
# "firefox - the browser obviously"
# "terminator - my favorite 'multi-window' Terminal program"
# "synaptic - so future sudo users can manage sw apps easier"
#======================================================================

sudo apt install openssh-server gdebi nano terminator synaptic wget curl ufw network-manager gedit -y
sudo apt install ubuntu-restricted-extras ubuntu-restricted-addons -y

# enable UFW
sudo sed -i 's/ENABLED=no/ENABLED=yes/g' /etc/ufw/ufw.conf

#==============================================
# open certain ports on the ciab-desktop server

sudo ufw allow 22          # ssh
sudo ufw allow 8080        # http
sudo ufw allow 80
sudo ufw allow https       
sudo ufw allow 4822        # guacd
sudo ufw allow 3389        # rdp
sudo ufw allow 4713        # pulseaudio


# install xrdp straight from canonical archives into cn2

sudo apt install xrdp -y

# sudo dpkg -i /home/$userID/xrdp.deb
# sudo dpkg -i /home/$userID/x11rdp.deb

# remove systemd xrdp start files as they for some reason don't work right.   This will
# leave upstart to start xrdp at system boot

sudo rm /lib/systemd/system/xrdp*

#---------------------------------------------------------------------------------------------
# In setup-containers.sh we used LXC to copy the ciab-logo.bmp to the $USER (the installers)
# new acct in this container. Here we move it from there to where it needs to be in order
# for it to be displayed on the xrdp login screen

# first make sure the directory exists... it should but just in case

# sudo mkdir /usr/local/share/xrdp

# sudo cp /home/$userID/ciab-logo.bmp /usr/local/share/xrdp/ciab-logo.bmp

#=================================================================================================
# change browsers to chromium-browser by installing it & removing firefox.  
# we do this because chromium is the basis of Chrome has been shown to have the better performance 
# with Guacamole


sudo apt install chromium-browser adobe-flashplugin -y
sudo apt remove firefox -y


#==============================================================================================================================================
# in order for all new users added to this server via sudo adduser xxx in the future we need to change the /etc/adduser.conf file
# to set /etc/adduser.conf to add all new users accounts created to the audio/pulse/pulse-access groups
#
# To do this we need to change the following 2 lines in adduser.conf.
#
# The following line needs to be first be uncommented & also changed to "include" the groups we want the user added to
##EXTRA_GROUPS="dialout cdrom floppy audio video plugdev users"
# and 
# The following line just needs to be uncommented so the EXTRA_GROUPS option above will be default behavior for adding new, non-system users
##ADD_EXTRA_GROUPS=1
#
# make the 1st change
sudo sed -i 's/#EXTRA_GROUPS="dialout cdrom floppy audio video plugdev users"/EXTRA_GROUPS="audio pulse pulse-access"/' /etc/adduser.conf
# make the 2nd change
sudo sed -i 's/#ADD_EXTRA_GROUPS=1/ADD_EXTRA_GROUPS=1/' /etc/adduser.conf

# copy our custom built pulseaudio drivers for xrdp/freerdp to the correct directory
# For Ubuntu 16.04 this willl be Pulseaudio 8.0

sudo mv /home/$userID/module-xrdp*.so   /usr/lib/pulse-8.0/modules
sudo chown root:root /usr/lib/pulse-8.0/modules/module-xrdp*.so
sudo chmod 644 /usr/lib/pulse-8.0/modules/module-xrdp*.so

# make sure the installing user is a member of audio/pulse/pulse-access groups

sudo adduser $userID pulse
sudo adduser $userID pulse-access
sudo adduser $userID audio

#---------------------------------------------------------------------------------------------------------------
# add the command "export PULSE_SERVER=10.0.3.1"  to the installer/user acct in the container CN1
# Later when that user logs into the container... that PULSE_SERVER environment variable will be set
# and REDIRECT any sound generated in the container to 10.0.3.1 which from the container CN1's perspective
# is the HOST it is running in.
#
# Important Note:  later if you add additional User accounts to the LXC container you will need to add this
#                  statement to those userID .bashrc files as well.
#---------------------------------------------------------------------------------------------------------------

sudo echo "export PULSE_SERVER=10.0.3.1" | tee -a /home/$userID/.bashrc

#---------------------------------------------------------------------------------------------------------------
# we need to add the export PULSE_SERVER-10.0.3.1 to the /opt/google/chrome/google-chrome script 
# file that is run when you execute chrome from the Ubuntu menu instead of starting it from a command prompt
# when you start it from a command prompt the actual /opt/google/chrome/chrome binary runs
# when you start chrome from the Ubuntu menu... the /opt/google/chrome/google-chrome script runs... 
# then invokes the actual chrome binary.   
#   We need the google-chrome script to have the same PULSE_SERVER=10.0.3.1 environment
# variable as the User's .bashrc has
#
# Note:  I'm not sure if this difference in starting chrome via the menu & the command line is a bug or not
#        but I am going to submit it as Bug as I think both methods of starting firefox should run with the
#        same User Environment variables - not different ones.   In the meantime, some of the next commands
#        are workarounds, inserting the 'export PULSE_SERVER=10.0.3.1' to the /opt/google/chrome/google-chrome
#---------------------------------------------------------------------------------------------------------------

# the original google-chrome script file is this one...
#oldfile=/opt/google/chrome/google-chrome

# save the original
#sudo cp $oldfile $oldfile.orig

# we will use SED to add our PULSE_SERVER statement to the original google-chromes script but save the change to google-chrome.new
#newfile=/opt/google/chrome/google-chrome.new

# Now in google-chrome script file we append after its "!/bin/sh" the export statement and redirect that to a new 
# copy of the google-chrome script filw which we will call google-chrome.new
#sudo sed '/bin\/bash/a export PULSE_SERVER=10.0.3.1' $oldfile > $newfile

# now we replace google-chrome with the google-chrome.new file and we should be all set
#sudo mv $newfile $oldfile
# and make sure the new firefox.sh is executable
#sudo chmod +x $oldfile

#=======================================
# Clean up some things before exiting...

sudo apt-get autoremove -y

#
#
# "Xubuntu Desktop Environment installation in CN2 is finished.."
#
# "*** Remember to create some UserID's in Container CN2 for your CIAB Remote Desktop users ! "
#
#
#

exit 0
