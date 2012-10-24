package GAL::Schema::Result::Feature::transcript;

use strict;
use warnings;
use base qw(GAL::Schema::Result::Feature::sequence_feature);

=head1 NAME

GAL::Schema::Result::Feature::transcript - A transcript object for the GAL
Library

=head1 VERSION

This document describes GAL::Schema::Result::Feature::transcript
version 0.01

=head1 SYNOPSIS

    use GAL::Annotation;
    my $feat_store = GAL::Annotation->new(storage => $feat_store_args,
					  parser  => $parser_args,
					  fasta   => $fasta_args,
					 );

    $feat_store->load_files(files => $feature_file,
			    mode  => 'overwrite',
			    );

    my $features = $feat_store->schema->resultset('Feature');

    my $genes = $features->search({type => 'gene'});
    while (my $gene = $genes->next) {
      my $transcripts = $gene->transcripts;
      while (my $transcript = $transcripts->next) {
	my $id    = $transcript->feature_id;
	my $start = $transcript->start;
	my $end   = $transcript->end;
      }

    }

=head1 DESCRIPTION

<GAL::Schema::Result::Feature::transcript> provides a <GAL::Schema::Result::Feature>
subclass for transcript specific behavior.

=head1 METHODS

=cut

#-----------------------------------------------------------------------------

=head2 exons_genomic

 Title   : exons_genomic
 Usage   : $exons = $self->exons_genomic
 Function: Get the transcripts exons sorted in genomic order
 Returns : A DBIx::Class::Result object loaded up with exons
 Args    : None

=cut

sub exons_genomic {
  my $self = shift;
  my $exons = $self->children({type => 'exon'},
			      {order_by => {'-asc' => 'start'},
			       distinct => 1});

  return wantarray ? $exons->all : $exons;
}

#-----------------------------------------------------------------------------

=head2 exons_rs

 Title   : exons_rs
 Usage   : $exons_rs = $self->exons_rs
 Function: Get the transcript's exons sorted in order of the transcripts strand
 Returns : A DBIx::Class::Result object loaded up with exons
 Args    : None

=cut

sub exons_rs {
  my $self = shift;

  my $sort_order;
  if ($self->strand eq '-') {
    $sort_order = {'-desc' => 'end'};
  }
  else {
    $sort_order = {'-asc' => 'start'};
  }

  my $exons = $self->children({type => 'exon'},
			       {order_by => $sort_order,
				distinct => 1});

  return wantarray ? $exons->all : $exons;
}

#-----------------------------------------------------------------------------

=head2 exons

 Title   : exons
 Usage   : $exons = $self->exons
 Function: Get the transcript's exons sorted in order of the transcripts strand
 Returns : An array(ref) of exon objects
 Args    : None

=cut

sub exons {
  my $self = shift;

  my @exons = grep {$_->type eq 'exon'} $self->children->all;
  if ($self->strand eq '-') {
    @exons = sort {$b->end <=> $a->end} @exons;
  }
  else {
    @exons = sort {$a->start <=> $b->start} @exons;
  }

  return wantarray ? @exons : \@exons;
}

#-----------------------------------------------------------------------------

=head2 introns_genomic

 Title   : introns_genomic
 Usage   : $introns = $self->introns_genomic
 Function: Get the transcript's introns sorted in genomic order
 Returns : A DBIx::Class::Result object loaded up with introns
 Args    : None

=cut

sub introns_genomic {
  my $self = shift;

  my $introns = $self->children({type => 'intron'},
				 {order_by => {'-asc' => 'start'},
				  distinct => 1});

  if (! $introns->count) {
    $self->infer_introns($introns);
  }

  return wantarray ? $introns->all : $introns;
}

#-----------------------------------------------------------------------------

=head2 introns

 Title   : introns
 Usage   : $introns = $self->introns
 Function: Get the transcripts introns sorted in the order of the transcripts
	   strand.
 Returns : A DBIx::Class::Result object loaded up with introns
 Args    : None

=cut

sub introns {
  my $self = shift;

  my $sort_order;
  if ($self->strand eq '-') {
    $sort_order = {'-desc' => 'end'};
  }
  else {
    $sort_order = {'-asc' => 'start'};
  }

  my $introns = $self->children({type => 'intron'},
				{order_by => $sort_order,
				 distinct => 1});

  if (! $introns->count) {
    $self->infer_introns($introns);
  }

  return wantarray ? $introns->all : $introns;
}

#-----------------------------------------------------------------------------

=head2 infer_introns

 Title   : infer_introns
 Usage   : $introns = $self->infer_introns
 Function: Infer introns for the transcript.
 Returns : A DBIx::Class::Result object loaded up with introns
 Args    : None

=cut

sub infer_introns {
  my ($self, $introns) = @_;

  if (! $introns) {
    my $sort_order;
    if ($self->strand eq '-') {
      $sort_order = {'-desc' => 'end'};
    }
    else {
      $sort_order = {'-asc' => 'start'};
    }

    $introns ||= $self->children({type => 'intron'},
				 {order_by => $sort_order,
				  distinct => 1});
  }

  # Keep the order_by like this so we stay in genomic order
  my $exons = $self->children({type => 'exon'},
			      {order_by => { -asc => 'start' },
			       distinct => 1});

  my @coordinates;
  while(my $exon = $exons->next) {
    push @coordinates, ($exon->start, $exon->end);
  }

  shift @coordinates;
  pop   @coordinates;

  my %template = (seqid  => $self->seqid,
		  source => $self->source,
		  type   => 'intron',
		  score  => '.',
		  strand => $self->strand,
		  phase  => '.',
		 );

  my $parent_id = $self->feature_id;

  my $count = 1;
  my @introns;
  while (@coordinates) {
    my ($start, $end) = (shift @coordinates,
			 shift @coordinates);
    my $feature_id = $parent_id . ':intron:';
    $feature_id .= sprintf("%03d", $count++);
    my @attrbs = ({feature_id => $feature_id,
		   att_key    => 'ID',
		   att_value  => $feature_id},
		  {feature_id => $feature_id,
		   att_key    => 'Parent',
		   att_value  => $parent_id},
		 );
    my @rels = {parent => $parent_id,
		child  => $feature_id};

    my %intron = %template;
    @intron{qw(feature_id start end attributes my_parents)} =
      ($feature_id, $start, $end, \@attrbs, \@rels);
    my $intron = $introns->find_or_create(\%intron);
    bless $intron, 'GAL::Schema::Result::Feature::intron';
    push @introns, $intron;
  }
  $introns->set_cache(\@introns);
}

#-----------------------------------------------------------------------------

=head2 mature_seq_genomic

 Title   : mature_seq_genomic
 Usage   : $seq = $self->mature_seq_genomic
 Function: Get the transcripts spliced genomic sequence (not reverse
	   complimented for minus strand features).
 Returns : A text string of the transcripts splice genomic sequence.
 Args    : None

=cut

sub mature_seq_genomic {
  my $self = shift;

  my $mature_seq_genomic;
  map {$mature_seq_genomic .= $_->genomic_seq} $self->exons_genomic->all;
  return $mature_seq_genomic;
}

#-----------------------------------------------------------------------------

=head2 mature_seq

 Title   : mature_seq
 Usage   : $seq = $self->mature_seq
 Function: Get the transcripts spliced sequence reverse complimented for minus
	   strand features.
 Returns : A text string of the transcripts splice genomic sequence.
 Args    : None

=cut

sub mature_seq {
  my $self = shift;

  my $mature_seq = $self->mature_seq_genomic;
  $mature_seq = $self->annotation->revcomp($mature_seq)
    if ($self->strand eq '-');
  return $mature_seq;
}

#-----------------------------------------------------------------------------

=head2 five_prime_UTR_seq_genomic

 Title   : five_prime_UTR_seq_genomic
 Usage   : $seq = $self->five_prime_UTR_seq_genomic
 Function: Get the transcripts spliced five_prime_UTR genomic sequence (not
	   reverse complimented for minus strand features.
 Returns : A text string of the five_prime_UTR spliced genomic sequence.
 Args    : None

=cut

sub five_prime_UTR_seq_genomic {
  my $self = shift;
  my $five_prime_UTR_seq_genomic;
  map {$five_prime_UTR_seq_genomic .= $_->genomic_seq}
    $self->five_prime_UTRs_genomic->all;
  return $five_prime_UTR_seq_genomic;
}

#-----------------------------------------------------------------------------

=head2 five_prime_UTR_seq

 Title   : five_prime_UTR_seq
 Usage   : $seq = $self->five_prime_UTR_seq
 Function: Get the transcripts spliced five_prime_UTR sequence reverse
	   complimented for minus strand features.
 Returns : A text string of the five_prime_UTR spliced sequence.
 Args    : None

=cut

sub five_prime_UTR_seq {
  my $self = shift;
  my $five_prime_UTR_seq = $self->five_prime_UTR_seq_genomic;
  if ($self->strand eq '-') {
    $five_prime_UTR_seq =
      $self->annotation->revcomp($five_prime_UTR_seq);
  }
  return $five_prime_UTR_seq;
}

#-----------------------------------------------------------------------------

=head2 three_prime_UTR_seq_genomic

 Title   : three_prime_UTR_seq_genomic
 Usage   : $seq = $self->three_prime_UTR_seq_genomic
 Function: Get the transcripts spliced three_prime_UTR genomic sequence (not
	   reverse complimented for minus strand features.
 Returns : A text string of the three_prime_UTR spliced genomic sequence.
 Args    : None

=cut

sub three_prime_UTR_seq_genomic {
  my $self = shift;
  my $three_prime_UTR_seq_genomic;
  map {$three_prime_UTR_seq_genomic .= $_->genomic_seq}
    $self->three_prime_UTRs_genomic->all;
  return $three_prime_UTR_seq_genomic;
}

#-----------------------------------------------------------------------------

=head2 three_prime_UTR_seq

 Title   : three_prime_UTR_seq
 Usage   : $seq = $self->three_prime_UTR_seq
 Function: Get the transcripts spliced three_prime_UTR sequence reverse
	   complimented for minus strand features.
 Returns : A text string of the three_prime_UTR spliced sequence.
 Args    : None

=cut

sub three_prime_UTR_seq {
  my $self = shift;
  my $three_prime_UTR_seq = $self->three_prime_UTR_seq_genomic;
  if ($self->strand eq '-') {
    $three_prime_UTR_seq =
      $self->annotation->revcomp($three_prime_UTR_seq);
  }
  return $three_prime_UTR_seq;
}

#-----------------------------------------------------------------------------

=head2 length

 Title   : length
 Usage   : $length = $self->length
 Function: Get the length of the mature transcript - the sum of all of its
	   exon lengths.
 Returns : An integer
 Args    : None

=cut

sub length {
  my $self = shift;
  my $length;
  map {$length += $_->length} $self->children({type => 'exon'},
					      {distinct => 1})->all;
  $self->warn('transcript_has_no_exons', $self->feature_id) unless $length;
  return $length;
}

#-----------------------------------------------------------------------------

=head2 coordinate_map

 Title   : coordinate_map
 Usage   : $map = $self->coordinate_map
 Function: Get the coordinate map the which has the structure:
	   $coordinate_map{genome2me}{$genomic_position}    = $transcript_position;
	   $coordinate_map{me2genome}{$transcript_position} = $genomic_position;
	   And thus can be used to map feature to genomic coordinates and vice versa.
 Returns : A hash or reference of the above map.
 Args    : None

=cut

sub coordinate_map {
  my $self = shift;
  if (! $self->{coordinate_map}) {
    my $strand = $self->strand;
    my $length = $self->length;
    my %coordinate_map;
    my @exons = $self->exons_genomic->all;
    my ($transcript_position, $increment);
    if ($strand eq '-') {
      $transcript_position = $length - 1;
      $increment = -1;
    }
    else {
      $transcript_position = 1;
      $increment = 1;
    }
    for my $exon (@exons) {
      my $start = $exon->start;
      my $end   = $exon->end;
      for my $genomic_position ($start .. $end) {
	$coordinate_map{genome2me}{$genomic_position}    = $transcript_position;
	$coordinate_map{me2genome}{$transcript_position} = $genomic_position;
	$transcript_position += $increment;
      }
    }
    $self->{coordinate_map} = \%coordinate_map;
  }
  return wantarray ? %{$self->{coordinate_map}} : $self->{coordinate_map};
}

#-----------------------------------------------------------------------------

=head2 genome2me

 Title   : genome2me
 Usage   : $my_coordinates = $self->genome2me(@genome_coordinates);
 Function: Transform genomic coordinates to mature transcript coordinates.
 Returns : An array or reference of mature transcript coordinates.
 Args    : An array reference of genomic coordinates.

=cut

sub genome2me {
  my ($self, @coordinates) = @_;
  my $coordinate_map = $self->coordinate_map;
  my @my_coordinates;
  for my $coordinate (@coordinates) {
    push @my_coordinates, $coordinate_map->{genome2me}{$coordinate};
  }
  return wantarray ? @my_coordinates : \@my_coordinates;
}

#-----------------------------------------------------------------------------

=head2 me2genome

 Title   : me2genome
 Usage   : $genomic_coordinates = $self->me2genome(@my_coordinates);
 Function: Transform mature transcript coordinates to genomic coordinates.
 Returns : An array or reference of genomic coordinates.
 Args    : An array reference of mature transcript coordinates.

=cut

sub me2genome {
  my ($self, @coordinates) = @_;
  my $coordinate_map = $self->coordinate_map;
  my @genomic_coordinates;
  for my $coordinate (@coordinates) {
    push @genomic_coordinates, $coordinate_map->{me2genome}{$coordinate};
  }
  return wantarray ? @genomic_coordinates : \@genomic_coordinates;
}

#-----------------------------------------------------------------------------

=head2 AED

 Title   : AED
 Usage   : $aed = $self->AED($transcript);
 Function: Calculate the annotation edit distance (AED) between two
	   transcripts. (PMID:19236712)
 Returns : An array or reference of genomic coordinates.
 Args    : A GAL::Schema::Result::Feature::transcript (or is_a) object

=cut

sub AED {

  my ($transcriptA, $transcriptB) = @_;

  my @exonsA = $transcriptA->exons;
  my $setA = Set::IntSpan::Fast->new;
  map {$setA->add_range($_->start, $_->end)} @exonsA;
  my $i = scalar $setA->as_array;

  my @exonsB = $transcriptB->exons;
  my $setB = Set::IntSpan::Fast->new;
  map {$setB->add_range($_->start, $_->end)} @exonsB;
  my $j = scalar $setB->as_array;

  my $int = scalar $setA->intersection($setB)->as_array;

  my $sn  = $int/$j;
  my $sp  = $int/$i;
  my $ac  = ($sn + $sp)/2;
  my $aed = 1 - $ac;

  return $aed;
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

<GAL::Schema::Result::Feature::transcript> does not throw any warnings
or error messages.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Feature::transcript> requires no configuration
files or environment variables.

=head1 DEPENDENCIES

<GAL::Schema::Result::Feature::sequence_feature>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

1;
