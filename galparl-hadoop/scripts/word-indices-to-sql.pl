#!/usr/bin/perl

my $threshold = 10;

my $filename = $ARGV[0] || die("word-index-to-sql <filename>");

my $content = do {
    local $/ = undef;
    open FILE, "<$filename";
    <FILE>
};

foreach my $line (split("\n", $content)) {
    my($season_word, $index) = split("\t", $line);
    my($season, $word) = split("\\|", $season_word);
    my $count = split(",", $index);
    if ($count >= $threshold) {
        print "INSERT INTO word_index(season, word, indice) VALUES($season, '$word', '$index');\n";
    }
}
