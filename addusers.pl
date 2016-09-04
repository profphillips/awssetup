#!/usr/bin/perl -w
# addusers.pl by John Phillips on 01/16/2003 revised 9/04/2016
#
# This program will read in a textfile of user email addresses and create
# a Linux account and a MySQL account for each.
#
# The students.txt file contains the students to add and
# is in the form (separators such as semicolons, spaces, and tabs are fine):
#
# emailname1@someemailaddress, emailname2@someemailaddress
#
# Run as root: # perl addusers.pl students.txt

$userPassword = 'starter_pw_for_all_users';

use DBI;
$dbAdmin = "root";
$dbPassword = "your_root_db_pw";

print "Connecting to MySQL using DBI\n";
$dbh = DBI->connect('DBI:mysql:mysql', $dbAdmin, $dbPassword)
  or die "Couldn't connect to database: " . $dbh->errstr;

$_ = <>;
$count = 0;
while( /(\w+?)@/g ) {

    $count++;
    $user = $1;

    print "\n***** Creating Linux account for a user id of $user\n";
    system("/usr/sbin/useradd -c '$user' -m $user -s '/bin/bash'");
    system("echo $user:$userPassword | /usr/sbin/chpasswd");

    print "Changing permissions on /home/$user/ to 711\n";
    chmod( 0711, "/home/$user/" );

    $q = "create database $user;";
    print "Creating MySQL database using: $q\n";
    $sth = $dbh->prepare($q) or die "Could not prepare statement: $dbh->errstr";
    $sth->execute();

    $q = "grant all privileges on $user.* to $user\@localhost identified by '$user';";
    print "Granting database permissions using: $q\n";
    $sth = $dbh->prepare( $q ) or die "Could not prepare statement: $dbh->errstr";
    $sth->execute();

}
print "\n$count accounts were processed\n\n";
