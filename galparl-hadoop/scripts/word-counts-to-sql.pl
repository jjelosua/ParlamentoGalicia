#!/usr/bin/perl

my $threshold = 10;

my $filename = $ARGV[0] || die("word-counts-to-sql <filename>");

my $content = do {
    local $/ = undef;
    open FILE, "<$filename";
    <FILE>
};

foreach my $line (split("\n", $content)) {
    my($season_word, $count) = split("\t", $line);
    my($season, $word) = split("\\|", $season_word);
    if ($count >= $threshold) {
        print "INSERT INTO word_count(season, word, count) VALUES($season, '$word', $count);\n";
    }
}
