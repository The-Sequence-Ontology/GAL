#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

use lib '/uufs/chpc.utah.edu/common/HIPAA/u0129786/GAL/lib';
use GAL::Annotation;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

hgvs2genomic.pl -g genes.gff3 -f genome.fasta hgvs.txt

Description:

A script to convert cDNA HGVS (e.g. c.3140C>A, c.3003_3006del etc.)
notation to genomic coordinates.

Positional Arguments:

A text file where the first column is the HGVS notation to convert and
the optional second column is the transcript ID that the HGVS
numbering refers to.

Options

  --transcript, -t <Transcript ID>

    The transcript that the HGVS notations are built on.  Note in the
    positional argument above that this can be given as a second
    column in the HGVS file.  If all HGVS notations in that file refer
    to the same transcript, then that transcript ID can be provided
    through this option.  Transcript IDs provided in the file will
    take precedent over a transcript ID provided by this option.
    Records with missing transcript IDs in the HGVS file will use the
    transcript ID provided by this option.

  --genes, -g <gene models GFF3 file>

    A GFF3 file with gene models used to interpret/convert cDNA
    coordinates to genomic coordinates.

  --fasta, -f <genome fasta file>

    A fasta file the provides the genomic sequence associated with the
    given GFF3 file.

";


my $cl = join ' ', $0, @ARGV;

my ($help, $trns_id, $gff3_file, $fasta_file);
my $opt_success = GetOptions('help'           => \$help,
                             'transcript|t=s' => \$trns_id,
			     'gff3|g=s'       => \$gff3_file,
			     'fasta|f=s'      => \$fasta_file,
			    );

die $usage if ! $opt_success;
print $usage if $help;

die "FATAL : missing_required_gff3_file : $cl\n" unless $gff3_file;
die "FATAL : missing_required_fasta_file : $cl\n" unless $fasta_file;

# Assuming defaults (GFF3 parser and SQLite storage)
my $annot = GAL::Annotation->new($gff3_file, $fasta_file);
my $features = $annot->features;
my $fasta_db = $annot->fasta;

my $hgvs_file = shift;
die "$usage\n\nFATAL : missing_required_hgvs_file : $cl\n" unless $hgvs_file;
open (my $IN, '<', $hgvs_file) or die "FATAL : cant_open_file_for_reading : $hgvs_file\n$!\n";

my %trns_cache;
LINE:
while (my $line = <$IN>) {

  chomp $line;
  my ($hgvs, $my_trns_id) = split /\t/, $line;
  $my_trns_id ||= $trns_id;

  if (! defined $my_trns_id) {
    die('FATAL : no_transcript_id_provided : ' .
	'Either provide transcript ID in second' .
	'column of HGVS file or on the command ' .
	"line with the --transcript option\n\n$line\n");
  }

  # Transcript
  my $trns;
  if (exists $trns_cache{$my_trns_id}) {
    $trns =  $trns_cache{$my_trns_id};
  }
  else {
    $trns = $features->find({feature_id => $my_trns_id});
    $trns_cache{$trns_id} = $trns;
    print '';
  }

  my $strand = $trns->strand;
  my $chr = $trns->seqid;
  my $fasta= $fasta_db->get_Seq_by_id($chr);

  my ($genomic_pos, $ref, $alt);

  # HGVS SNV
  if ($hgvs =~ /^c\.\d+[ACGT]>[ACGT]$/) {
          # c.50T>C
          # c.59T>C
          # c.59T>G
          # c.64T>C
          my $hgvs_copy = $hgvs;
         $hgvs_copy =~ s/^c\.//;
          my ($cds_pos) = $hgvs_copy =~ /^(\d+)/;
          $hgvs_copy =~ s/^\d+//;
          ($ref, $alt) = split />/, $hgvs_copy;
          if ($strand eq '-') {
                  $ref = $trns->annotation->revcomp($ref);
                  $alt = $trns->annotation->revcomp($alt);
          }
          ($genomic_pos) = $trns->cds2genome($cds_pos);
  }
  # HGVS Deletion
  elsif ($hgvs =~ /^c\.(\d+(_\d+)?)del$/) {
          # c.1491del
          # c.53_73del
          # c.62_73del
          # c.66_67del
          # c.70del
          # c.100_103del
          # c.139_152del
          # c.141_142del
          my $hgvs_copy = $hgvs;
          $hgvs_copy =~ s/^c\.//;
          my ($cds_pos) = $hgvs_copy =~ /^(\d+(_\d+)?)del$/;
          my ($cds_start, $cds_end) = split /_/, $cds_pos;
          $cds_end ||= $cds_start;
          my ($genomic_start) = $trns->cds2genome($cds_start);
          my ($genomic_end) = $trns->cds2genome($cds_end);
          $genomic_end ||= $genomic_start;
          ($genomic_start, $genomic_end) = sort {$a <=> $b} ($genomic_start, $genomic_end);
          my $genomic_len = $genomic_end - $genomic_start + 1;
          $genomic_pos = $genomic_start - 1;
          $ref = $fasta->subseq($genomic_pos, $genomic_end);
          $alt = substr($ref, 0, 1);
  }
  # # HGVS Deletion/Insertion (MNV)
  elsif ($hgvs =~ /^c\.(\d+(_\d+))delins[ACGT]+$/) {
          # c.3_4delinsTT
          # c.161_162delinsAA
          # c.266_270delinsCTT
          # c.435_439+2delinsAG
          # c.659_661delinsTG
          # c.1433_1444delinsC
          # c.1454delinsTGT
          # c.2276delinsCA
          # c.2611_2612delinsTG
          # c.2662_2666delins21
          # c.2766_2773delinsTGCC
          # c.2774_2788delinsC-
          # c.3003_3008delinsGC
          my $hgvs_copy = $hgvs;
          $hgvs_copy =~ s/^c\.//;
          my ($cds_pos) = $hgvs_copy =~ /^(\d+(_\d+)?)delins[ACGT]+$/;
          $hgvs_copy =~ s/^(\d+(_\d+)?)delins//;
          $alt = $hgvs_copy;
          # unless ($alt =~ /^[ACGT]+$/) {
          #         warn "WARN : cant_parse_hgvs : $hgvs\n";
          #         next LINE;
          # }
          my ($cds_start, $cds_end) = split /_/, $cds_pos;
          my ($genomic_start) = $trns->cds2genome($cds_start);
          my ($genomic_end) = $trns->cds2genome($cds_end);
          $genomic_end ||= $genomic_start;
          ($genomic_start, $genomic_end) = sort {$a <=> $b} ($genomic_start, $genomic_end);
          my $genomic_len = $genomic_end - $genomic_start + 1;
          $genomic_pos = $genomic_start - 1;
          $ref = $fasta->subseq($genomic_pos, $genomic_end);
          if ($strand eq '-') {
                  $alt = $trns->annotation->revcomp($alt);
          }
          my $alt_xtra = substr($ref, 0, 1);
          $alt = $alt_xtra . $alt;
  }
  # HGVS Insertion
  elsif ($hgvs =~ /^c\.(\d+(_\d+))ins[ACGT]+$/) {
          # c.2059_2060insT
          my $hgvs_copy = $hgvs;
          $hgvs_copy =~ s/^c\.//;
          my ($cds_pos) = $hgvs_copy =~ /^(\d+(_\d+)?)ins[ACGT]+$/;
          $hgvs_copy =~ s/^(\d+(_\d+)?)ins//;
          $alt = $hgvs_copy;
          unless ($alt =~ /^[ACGT]+$/) {
                  warn "WARN : cant_parse_hgvs : $hgvs\n";
                  next LINE;
          }
          my ($cds_start, $cds_end) = split /_/, $cds_pos;
          my ($genomic_start) = $trns->cds2genome($cds_start);
          my ($genomic_end) = $trns->cds2genome($cds_end);
          $genomic_end ||= $genomic_start;
          ($genomic_start, $genomic_end) = sort {$a <=> $b} ($genomic_start, $genomic_end);
          # my $genomic_len = $genomic_end - $genomic_start + 1;
          $genomic_pos = $genomic_start;
          $ref = $fasta->subseq($genomic_pos, $genomic_pos);
          if ($strand eq '-') {
                  $alt = $trns->annotation->revcomp($alt);
          }
          my $alt_xtra = substr($ref, 0, 1);
          $alt = $alt_xtra . $alt;
          print '';
  }
  # HGVS Duplication
  elsif ($hgvs =~ /^c\.(\d+(_\d+)?)dup$/) {
          # c.11dup
          # c.237dup
          # c.270dup
          # c.311dup
          # c.337dup
          # c.518_521dup
          # c.582dup
          # c.755+1_755+2dup
          # c.838_839dup
          # c.903dup
          my $hgvs_copy = $hgvs;
          $hgvs_copy =~ s/^c\.//;
          my ($cds_pos) = $hgvs_copy =~ /^(\d+(_\d+)?)dup$/;
          $hgvs_copy =~ s/^(\d+(_\d+)?)dup//;
          my ($cds_start, $cds_end) = split /_/, $cds_pos;
          $cds_end ||= $cds_start;
          my ($genomic_start) = $trns->cds2genome($cds_start);
          my ($genomic_end) = $trns->cds2genome($cds_end);
          ($genomic_start, $genomic_end) = sort {$a <=> $b} ($genomic_start, $genomic_end);
          $genomic_pos = $genomic_start - 1;
          $ref = $fasta->subseq($genomic_pos, $genomic_end);
          $alt = $ref;
          $alt =~ s/^[ACGT]//;
          $alt = $ref . $alt;
          print '';
  }
  # HGVS Splice
  elsif ($hgvs =~ /^c\.\d+[+\-]\d+[ACGT]>[ACGT]/) {
          # c.81+1G>A
          # c.387+1G>A
          # c.388–1G>C
          # c.439+1G>T
          # c.439+1G>A

          my $hgvs_copy = $hgvs;
          $hgvs_copy =~ s/^c\.//;
          my ($cds_pos) = $hgvs_copy =~ /^(\d+)/;
          $hgvs_copy =~ s/^(\d+)//;
          my ($direction, $length) = $hgvs_copy =~ /^([+\-])(\d+)/;
          if ($direction eq '+') {
                  $direction = 1;
          }
          elsif ($direction eq '-') {
                  $direction = -1;
          }
          else {
                  warn "WARN : invalid_splice_annotation : $hgvs\n";
                  next LINE;
          }
          $direction = $strand eq '-' ? $direction * -1 : $direction;
          $hgvs_copy =~ s/^[+\-]\d+//;

          ($ref, $alt) = split /\>/, $hgvs_copy;

          ($genomic_pos) = $trns->cds2genome($cds_pos);
          $genomic_pos += ($length * $direction);
          # $genomic_pos -= 1;
          my $fasta_ref = $fasta->subseq($genomic_pos, $genomic_pos);
          if ($strand eq '-') {
                  $ref = $trns->annotation->revcomp($ref);
                  $alt = $trns->annotation->revcomp($alt);
          }
          print '';
  }
  # HGVS WTF
  else {
          warn "WARN : cant_parse_hgvs : $hgvs\n";
          next LINE;
  }

  my $genomic_locus = "$chr:$genomic_pos:$ref:$alt";

  print join("\t", $hgvs, $my_trns_id, $genomic_locus);
  print "\n";
  print '';

  #---------------------
  # Debugging statements
  #---------------------
  # print "HGVS: $hgvs\n";
  # print "HGVS_parts: $cds_pos, $ref, $alt\n";
  # print "Genomic: $chr:$genomic_pos:$ref:$alt\n";
  # print "TRNS: $my_trns_id\n";
  # print "T-Start: " . $trns->my_start . "\n";
  # print "C-Start: " . $trns->CDS_start . "\n";
  # print "C2M-Start: " . ${$trns->genome2me($trns->CDS_start)}[0] . "\n";
  # print "T-Length: " . $trns->length . "\n";
  # print "G2M: " . join(',', $trns->genome2me(10639250)) . "\n";
  # print "M2G: " . join(',', $trns->me2genome(10)) . "\n";
  # print "C2M: " . join(',', $trns->cds2mrna(1)) . "\n";
  # print "C2G: " . join(',', ${$trns->cds2genome(1)}[0]) . "\n";
  # #print "G
  # print "\n\n----------------------------------------\n\n";
  # print '';
}
