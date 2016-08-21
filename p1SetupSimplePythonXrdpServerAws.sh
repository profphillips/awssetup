#!/bin/bash
echo '-----------------------------------------------------------------------------------------------'
echo '---- SETUP FOR AWS EC2 MULTIUSER SIMPLE PYTHON UBUNTU 16.04 XRDP SERVER'
echo '---- version 20160821'
echo '-----------------------------------------------------------------------------------------------'

# Updates a Ubuntu 16.04 AWS instance with Apache2, xrdp, and Mate for remote desktop access.

# I run this scrip as root: 
#   $ sudo su -
#   # vim setup.sh
#   Copy from GitHub raw and paste into vim (i (insert mode) and then right click if using Putty to paste)
#   # chmod 700 setup.sh
#   # ./setup.sh
# takes a few minutes to run
# reboot server from AWS control panel
# log in from Putty using jdoe/mucis (remember to open firewall SSH port with your computer's ip address only)
# connect using Windows/Mac Remote Desktop using jdoe/mucis (remember to open firewall RDP port)

echo 'Starting shell script at:'
date
whoami
pwd

echo '-----------------------------------------------------------------------------------------------'
echo '---- UPDATING THE SERVER'
echo '-----------------------------------------------------------------------------------------------'
apt-get -qq update -y
apt-get -qq upgrade -y
# could also apt-get -qq dist-upgrade -y  -- not sure if this is needed

echo '---- SETTING HOST NAME'
hostnamectl set-hostname localhost
hostnamectl

echo '---- INSTALLING A FEW UTILITY PROGRAMS'
apt-get -qq install -y git bzip2 zip unzip screen

echo '-----------------------------------------------------------------------------------------------'
echo '---- INSTALLING COMPILERS'
echo '-----------------------------------------------------------------------------------------------'

echo '----PERL IS PREINSTALLED'
perl --version

echo '---- PYTHON AND PYTHON3 ARE PREINSTALLED'
python3 --version

echo '-----------------------------------------------------------------------------------------------'
echo '---- INSTALLING APACHE2'
echo '-----------------------------------------------------------------------------------------------'

apt-get -qq install -y apache2
echo '--'

echo '---- CONFIGURE APACHE2 TO ALLOW CGI AND PUBLIC_HTML USER FOLDERS'
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
a2enconf servername.conf
sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi .pl .py .rb/' /etc/apache2/mods-available/mime.conf
sed -i 's/IncludesNoExec/ExecCGI/' /etc/apache2/mods-available/userdir.conf
a2enmod userdir
a2enmod cgid
a2disconf serve-cgi-bin

systemctl reload apache2
systemctl restart apache2
systemctl status apache2

echo '---- FIXING APACHE ERROR LOG SO ALL USERS CAN READ IT'
chmod 644 /var/log/apache2/error.log
chmod 755 /var/log/apache2
sed -i 's/create 640 root adm/create 644 root adm/' /etc/logrotate.d/apache2

echo '-----------------------------------------------------------------------------------------------'
echo '---- CREATING FILES FOR THE USERS'
echo '-----------------------------------------------------------------------------------------------'

echo '---- CONFIGURE SKEL WITH TEST FILES FOR ALL USERS'
mkdir /etc/skel/cis1109
mkdir /etc/skel/public_html
mkdir /etc/skel/public_html/pub1109
mkdir /etc/skel/public_html/test

echo "<html><body>Hello from HTML</body></html>" > /etc/skel/public_html/test/htmltest.html

echo "#!/usr/bin/perl" > /etc/skel/public_html/test/perltest.pl
echo 'print "Content-type: text/html\n\n";' >> /etc/skel/public_html/test/perltest.pl
echo 'print "Hello from Perl\n";' >> /etc/skel/public_html/test/perltest.pl
chmod 755 /etc/skel/public_html/test/perltest.pl

echo "#!/usr/bin/python3" > /etc/skel/public_html/test/pythontest.py
echo 'print ("Content-type: text/html\n\n")' >> /etc/skel/public_html/test/pythontest.py
echo 'print ("Hello from Python\n")' >> /etc/skel/public_html/test/pythontest.py
chmod 755 /etc/skel/public_html/test/pythontest.py

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
apt-get purge -y --auto-remove mate-screensaver

# suggest installing the following themes and fonts and then choose a small/simple/quick wallpaper
# I usually set the mono font to inconsolata medium 14
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

# Brackets seems to work fine -- nice HTML editor
wget https://github.com/adobe/brackets/releases/download/release-1.7/Brackets.Release.1.7.64-bit.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/libg/libgcrypt11/libgcrypt11_1.5.3-2ubuntu4_amd64.deb
gdebi -n libgcrypt11_1.5.3-2ubuntu4_amd64.deb
gdebi -n Brackets.Release.1.7.64-bit.deb
rm -f libgcrypt*.deb
rm -f Brackets*.deb

echo '-----------------------------------------------------------------------------------------------'
echo '---- ADDING MISC.'
echo '-----------------------------------------------------------------------------------------------'

# Add graphics to Python3
apt-get install -y python3-tk

echo '---- ADDING TEST USER jdoe'
useradd -m jdoe -c 'Jane Doe' -s '/bin/bash'

echo '---- SETTING PASSWORD FOR USER jdoe TO mucis'
echo jdoe:mucis | sudo chpasswd

echo '---- ALLOWING PASSWORD LOGINS - BE SURE TO SET AWS FIREWALL CORRECTLY TO LIMIT ACCESS BY IP'
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

echo '-----------------------------------------------------------------------------------------------'
echo 'Ending shell script at:'
date

