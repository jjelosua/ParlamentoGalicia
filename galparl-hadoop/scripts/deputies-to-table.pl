#!/usr/bin/perl

use strict;

my @lines;

my $file = $ARGV[0] || die("diputados-to-table <file>\n");
if (!(-f $file)) {
    die("File $file doesn't exist\n");
}

open FILE, "<$file";
while (<FILE>) {
    push @lines, $_;
}
close FILE;

foreach my $line (@lines) {
    chomp($line);
    my ($fullname, $session, $party, $sex) = split ";", $line;
    my ($surname, $name) = split ",", $fullname;
    print "INSERT INTO deputies(fullname, name, surname, session, party, sex) VALUES('".trim($fullname)."', '".trim($name)."', '"
            .trim($surname)."', '".trim($session)."', '".trim($party)."', '".trim(uc($sex))."');\n";
}

sub trim
{
    my($str) = @_;

    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    return $str;
}
