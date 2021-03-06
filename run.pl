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

my $c = read_file('data/relations.txt');
my $results = {};
my $sentenceid = 0;
foreach my $line (split /\n/, $c) {
  ++$sentenceid;
  print "<$line>\n";
  my $depth = 0;
  my $rec = [];
  my $state = 0;
  foreach my $char (split //, $line) {
    if ($char eq '[') {
      ++$depth;
      $rec->[$depth] = [];
    } elsif ($char eq ']') {
      if ($depth > 0) {
	$state = 1;
      } else {
	die "oops!\n";
      }
    } elsif ($state == 1) {
      if (! exists $rec->[$depth]) {
	$rec->[$depth] = [$char];
      }
      if (exists $rec->[$depth]) {
	if (! exists $results->{$sentenceid}{$char}) {
	  $results->{$sentenceid}{$char} = [];
	}
	my @copy = @{$rec->[$depth]};
	push @{$results->{$sentenceid}{$char}}, join('',@copy);
      }
      $state = 0;
      --$depth;
    } else {
      for ($i = 1; $i <= $depth; ++$i) {
	push @{$rec->[$i]}, $char;
      }
    }
  }
}

print Dumper($results);
