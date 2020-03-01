#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

map_seqids map_file.txt feature_file.gff3

Description:

Map the seqids in a GFF3 file to new values.  For example, you want to
map a GFF3 file that uses NCBI RefSeq contig accessions (NC_000001) to
UCSC style chromosome names (chr1).  The map file should have to
tab-delimited columns with the old seqid in the first column and the
new seqid in the second column.

";


my ($help);
my $opt_success = GetOptions('help'    => \$help,
			      );

if ($help) {
    print $usage;
    exit(0);
}
die $usage if ! $opt_success;

my ($map_file, $gff_file) = @ARGV;
die $usage unless $map_file && $gff_file;

open (my $MAP, '<', $map_file) or
  handle_message('FATAL', 'cant_open_file_for_reading',  $map_file);
open (my $GFF, '<', $gff_file) or
  handle_message('FATAL', 'cant_open_file_for_reading',  $gff_file);

my %map;
LINE:
while (my $line = <$MAP>) {
  chomp $line;
  next LINE if $line =~ /^(\#|\s)/;
  my ($old, $new) = split /\s+/, $line;
  $map{$old} = $new;
}

ROW:
while (my $line = <$GFF>) {

  if ($line =~ /^\#/) {
          print $line;
          next ROW;
  }
  chomp $line;
  my @fields = split /\t/, $line;
  $fields[0] = exists $map{$fields[0]} ? $map{$fields[0]} : $fields[0];
  print join "\t", @fields;
  print "\n";
}

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

sub handle_message {

  my ($level, $code, $message) = @_;

  $level   ||= 'FATAL';
  $code    ||= 'unkown_error';
  $message ||= 'No additional information';

  print STDERR join ' : ', ($level, $code, $message);
  print STDERR "
";

  die  if $level eq 'FATAL';
}

#-----------------------------------------------------------------------------

