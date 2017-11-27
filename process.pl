#!/usr/bin/perl -w

use Data::Dumper;
use File::Slurp;

my $c = read_file('data-with-label.txt');
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
