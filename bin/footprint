#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Set::IntSpan::Fast;
#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

footprint file.txt
cat file.txt | footprint
footprint --gff --type CDS file.gff
footprint --zero file.bed
footprint --id 0 --col1 1 --col2 2 file.txt

Description:

This scirpt will determine the footprint of a series of coordinate pairs.

Options:

  gff:    Assume input is in GFF/GTF format.
  zero:   Coordinates are zero based (BED files, UCSC tables etc).
  type:   Valid only with the gff flag.  Report footprint by type.  May
          be given multiple times.
  id:     A column number of an ID that the coordinates are relative to
          (0 based) [0].
  start:  The column of the start coordinate (0 based) [1].
  end:    The column of the end coordinate (0 based) [2].
  spans:  Print the merged spans rather than the footprint.

";


my ($help, $gff, $zero, @types, $id_col, $start_col, $end_col, $spans);
my $opt_success = GetOptions('help'    => \$help,
			     'gff'     => \$gff,
			     'zero'    => \$zero,
			     'type=s'  => \@types,
			     'id=i'    => \$id_col,
			     'start=i' => \$start_col,
			     'end=i'   => \$end_col,
			     'spans'   => \$spans,
			      );

die $usage if $help || ! $opt_success;

my @files = @ARGV;
die $usage unless (@files || ! -t STDIN);
#push @files, 'STDIN' if ! -t STDIN;

$id_col    ||= 0;
$start_col ||= 1;
$end_col   ||= 2;

if ($gff)  {
    ($id_col, $start_col, $end_col) = (0, 3, 4);
    undef $zero;
}

my %types;
map {$types{$_}++} @types if @types;

for my $file (@files) {
    my $IN;
    #if (! -t STDIN) {
    #	open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
    #}
    #else {
    	open ($IN, $file) or die "Can't open $file for reading: $!\n";
    #}
    
    my %data;
    while (<$IN>) {
	last if /^\s*\##FASTA/ && $gff;
	next if /^\s*\#/;
	chomp;
	my @fields = split /\t/, $_;
	next if (%types && ! $types{$fields[2]});
	
	my ($seqid, $start, $end) = @fields[$id_col, $start_col, $end_col];
	$start++ if $zero;
	$data{$seqid} ||= Set::IntSpan::Fast->new();
	$data{$seqid}->add_range($start, $end);
    }
    
    my $footprint;
    for my $seqid (keys %data) {
	my $set = $data{$seqid};
	if ($spans) {
	    my $iter = $set->iterate_runs();
	    while (my ( $start, $end ) = $iter->()) {
		print join "\t", ($seqid, '.', 'region', $start, $end, qw(. . . .));
		print "\n";
	    }
	}
	else {
	    $footprint += scalar $set->as_array;
	}
    }
    print "$file\t$footprint\n" unless $spans;
}

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

