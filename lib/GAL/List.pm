package GAL::List;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';
use base qw(GAL::Base);
use List::Util;

=head1 NAME

GAL::List - List aggregation and analysis functions for GAL

=head1 VERSION

This document describes GAL::List version 0.01

=head1 SYNOPSIS

    use GAL::List::Categorical;
    my $list_catg = GAL::List::Categorical->new(list => [qw(red red red blue blue
							       green yellow orange orange
							       purple purple purple purple)]);
    my $count    = $list_catg->count;
    $list_ref    = $list_catg->list;
    @list_ary    = $list_catg->list;
    $class       = $list_catg->class;
    $catg_counts = $list_catg->category_counts;
    $count_uniq  = $list_catg->count_uniq;
    $max_str     = $list_catg->maxstr;
    $min_str     = $list_catg->minstr;
    @shff_list   = $list_catg_shuffle;
    @uniq_list   = $list_catg_uniq;
    $item        = $list_catg->random_pick;

    use GAL::List::Numric;
    $list_numeric = GAL::List::Numeric->new(list => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    $max = $list_numeric->max;
    $min = $list_numeric->min;
    $sum = $list_numeric->sum;

=head1 DESCRIPTION

<GAL::List> serves as a base class for the modules below it and
provides basic list summarization details.  It is not intended to be
used on it's own.  You should use it's subclasses instead.

=head1 CONSTRUCTOR

To construct a GAL::List subclass simply pass it an appropriate list.

    my $list_catg = GAL::List::Categorical->new(list => [qw(red red red blue blue
							       green yellow orange orange
							       purple purple purple purple)]);
    $list_numeric = GAL::List::Numeric->new(list => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);


=cut

#-----------------------------------------------------------------------------
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::List->new()
     Function: Creates a GAL::List object;
     Returns : A GAL::List object
     Args    :

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
	my @valid_attributes = qw(list class);
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------

=head1  ATTRIBUTES

All attributes can be supplied as parameters to the constructor as a
list (or referenece) of key value pairs.

=head2 list

 Title   : list
 Usage   : $a = $self->list()
 Function: Get/Set the value of list.
 Returns : The value of list.
 Args    : A value to set list to.

=cut

sub list {
  my ($self, $list) = @_;
  if ($list) {

    my $err_msg = ('GAL::List requires an array reference as the ' .
		   'first argument, but you gave a  ' . ref $list
		  );
    my $err_code = 'list_or_reference_required : ' . ref $list;
    $self->warn(message => (message => $err_msg,
			    code    => $err_code,
			   )
	       ) unless ref $list eq 'ARRAY';
    $self->{list} = $list;
  }
  $self->{list} ||= [];
  return wantarray ? @{$self->{list}} : $self->{list};
}

#-----------------------------------------------------------------------------
#
# =head2 class
#
#  Title   : class
#  Usage   : $a = $self->class()
#  Function: Get/Set the value of class.
#  Returns : The value of class.
#  Args    : A value to set class to.
#
# =cut
#
# sub class {
#   my ($self, $class) = @_;
#   $class =~ s/GAL::List:://;
#   $class = 'GAL::List::' . $self->{class};
#   $self->{class} = $class if $class;
#   return $self->{class};
# }
#
#-----------------------------------------------------------------------------
#---------------------------------- Methods ----------------------------------
#-----------------------------------------------------------------------------

=head1 METHODS

=head2 count

 Title   : count
 Usage   : $a = $self->count()
 Function: Get/Set the value of count.
 Returns : The value of count.
 Args    : A value to set count to.

=cut

sub count {
    my $self = shift;
    return scalar @{$self->{list}};
}

#-----------------------------------------------------------------------------

=head2 count_uniq

 Title   : count_uniq
 Usage   : $a = $self->count_uniq()
 Function:
 Returns :
 Args    :

=cut

sub count_uniq {
    my $self = shift;
    return scalar @{$self->uniq};
}

#-----------------------------------------------------------------------------

=head2 category_counts

 Title   : category_counts
 Usage   : $a = $self->category_counts()
 Function: Get/Set the value of category_counts.
 Returns : The value of category_counts.
 Args    : A value to set category_counts to.

=cut

sub category_counts {
    my $self = shift;
    my %hash;
    map {$hash{$_}++} @{$self->{list}};
    return wantarray ? %hash : \%hash;
}

#-----------------------------------------------------------------------------

=head2 max

 Title   : max
 Usage   : $a = $self->max()
 Function:
 Returns :
 Args    :

=cut

sub max {
    my $self = shift;
    return List::Util::max @{$self->{list}};
}

#-----------------------------------------------------------------------------

=head2 maxstr

 Title   : maxstr
 Usage   : $a = $self->maxstr()
 Function:
 Returns :
 Args    :

=cut

sub maxstr {
    my $self = shift;
    return List::Util::maxstr @{$self->{list}};
}

#-----------------------------------------------------------------------------

=head2 min

 Title   : min
 Usage   : $a = $self->min()
 Function:
 Returns :
 Args    :

=cut

sub min {
    my $self = shift;
    return List::Util::min @{$self->{list}};
}

#-----------------------------------------------------------------------------

=head2 minstr

 Title   : minstr
 Usage   : $a = $self->minstr()
 Function:
 Returns :
 Args    :

=cut

sub minstr {
    my $self = shift;
    return List::Util::minstr @{$self->{list}};
}

#-----------------------------------------------------------------------------

=head2 shuffle

 Title   : shuffle
 Usage   : $a = $self->shuffle()
 Function:
 Returns :
 Args    :

=cut

sub shuffle {
    my $self = shift;
    return List::Util::shuffle @{$self->{list}};
}

#-----------------------------------------------------------------------------

=head2 sum

 Title   : sum
 Usage   : $a = $self->sum()
 Function:
 Returns :
 Args    :

=cut

sub sum {
    my $self = shift;
    return List::Util::sum @{$self->{list}};
}

#-----------------------------------------------------------------------------

=head2 uniq

 Title   : uniq
 Usage   : $a = $self->uniq()
 Function:
 Returns :
 Args    :

=cut

sub uniq {
    my $self = shift;
    my %seen;
    my @uniq = grep {! $seen{$_}++} $self->list;
    return wantarray ? @uniq : \@uniq;
}

#-----------------------------------------------------------------------------

=head2 random_pick

 Title   : random_pick
 Usage   : $a = $self->random_pick()
 Function:
 Returns :
 Args    :

=cut

sub random_pick {
    my $self = shift;

    my $random = int(rand($self->count));
    return $self->{list}[$random];
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=over

=item C<< list_or_reference_required >>

GAL::List::list require an array or a reference to any array be passed
as an argument, but you have passed something else.

Keep in mind that several of GAL::List's methods are provided by
List::Util, and errors not found here may be thrown by that module.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::List> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<GAL::Base>
<List::Util>

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
