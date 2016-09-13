#!/bin/bash
echo '-----------------------------------------------------------------------------------------------'
echo '---- UPDATING THE SYSTEM FOR AWS EC2 MULTIUSER STUDENT DEVELOPER UBUNTU 16.04 SERVER'
echo '---- version 20160904'
echo '-----------------------------------------------------------------------------------------------'

# This script installs various programming languages, servers, and utilities.
# It creates a console only version of the server.
# If you want an xrdp GUI server then run this script followed by the GUI script.

# I run this as root: 
#   $ sudo su -
#   # vim d1setup.sh
#   Copy from GitHub raw and paste into vim (i (insert mode) and then right click if using Putty to paste)
#   # chmod 700 d1setup.sh
#   # ./d1setup.sh

# It takes a few minutes to run...

echo 'Starting shell script at:'
date
whoami
pwd

# The following line is needed in order to do an oracle java jdk install and
# it must go before an update command, hence this location. 
# However, the openjdk version seems to be working ok and so I will comment this out for now.
#add-apt-repository ppa:webupd8team/java -y

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

echo '---- INSTALLING JAVA 8 COMPILER'
# if using oracle install it asks some interactive questions -- not sure how to automate them
# back to using openjdk version for now
apt-get -qq install -y openjdk-8-jdk openjfx
#apt-get -qq install -y oracle-java8-installer
javac -version
java -version

echo '---- INSTALLING JAVA/MYSQL JDBC DRIVER'
apt-get -qq install -y libmysql-java
echo 'CLASSPATH=.:/usr/share/java/mysql-connector-java.jar' >> /etc/environment

echo '----PERL IS PREINSTALLED / INSTALL MYSQL DRIVER'
perl --version
apt-get -qq install -y libdbi-perl

echo '---- PYTHON AND PYTHON3 ARE PREINSTALLED / INSTALL MYSQL DRIVER'
python3 --version
apt-get -qq install -y python3-mysqldb

echo '---- RUBY IS PREINSTALLED ON VAGRANT BUT NOT ON AWS'
apt-get -qq install -y ruby
ruby --version

echo '---- INSTALLING C AND C++ COMPILERS'
apt-get -qq install -y build-essential
gcc --version
g++ --version

#echo '---- INSTALLING C# COMPILER'
#apt-get -qq install -y mono-complete
#mono

#echo '---- INSTALLING GO'
#apt-get -qq install -y golang
#go version

#echo '---- INSTALLING CLOJURE'
#apt-get install -y clojure1.6

#echo '---- INSTALLING LEGACY COMPILERS'

#echo '---- INSTALLING FORTRAN COMPILER'
#apt-get install -y gfortranq
#gfortran --version

#echo '---- INSTALLING COBOL COMPILER'
#apt-get install -y open-cobol
#cobc -V

#echo '---- INSTALLING PL/I COMPILER'
#wget http://www.iron-spring.com/pli-0.9.9.tgz
#tar -xvzf pli-0.9.9.tgz
#cd pli-0.9.9
#make install
#cd ..
#rm -f pli-0.9.9.tgz
#plic -V

echo '-----------------------------------------------------------------------------------------------'
echo '---- INSTALLING APACHE2, MYSQL, AND PHP7 TO CREATE A LAMP SERVER'
echo '-----------------------------------------------------------------------------------------------'

apt-get -qq install -y apache2
echo '--'

echo '---- INSTALLING PHP7'
apt-get -qq install -y php7.0 php7.0-mysql libapache2-mod-php7.0 php7.0-gd php7.0-json
echo '--'

echo '---- INSTALLING MYSQL WITH NO ROOT PASSWORD'
DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server
echo '--'

echo '---- CONFIGURE APACHE2 TO ALLOW CGI AND PUBLIC_HTML USER FOLDERS'
echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf
a2enconf servername.conf

sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi .pl .py .rb/' /etc/apache2/mods-available/mime.conf

sed -i 's/IncludesNoExec/ExecCGI/' /etc/apache2/mods-available/userdir.conf

sed -i 's/<IfModule mod_userdir.c>/#<IfModule mod_userdir.c>/' /etc/apache2/mods-available/php7.0.conf
sed -i 's/    <Directory/#    <Directory/' /etc/apache2/mods-available/php7.0.conf
sed -i 's/        php_admin_flag engine Off/#        php_admin_flag engine Off/' /etc/apache2/mods-available/php7.0.conf
sed -i 's/    <\/Directory>/#    <\/Directory>/' /etc/apache2/mods-available/php7.0.conf
sed -i 's/<\/IfModule>/#<\/IfModule>/' /etc/apache2/mods-available/php7.0.conf

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
echo '---- INSTALLING TOMCAT JAVA WEB SERVER'
echo '-----------------------------------------------------------------------------------------------'
# some 16.04 commands for working with tomcat include
# systemctl status tomcat8
# systemctl restart tomcat8

apt-get -qq install -y tomcat8 tomcat8-docs tomcat8-admin tomcat8-examples

echo '---- CONFIGURE TOMCAT'
echo '---- SET THE TOMCAT ADMIN USER: tomcat'
echo '---- SET THE TOMCAT ADMIN PASSWORD: tomcatpw'
echo '---- UPLOAD AND RUN JSP PROGRAMS AT BROWSER URL OF: ipaddress:8080'
sed -i 's/<\/tomcat-users>/  <user username="tomcat" password="mucis" roles="manager-gui,admin-gui"\/><\/tomcat-users>/' /etc/tomcat8/tomcat-users.xml

# Todo -- add a nodejs server option

echo '-----------------------------------------------------------------------------------------------'
echo '---- CREATING FILES FOR THE USERS'
echo '-----------------------------------------------------------------------------------------------'

echo '---- CONFIGURE SKEL WITH TEST FILES FOR ALL USERS'
mkdir /etc/skel/public_html
mkdir /etc/skel/public_html/pub1000
mkdir /etc/skel/public_html/test

echo "<html><body>Hello from HTML</body></html>" > /etc/skel/public_html/test/htmltest.html

echo "<?php phpinfo(); ?>" > /etc/skel/public_html/test/phptest.php

echo "#!/usr/bin/perl" > /etc/skel/public_html/test/perltest.pl
echo 'print "Content-type: text/html\n\n";' >> /etc/skel/public_html/test/perltest.pl
echo 'print "Hello from Perl\n";' >> /etc/skel/public_html/test/perltest.pl
chmod 755 /etc/skel/public_html/test/perltest.pl

echo "#!/usr/bin/python3" > /etc/skel/public_html/test/pythontest.py
echo 'print ("Content-type: text/html\n\n")' >> /etc/skel/public_html/test/pythontest.py
echo 'print ("Hello from Python\n")' >> /etc/skel/public_html/test/pythontest.py
chmod 755 /etc/skel/public_html/test/pythontest.py

echo "#!/usr/bin/ruby" > /etc/skel/public_html/test/rubytest.rb
echo 'print "Content-type: text/html\n\n"' >> /etc/skel/public_html/test/rubytest.rb
echo 'print "<html><body><p>Hello using Ruby!</p></body></html>"' >> /etc/skel/public_html/test/rubytest.rb
chmod 755 /etc/skel/public_html/test/rubytest.rb
echo '--'

echo "import java.sql.Connection;" > /etc/skel/public_html/test/JDBCTest.java
echo "import java.sql.DriverManager;" >> /etc/skel/public_html/test/JDBCTest.java
echo "class JDBCTest {" >> /etc/skel/public_html/test/JDBCTest.java
echo "public static void main(String[] args) {" >> /etc/skel/public_html/test/JDBCTest.java
echo '  try(Connection con=DriverManager.getConnection("jdbc:mysql://localhost","yourdbusername","yourdbuserpassword")){' >> /etc/skel/public_html/test/JDBCTest.java
echo '  System.out.println("Connected");' >> /etc/skel/public_html/test/JDBCTest.java
echo '} catch (Exception e) {' >> /etc/skel/public_html/test/JDBCTest.java
echo '  e.printStackTrace();' >> /etc/skel/public_html/test/JDBCTest.java
echo '}}}' >> /etc/skel/public_html/test/JDBCTest.java

echo '---- ADDING TEST USER jdoe'
useradd -m jdoe -c 'Jane Doe' -s '/bin/bash'

echo '---- SETTING PASSWORD FOR USER jdoe TO mucis'
echo jdoe:mucis | sudo chpasswd

echo '---- ALLOWING PASSWORD LOGINS - BE SURE TO SET AWS FIREWALL CORRECTLY TO LIMIT ACCESS BY IP'
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

echo '---- CREATING A TEST DATABASE FOR jdoe'
mysql -uroot -e "create database jdoe"
mysql -uroot -e "GRANT ALL PRIVILEGES ON jdoe.* TO jdoe@localhost IDENTIFIED BY 'mucis'"
mysql -ujdoe -pmucis -e "use jdoe;drop table if exists address;create table address(name varchar(50) not null, street varchar(50) not null, primary key(name));"
mysql -ujdoe -pmucis -e "use jdoe;insert into address values('Jane', '123 Main Street');insert into address values('Bob', '222 Oak Street');insert into address values('Sue', '555 Trail Street');"

echo '-----------------------------------------------------------------------------------------------'
echo '--- REMINDERS'
echo '-----------------------------------------------------------------------------------------------'
echo '---- Do not forget to set AWS firewall to limit SSH connections to just a few specific ip addresses'
echo '---- Set firewall to allow port 80 for Apache and port 8080 for Tomcat'
echo '---- Admin user: ubuntu password: none, log in using AWS private key'
echo '---- Test user: jdoe password: mucis'
echo '---- MySQL admin user: root password: none'
echo '---- MySQL jdoe user: jdoe password: mucis'
echo '---- Tomcat admin user: tomcat password: mucis'
echo '---- SECURE MYSQL USING: sudo mysql_secure_installation'
echo '---- REPLACE THE ABOVE PASSWORDS'
echo '---- REBOOT THE SERVER FROM THE AWS CONTROL PANEL'
echo '--'
echo 'Ending shell script at:'
date

