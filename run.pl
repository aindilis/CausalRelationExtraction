#!/usr/bin/perl -w

use Data::Dumper;
use File::Slurp;
use IO::File;
use Lingua::EN::Sentence qw(get_sentences);

my $file = $ARGV[0];

if (! -f $file) {
  die "Usage: './run.pl <TEXTFILE>'\n";
}

my $contents = read_file($file);
my $sentences = get_sentences($contents);

my $fh = IO::File->new;
$fh->open(">./data/sentences.txt") or die "cannot open sentences\n";

foreach my $sentence (@$sentences) {
  $sentence =~ s/\s+/ /sg;
  $sentence =~ s/^\s/ /s;
  $sentence =~ s/\s$/ /s;
  print $fh $sentence."\n";
}

$fh->close;

system "java -cp target/causal-relation-extraction-1.0-SNAPSHOT.jar:/home/andrewdo/.m2/repository/edu/stanford/nlp/stanford-parser/3.4.1/stanford-parser-3.4.1.jar:/var/lib/myfrdcsa/sandbox/stanford-parser-20140827/stanford-parser-20140827/stanford-parser-3.4.1-models.jar org.frdcsa.causalrelationextraction.App \"./data/sentences.txt\"";

my $c = read_file('./data/relations.txt');

my $i = 1;
my $allitems = {};
my $items = {};
foreach my $line (split /\n/, $c) {
  if ($line =~ /^\{(.*)\}\{(.*)\}\{(.*)\}$/) {
    $items->{$i}{$1}{$2}{$3} = 1;
    $allitems->{$1}{$2}{$3} = 1;
  } elsif ($line =~ /^-$/) {
    print $i++."\n";
  }
}

print Dumper({Items => $items, AllItems => $items});
