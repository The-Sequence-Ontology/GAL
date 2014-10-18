#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

cat ids.txt | extract_rows --col 0 data.txt
cat ids.txt | extract_rows -v --col 0 data.txt

Description:

This script will extract rows from a data file that match a stream of IDs.

Options:

  col:        The ID column in the data file
  reverse|v:  Reverse the query.  Only extract rows that don't match IDs.
";


my ($help, @cols, $reverse);
my $opt_success = GetOptions('help'      => \$help,
			     'col=i'     => \@cols,
			     'reverse|v' => \$reverse,
			      );

die $usage if $help || ! $opt_success;

my %ids = map {chomp;($_ => 1)} (<STDIN>);

my $file = shift;
die $usage unless $file;
open (my $IN, '<', $file) or die "Can't open $file for reading\n$!\n";

while (<$IN>) {

	my @columns = split /\t/, $_;
	chomp @columns;
	my $column_key = join "\t", @columns[@cols];
	next if   $ids{$column_key} &&   $reverse;
	next if ! $ids{$column_key} && ! $reverse;
	print;
}

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

