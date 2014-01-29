package GAL::Interval::Span;

use strict;
use vars qw($VERSION);
use Statistics::Descriptive;

$VERSION = 0.2.0;
use base qw(GAL::Interval);

=head1 NAME

GAL::Interval::Span - Provide functions for intervals on sequence

=head1 VERSION

This document describes GAL::Interval::Span version 0.2.0

=head1 SYNOPSIS

    use GAL::Interval::Span;

=head1 DESCRIPTION

    GAL::Interval::Span provides a collection of methods for intervals
    on sequence.  It uses Set::IntSpan::Fast under the hood to provide
    the functionality.

=head1 METHODS

=cut

#-----------------------------------------------------------------------------
#                                 Constructor
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Interval::Span->new()
     Function: Creates a GAL::Interval::Span object;
     Returns : A GAL::Interval::Span object
     Args    : list => \@list

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	return $self;
}

sub _initialize_args {
	my ($self, @args) = @_;

	######################################################################
	# This block of code handels class attributes.  Use the
	# @valid_attributes below to define the valid attributes for
	# this class.  You must have identically named get/set methods
	# for each attribute.  Leave the rest of this block alone!
	######################################################################
	my $args = $self->SUPER::_initialize_args(@args);
	# Set valid class attributes here
	my @valid_attributes = qw();
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------
#                                 Attributes
#-----------------------------------------------------------------------------

# =head2 attribute
#
#  Title   : attribute
#  Usage   : $a = $self->attribute()
#  Function: Get/Set the value of attribute.
#  Returns : The value of attribute.
#  Args    : A value to set attribute to.
#
# =cut
#
# sub attribute {
#   my ($self, $attribute) = @_;
#   $self->{attribute} = $attribute if $attribute;
#   return $self->{attribute};
# }

#-----------------------------------------------------------------------------
#                                   Methods
#-----------------------------------------------------------------------------

=head2 sets

 Title   : sets
 Usage   : $sets = $self->set('chr1');
 Function: Get the underlying Set::IntSpan::Fast object.

 Returns : A Set::IntSpan::Fast object(s) as array(ref) or scalar if
	   only one seqid is requrested.
 Args    : One or more valid seqids.

=cut

sub sets {
    my ($self, @seqids) = @_;

    @seqids = $self->seqids unless scalar @seqids;

    my @sets;
    for my $seqid (@seqids) {
      $self->{set}{$seqid} ||= Set::IntSpan::Fast->new();
      push @sets, $self->{set}{$seqid};
    }
    return wantarray ? @sets : scalar @seqids < 2 ? shift @sets : \@sets;
}

#-----------------------------------------------------------------------------

=head2 add_feature

 Title   : add_feature
 Usage   : $a = $self->add_feature($feature)
 Function: Add a feature to the set.
 Returns : N/A
 Args    :  A feature either as a hash reference (with keys seqid,
	    start and end) or an object (with methods seqid, start and
	    end).

=cut

sub add_feature {
    my ($self, $feature) = @_;

    my ($seqid, $start, $end);
    if (ref $feature eq 'HASH') {
      ($seqid, $start, $end) = @{$feature}{qw(seqid start end)};
    }
    elsif (ref $feature) {
      eval{
	($seqid, $start, $end) = ($feature->seqid, $feature->start,
				  $feature->end);
      };
      if ($@) {
	my $type = ref $feature;
	$self->throw('invald_feature',
		     ("Got $type, need hash or object.  ".
		      "See GAL::Set::Span->add_feature"));
      }
    }
    else {
      $self->throw('invald_feature', ("Got $feature, need hash or object.  ".
				      "See GAL::Set::Span->add_feature"));
    }
    $self->throw('invalid_feature', join ', ', ($seqid, $start, $end))
      unless ($seqid && $start && $end);
    $self->sets($seqid)->add_range($start, $end);
}

#-----------------------------------------------------------------------------

=head2 seqids

 Title   : seqids
 Usage   : @seqids = $self->seqids();
 Function: Return a list of all seqids represented in the sets.
 Returns : An array(ref) of seqids.
 Args    : N/A

=cut

sub seqids {
    my $self = shift;

    my @seqids = keys %{$self->{set}};
    return wantarray ? @seqids : \@seqids;
}

#-----------------------------------------------------------------------------

=head2 stats

 Title   : stats
 Usage   : $a = $self->stats
 Function: Calculate simple summary stats on spans
 Returns : N/A
 Args    : N/A

=cut

sub stats {
  my $self = shift;

  return $self->{stats} if $self->{stats};

  my $start_min  = 1e15;
  my $start_max  = 0;
  my $end_min    = 1e15;
  my $end_max    = 0;
  my $span_count = 0;
  my @lengths;

  my $stats = Statistics::Descriptive::Full->new();
  for my $set ($self->sets) {
    my $iter = $set->iterate_runs();
    while (my ( $start, $end ) = $iter->()) {
      my $length = $end - $start + 1;
      $stats->add_data($length);
      $start_min = $start_min > $start ? $start : $start_min;
      $start_max = $start_max < $start ? $start : $start_max;

      $end_min = $end_min > $end ? $end : $end_min;
      $end_max = $end_max < $end ? $end : $end_max;
    }
    $self->{stats} = $stats;
    return $self->{stats};
  }
}

#-----------------------------------------------------------------------------

=head2 span_count

 Title   : span_count
 Usage   : $a = $self->span_count()
 Function: Return the count of spans
 Returns : An integer - count of spans
 Args    : N/A

=cut

sub span_count {
    return shift->stats->count;
}

#-----------------------------------------------------------------------------

=head2 length_min

 Title   : length_min
 Usage   : $a = $self->length_min()
 Function:
 Returns :
 Args    : N/A

=cut

sub length_min {
    return shift->stats->min;
}

#-----------------------------------------------------------------------------

=head2 length_max

 Title   : length_max
 Usage   : $a = $self->length_max()
 Function:
 Returns :
 Args    : N/A

=cut

sub length_max {
    return shift->stats->max;
}

#-----------------------------------------------------------------------------

=head2 length_sum

 Title   : length_sum
 Usage   : $a = $self->length_sum()
 Function:
 Returns :
 Args    : N/A

=cut

sub length_sum {
    return shift->stats->sum;
}

#-----------------------------------------------------------------------------

=head2 footprint

 Title   : footprint
 Usage   : $a = $self->footprint()
 Function: An alias for length_sum
 Returns : Integer - length of all spans
 Args    : N/A

=cut

sub footprint {
    return shift->stats->sum;
}

#-----------------------------------------------------------------------------

=head2 length_stdev

 Title   : length_stdev
 Usage   : $a = $self->length_stdev()
 Function:
 Returns :
 Args    : N/A

=cut

sub length_stdev {
    return shift->stats->standard_deviation;
}

#-----------------------------------------------------------------------------

=head2 length_mean

 Title   : length_mean
 Usage   : $a = $self->length_mean()
 Function:
 Returns :
 Args    : N/A

=cut

sub length_mean {
    return shift->stats->mean;
}

#-----------------------------------------------------------------------------

=head2 length_median

 Title   : length_median
 Usage   : $a = $self->length_median()
 Function:
 Returns :
 Args    : N/A

=cut

sub length_median {
    return shift->stats->median;
}

#-----------------------------------------------------------------------------

=head2 method

 Title   : method
 Usage   : $a = $self->method()
 Function:
 Returns :
 Args    :

=cut

sub method {
    my $self = shift;
    $self->throw('method_not_implimented', 'method');
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=over

=item C<< Metohd histogram not implimented yet >>

There is a place holder for the histogram method, but the method has
not been written yet.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Interval::Span> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Interval>
<Statistics::Descriptive::Discreet>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself (See LICENSE).

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
