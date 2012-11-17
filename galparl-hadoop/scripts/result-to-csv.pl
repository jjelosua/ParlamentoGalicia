#!/usr/bin/perl

use strict;

my $filename = (scalar(@ARGV) >= 1) ?
    $ARGV[0] : "../output/part-r-00000"; 
my $MIN = 30;
my $MAX = 750;
my $N_WORDS = 30;

my @result = ();

open FILE, "<$filename";
my @lines = ();
while (<FILE>) {
    chomp;
    push @lines, $_;
}
close FILE;

my $nlines = scalar @lines;
my $i = 0;
print "\"name\",\"word\",\"count\"\n";
while ($i < $N_WORDS) {
    my $pos = rand($nlines);
    my $line = $lines[$pos];
    my ($word, $count) = split "\t", $line;
    if (($word =~ /\d+/) || (length($word) == 1)) { next; }
    if ($count >= $MIN && $count <= $MAX) {
        print "\"$word\",\"$word\",$count\n";
        $i++;
    }
}
