package GAL::Interval::NCL;

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
########                                                                ########
########		Maybe this should be List::NCL                  ########
########								########
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

use strict;
use vars qw($VERSION);


$VERSION = 0.2.0;
use base qw(GAL::Interval);

=head1 NAME

GAL::Interval::NCL - Provide functions for intervals on sequence

=head1 VERSION

This document describes GAL::Interval::NCL version 0.2.0

=head1 SYNOPSIS

    use GAL::Interval::NCL;

=head1 DESCRIPTION

    GAL::Interval::NCL provides a collection of methods for intervals
    on sequence via nested containment lists.

=head1 METHODS

=cut

#-----------------------------------------------------------------------------
#                                 Constructor
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Interval::NCL->new()
     Function: Creates a GAL::Interval::NCL object;
     Returns : A GAL::Interval::NCL object
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

=head2 stats

 Title   : stats
 Usage   : $stats = $self->stats()
 Function: Provides access to the Statistics::Descriptive::Discreet object
 Returns : A Statistics::Descriptive::Discreet object
 Args    : None

=cut

sub stats {
    my $self = shift;
    unless ($self->{stats}) {
	my $stats = Statistics::Descriptive::Discreet::Full->new();
	$stats->add_data(@{$self->{list}});
	$self->{stats} = $stats;
    }
    return $self->{stats};
}

#-----------------------------------------------------------------------------

=head2 count

 Title   : count
 Usage   : $a = $self->count()
 Function: Returns the count of the list of elements
 Returns :
 Args    :

=cut

sub count {
  return shift->stats->count();
}

#-----------------------------------------------------------------------------

=head2 mean

 Title   : mean
 Usage   : $a = $self->mean()
 Function: Returns the mean of the list of elements
 Returns :
 Args    :

=cut

sub mean {
  return shift->stats->mean;
}

#-----------------------------------------------------------------------------

=head2 sum

 Title   : sum
 Usage   : $a = $self->sum()
 Function: Returns the sum of the list of elements
 Returns :
 Args    :

=cut

sub sum {
  return shift->stats->sum;
}

#-----------------------------------------------------------------------------

=head2 variance

 Title   : variance
 Usage   : $a = $self->variance()
 Function: Returns the variance of the list of elements
 Returns :
 Args    :

=cut

sub variance {
  return shift->stats->variance();
}

#-----------------------------------------------------------------------------

=head2 standard_deviation

 Title   : standard_deviation
 Usage   : $a = $self->standard_deviation()
 Function: Returns the standard_deviation of the list of elements
 Returns :
 Args    :

=cut

sub standard_deviation {
  return shift->stats->standard_deviation();
}

#-----------------------------------------------------------------------------

=head2 min

 Title   : min
 Usage   : $a = $self->min()
 Function: Returns the min of the list of elements
 Returns :
 Args    :

=cut

sub min {
  return shift->stats->min();
}

#-----------------------------------------------------------------------------

=head2 mindex

 Title   : mindex
 Usage   : $a = $self->mindex()
 Function: Returns the mindex of the list of elements
 Returns :
 Args    :

=cut

sub mindex {
  return shift->stats->mindex();
}

#-----------------------------------------------------------------------------

=head2 max

 Title   : max
 Usage   : $a = $self->max()
 Function: Returns the max of the list of elements
 Returns :
 Args    :

=cut

sub max {
  return shift->stats->max();
}

#-----------------------------------------------------------------------------

=head2 maxdex

 Title   : maxdex
 Usage   : $a = $self->maxdex()
 Function: Returns the maxdex of the list of elements
 Returns :
 Args    :

=cut

sub maxdex {
  return shift->stats->maxdex();
}

#-----------------------------------------------------------------------------

=head2 sample_range

 Title   : sample_range
 Usage   : $a = $self->sample_range()
 Function: Returns the sample_range of the list of elements
 Returns :
 Args    :

=cut

sub sample_range {
  return shift->stats->sample_range();
}

#-----------------------------------------------------------------------------

=head2 median

 Title   : median
 Usage   : $a = $self->median()
 Function: Returns the median of the list of elements
 Returns :
 Args    :

=cut

sub median {
  return shift->stats->median();
}

#-----------------------------------------------------------------------------

=head2 percentile

 Title   : percentile
 Usage   : $a = $self->percentile()
 Function: Returns the percentile of the list of elements
 Returns :
 Args    :

=cut

sub percentile {
  return shift->stats->percentile(shift);
}

#-----------------------------------------------------------------------------

=head2 harmonic_mean

 Title   : harmonic_mean
 Usage   : $a = $self->harmonic_mean()
 Function: Returns the harmonic_mean of the list of elements
 Returns :
 Args    :

=cut

sub harmonic_mean {
  return shift->stats->harmonic_mean();
}

#-----------------------------------------------------------------------------

=head2 geometric_mean

 Title   : geometric_mean
 Usage   : $a = $self->geometric_mean()
 Function: Returns the geometric_mean of the list of elements
 Returns :
 Args    :

=cut

sub geometric_mean {
  return shift->stats->geometric_mean();
}

#-----------------------------------------------------------------------------

=head2 mode

 Title   : mode
 Usage   : $a = $self->mode()
 Function: Returns the mode of the list of elements
 Returns :
 Args    :

=cut

sub mode {
  return shift->stats->mode();
}

#-----------------------------------------------------------------------------

=head2 trimmed_mean

 Title   : trimmed_mean
 Usage   : $a = $self->trimmed_mean()
 Function: Returns the trimmed_mean of the list of elements
 Returns :
 Args    :

=cut

sub trimmed_mean {
  return shift->stats->trimmed_mean(@_);
}

#-----------------------------------------------------------------------------

=head2 frequency_distribution

 Title   : frequency_distribution
 Usage   : $a = $self->frequency_distribution()
 Function: Returns the frequency_distribution of the list of elements
 Returns :
 Args    :

=cut

sub frequency_distribution {
  return shift->stats->frequency_distribution(shift);
}

#-----------------------------------------------------------------------------

=head2 least_squares_fit

 Title   : least_squares_fit
 Usage   : $a = $self->least_squares_fit()
 Function: Returns the least_squares_fit of the list of elements
 Returns :
 Args    :

=cut

sub least_squares_fit {
  return shift->stats->least_squares_fit(@_);
}

#-----------------------------------------------------------------------------

=head2 histogram

 Title   : histogram
 Usage   : $a = $self->histogram()
 Function:
 Returns :
 Args    :

=cut

sub histogram {
    my $self = shift;
    $self->throw('developer_error', 'Metohd histogram not implimented yet');
}

#-----------------------------------------------------------------------------

=head2 bins

 Title   : bins
 Usage   : @bins = $self->bins($bin_count)
	   @bins = $self->bins($min, $max, $step)
	   @bins = $self->bins(\@bins)
 Function: Get/Set bin values
 Returns : A list or reference of the bin values.
 Args    : A reference to a list of bin values.

=cut

sub bins {
	my ($self, $min, $max, $step) = @_;
	if (ref $min eq 'ARRAY') {
	    my $bins = $min;
	    $self->{bins} = $bins;
	}
	else {
	    if ($min && ! defined $max && ! defined $step)  {
		my $bin_count = $min;
		$min  = $self->min unless defined $min;
		$max  = $self->max unless defined $max;
		$step = ($max - $min) / $bin_count;
	    }
	    $min  = $self->min unless defined $min;
	    $max  = $self->max unless defined $max;
	    $step = ($max - $min) / 10 unless defined $step;
	    $step = sprintf "%.1g", $step;
	    my @bins;
	    foreach (my $i = $min + $step; $i <= $max + $step; $i += $step) {
		push @bins, $i;
	    }
	    $self->{bins} = \@bins;
	}
	$self->bin_range unless $self->{bins};
	return wantarray ? @{$self->{bins}} : $self->{bins};
}

#-----------------------------------------------------------------------------

=head2 bin_range

 Title   : bin_range
 Usage   : @bins = $self->bin_range($min, $max, $step)
 Function: Get
 Returns :
 Args    :

=cut

sub bin_range {
	my ($self, $min, $max, $step) = @_;

	$min  = $self->min unless defined $min;
	$max  = $self->max unless defined $max;
	$step = ($max - $min) / 10 unless defined $step;
	$step = sprintf "%.1g", $step;
	my @bins;
	foreach (my $i = $min + $step; $i <= $max + $step; $i += $step) {
		push @bins, $i;
	}
	$self->{bins} = \@bins;
	return wantarray ? @bins : \@bins;
}

#-----------------------------------------------------------------------------

=head2 fd

 Title   : fd
 Usage   : $a = $self->fd()
 Function:
 Returns :
 Args    :

=cut

sub fd {
    my ($self, $bin_value) = @_;
    my @bins;
    my $min = $self->min;
    my $max = $self->max;

    if (! $self->{frequencey_distribution} || $bin_value) {
	if (ref $bin_value eq 'ARRAY') {
	    @bins = @{$bin_value};
	}
	elsif (ref $bin_value eq 'HASH') {
	    $self->bin_range(@{$bin_value}->{qw(min max step)});
	}
	elsif ($bin_value && $bin_value == int($bin_value)) {
	    my $step = ($max - $min) / $bin_value;
	    $self->bin_range(undef, undef, $step);
	}
	my @bins = $self->bins;
	my %fd;
	  DATUM:
	    for my $datum ($self->list) {
		my $min_bin = 0;
		my $max_bin = scalar @bins - 1;
		my $bindex =  int($max_bin / 2);
		while (1) {
		    next DATUM if ($bindex < $min_bin ||
				   $bindex > $max_bin);
		    my $upper = $bins[$bindex];
		    my $lower = $bindex - 1 >= 0 ? $bins[$bindex - 1] : $min - 1;
		    if ($self->float_le($datum, $upper)) {
			$max_bin = $bindex;
			if ($self->float_gt($datum, $lower)) {
			    $fd{$bins[$bindex]}++;
			    next DATUM;
			}
			else {
			    $bindex -= (int(($bindex - $min_bin) / 2) || 1);
			}
		    }
		    else {
			$min_bin = $bindex;
			$bindex += (int(($max_bin - $bindex) / 2) || 1);
		    }
		}
	    }
	map {$fd{$_} ||= 0} @bins;
	$self->{fd} = \%fd;
    }
    return wantarray ? %{$self->{fd}} : $self->{fd};
}

#-----------------------------------------------------------------------------

=head2 cfd

 Title   : cfd
 Usage   : $a = $self->cfd()
 Function:
 Returns :
 Args    :

=cut

sub cfd {
    my $self = shift;
    my %cfd = $self->fd;
    my $running_total;
    for my $key (sort {$a <=> $b} keys %cfd) {
	my $datum = $cfd{$key};
	$running_total += $datum;
	$cfd{$key} = $running_total;
    }
    return wantarray ? %cfd : \%cfd;
}

#-----------------------------------------------------------------------------

=head2 relative_fd

 Title   : relative_fd
 Usage   : $a = $self->relative_fd()
 Function:
 Returns :
 Args    :

=cut

sub relative_fd {
    my $self = shift;
    my %relative_fd = $self->fd;
    my $count = $self->count;
    map {$relative_fd{$_} /= $count} keys %relative_fd;
    return wantarray ? %relative_fd : \%relative_fd;
}

#-----------------------------------------------------------------------------

=head2 relative_cfd

 Title   : relative_cfd
 Usage   : $a = $self->relative_cfd()
 Function:
 Returns :
 Args    :

=cut

sub relative_cfd {
    my $self = shift;
    my %relative_cfd = $self->cfd;
    my $count = $self->count;
    map {$relative_cfd{$_} /= $count} keys %relative_cfd;
    return wantarray ? %relative_cfd : \%relative_cfd;
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
    $self->throw('developer_error', 'Metohd not implimented yet');
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=over

=item C<< Metohd histogram not implimented yet >>

There is a place holder for the histogram method, but the method has
not been written yet.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Interval::NCL> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Interval>

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
