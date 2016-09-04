# awssetup
Various scripts to ease setup of AWS EC2 Ubuntu 16.04 servers for CS student use.

## Dev Servers
These scripts aid in setting up a developer server. 

### Text-Based
Running the d1 script will build text-based server 
with support for a variety of programming languages and servers. This works great on a micro instance 
and probably will run okay on a nano instance. It easily keeps up with 30 or more users logged in at once.

Be sure to open AWS firewall ports for http, ssh, and possibly TCP on 8080 if using Tomcat for your student's 
IP addresses. I usually open http port 80 and port 8080 to the world. Of course there are many other ways of
controlling security. So far I prefer this method over using software like denyhosts--just let the AWS firewall 
block out the rest of the world.

### GUI-Based
After running d1 you can next run the d2 script. This will create a Ubuntu Mate server that supports xrdp.
Students can log in remotely using Windows Remote Desktop on either Mac OS X or Windows. This option supports
IDEs such as Eclipse / STS, NetBeans, and others. However, it is recommended to use at least a medium instance with
4GB RAM for a single user. Each additional user might require another 2 GB or so depending on what apps they will be
running. I just have my students use free AWS Educate accounts and run their own dev server.

## Python Server
This is a simple server designed for a non-majors class I teach using Python. It is a Ubuntu Mate GUI xrdp server that allows
students to connect using Windows remote desktop. I tried to simplify the GUI to just the basics. A medium instance (4GB)
should be able to support 8 students at once or so given the simple software used. If you add an IDE then you might need
a lot more memory.

Be sure to open some AWS firewall ports to allow RDP from the IP addresses of your students.

## addusers.pl
I run this Perl script as root to setup all of the student accounts. It is easy to get a list of student email addresses separated
by commas. I feed this into the addusers.pl script and it creates Linux accounts and MySQL accounts for each student.
Saves me a ton of work.


