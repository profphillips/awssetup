#!/bin/bash
echo '-----------------------------------------------------------------------------------------------'
echo '---- UPDATING THE SYSTEM FOR AWS EC2 MULTIUSER STUDENT DEVELOPER UBUNTU 16.04 XRDP GUI SERVER'
echo '---- This is the second part of the setup script and deals with adding an xrdp Mate GUI.'
echo '---- chmod 700 d2setup.sh and run as root.'
echo '---- version 20160821'
echo '-----------------------------------------------------------------------------------------------'

echo 'Starting shell script at:'
date
whoami
pwd

echo '--'
echo '-----------------------------------------------------------------------------------------------'
echo '---- INSTALLING GUI ENVIRONMENT'
echo '-----------------------------------------------------------------------------------------------'

# To see what software is available use: apt-cache search mate
# to remove a package use: sudo apt-get purge --auto-remove packagename

# install remote destop server software
apt-get -qq install -y xrdp

# set Mate to be the default window manager
sed -i 's/.*\/etc\/X11\/Xsession/mate-session/' /etc/xrdp/startwm.sh

# The following command installs most of what we need for a basic Mate remote desktop system
# We do get an error with the trash applet but can just delete the applet on first run
# .. or install mate-desktop-environment below to fix applet problem
apt-get -qq install -y mate-core

# not sure if the following line is needed
# recommended by http://c-nergy.be/blog/?p=5874
apt-get -qq install -y mate-notification-daemon

# mate-utils adds screenshot menu item
apt-get -qq install -y mate-utils

# mate-menu lets user configure which programs appear on the menu bar
apt-get -qq install -y mate-menu

# mate-desktop-environment adds screensaver which we do not want -- remove it
# but we may want some of the other apps it gives us; it also fixes trash applet startup error
apt-get -qq install -y mate-desktop-environment
#apt-get -qq install -y mate-desktop-environment-extras
apt-get purge -y --auto-remove mate-screensaver

# ubuntu-mate-core adds a gig of stuff -- not really needed for remote desktop
# ubuntu-mate-desktop adds another gig of stuff including LibreOffice -- not needed
#apt-get -qq install -y ubuntu-mate-core
#apt-get -qq install -y ubuntu-mate-desktop
#sed -i 's/.*\/etc\/X11\/Xsession/mate-session/' /etc/xrdp/startwm.sh

# suggest installing the following themes and fonts and then choose a small/simple/quick wallpaper
# I usually set the mono font to inconsolata medium 14 and the wallpaper to 
apt-get install -y mate-themes ubuntu-mate-themes
apt-get install -y ubuntu-mate-wallpapers-utopic ubuntu-mate-wallpapers-vivid
apt-get install -y fonts-inconsolata fonts-dejavu fonts-droid-fallback fonts-liberation fonts-ubuntu-font-family-console

# add a few useful apps; gdebi needed to install chrome; seemed like I needed xterm for something a while back...
apt-get install -y xterm gdebi-core

echo '-----------------------------------------------------------------------------------------------'
echo '---- ADDING BROWSERS'
echo '-----------------------------------------------------------------------------------------------'

apt-get install -y firefox

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
gdebi -n google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

echo '-----------------------------------------------------------------------------------------------'
echo '---- ADDING ADVANCED TEXT EDITORS'
echo '-----------------------------------------------------------------------------------------------'

apt-get -qq install -y pluma vim-gnome

# Had problems with auto install of atom. Manual install of lastest beta also failed 20160820.
#wget https://github.com/atom/atom/releases/download/v1.9.9/atom-amd64.deb
#gdebi -n atom-amd64.deb

# This did not work either...
#add-apt-repository -y ppa:webupd8team/atom
#apt-get -y update
#apt-get install -y atom

# Brackets seems to work fine -- nice HTML editor
wget https://github.com/adobe/brackets/releases/download/release-1.7/Brackets.Release.1.7.64-bit.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_amd64.deb
gdebi -n libgcrypt11_1.5.3-2ubuntu4_amd64.deb
gdebi -n Brackets.Release.1.7.64-bit.deb

echo '-----------------------------------------------------------------------------------------------'
echo '---- ADDING MISC.'
echo '-----------------------------------------------------------------------------------------------'

# Had some problems last year with dropbox with minimal install; haven't tried it recently
#wget https://www.dropbox.com/install

# synaptic is a gui install tool; will need to give user sudo privledges in order to use it.
apt-get install -y synaptic

# Add graphics to Python3
apt-get install -y python3-tk


#echo '-----------------------------------------------------------------------------------------------'
#echo '---- INSTALLING Mono/C# GUI IDE'
#echo '-----------------------------------------------------------------------------------------------'

# the following is a large install; only install this if you need to do C# development in a GUI 
#    echo '---- INSTALLING C, C++, C# Mono IDE'
#    apt-get install -y monodevelop
#    echo '--'

echo '-----------------------------------------------------------------------------------------------'
echo '---- INSTALLING Spring Tool Suite / Eclipse GUI IDE'
echo '-----------------------------------------------------------------------------------------------'

# Spring Tool Suite (sts) is a large install but useful for developing Java software
# sts seems to be better than the standard ubuntu eclipse install which is a rather old version  (3.8 I believe)
# sts uses eclipse 4.6 which was released 20160622
# for better JavaFX support you can do Help/MarketPlace, search on FX, choose/install e(fx)clipse

echo '---- INSTALLING SPRING STS / ECLIPSE IDE 20160819 VERSION'
wget http://dist.springsource.com/release/STS/3.8.1.RELEASE/dist/e4.6/spring-tool-suite-3.8.1.RELEASE-e4.6-linux-gtk-x86_64.tar.gz
tar xvzf spring-tool-suite-3.8.1.RELEASE-e4.6-linux-gtk-x86_64.tar.gz
rm -f spring-tool-suite-3.8.1.RELEASE-e4.6-linux-gtk-x86_64.tar.gz
mkdir /etc/skel/sts
cp -r sts-bundle/sts-3.8.1.RELEASE/* /etc/skel/sts/
echo 'RUN AS: ~/sts/STS'
echo '--'

echo '-----------------------------------------------------------------------------------------------'
echo '---- INSTALLING NetBeans GUI IDE'
echo '-----------------------------------------------------------------------------------------------'

# The following is a NetBeans standard edition install
# after installing, use Tools/Plugins; check all in Settings; click Update; Available Plugins Tab
# .. choose Java EE Base to work with Tomcat
# .. choose JavaFX 2 Support for some menu shortcuts that maybe works with JavaFX 8 (also adds Maven) -- needs testing
# .. choose Gluon Plugin for experimental Android / iOS development using Java

apt-get install -y netbeans
echo '--'

# Todo -- add Intellij IDE

echo '-----------------------------------------------------------------------------------------------'
echo '---- ADDING GUI USER WITH SUDO OPTION'
echo '-----------------------------------------------------------------------------------------------'

# Add a new GUI user with sudo privledges so we can finalize our setup in GUI environment

useradd -m river -c 'River' -s '/bin/bash'
echo river:mucis | sudo chpasswd
usermod -aG sudo river
echo '--'

echo '-----------------------------------------------------------------------------------------------'
echo '---- ALL DONE'
echo '-----------------------------------------------------------------------------------------------'

echo '--'
echo 'Reboot from AWS control panel.'
echo 'Use Windows/Mac Remote Desktop to connect to GUI server as user river / mucis.'
echo 'Make sure your AWS firewall only allows your computers ip addresses for SSH and RDP.'
echo 'You can allow everyone access to port 80 (http) for the Apache2 web server.'
echo 'You can allow everyone access to port 8080(tcp) for the Tomcat Java server if used.'
echo 'Ending shell script at:'
date


