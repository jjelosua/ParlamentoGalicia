#!/usr/bin/perl

my $threshold = 10;

my $filename = $ARGV[0] || die("word-index-to-sql <filename>");

my $content = do {
    local $/ = undef;
    open FILE, "<$filename";
    <FILE>
};

foreach my $line (split("\n", $content)) {
    my($word, $index) = split("\t", $line);
    my $count = split(",", $index);
    if ($count >= $threshold) {
        print "INSERT INTO word_index(word, indice) VALUES('$word', '$index');\n";
    }
}
