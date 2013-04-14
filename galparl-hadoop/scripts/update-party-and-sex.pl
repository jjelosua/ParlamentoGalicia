#!/usr/bin/perl

use strict;

my $host = "localhost";
my $user = "root";
my $passwd = "passwd";
my $db = "galparl";

my @entries = query("select season, fullname from entries");
foreach my $entry (@entries) {
    my ($season, $fullname) = split "\t", $entry;
    my @result = query("select party, sex from deputies where season = $season AND surname = '$fullname'");
    foreach my $row (@result) {
        my ($party, $sex) = split "\t", $row;
        query("update entries set party = '$party', sex = '$sex' where season = $season AND fullname = '$fullname'");
        # print "update entries set party = '$party', sex = '$sex' where season = $season AND fullname = '$fullname'";
    }
}

sub query
{
    my($sql) = @_;

    my $result = `mysql -h $host -u $user -p$passwd -e "$sql" $db;`; 
    my @lines = split "\n", $result;
    shift @lines;
    return @lines;
}
