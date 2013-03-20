#!/usr/bin/perl

my $threshold = 10;

my $filename = $ARGV[0] || die("word-count-to-sql <filename>");

my $content = do {
    local $/ = undef;
    open FILE, "<$filename";
    <FILE>
};

foreach my $line (split("\n", $content)) {
    my($word, $count) = split("\t", $line);
    if ($count >= $threshold) {
        print "INSERT INTO word_count(word, count) VALUES('$word', $count);\n";
    }
}
