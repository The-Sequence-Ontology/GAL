package GAL::List;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';
use base qw(GAL::Base);
use List::Util;

=head1 NAME

GAL::List - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::List version 0.01

=head1 SYNOPSIS

     use GAL::List;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 METHODS

=cut

#-----------------------------------------------------------------------------
#                                 Constructor                                 
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::List->new()
     Function: Creates a List object;
     Returns : A List object
     Args    :

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
#	my $class = $self->class;
#	$self->load_module($class);
#	bless $self, $class;
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
#                                 Attributes                                 
#-----------------------------------------------------------------------------

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
      $self->warn(message => ('GAL::List requires an array reference as the ' . 
			      'first argument, but you gave a  ' . ref $list
			      )
		  ) unless ref $list eq 'ARRAY';
      $self->{list} = $list;
  }
  $self->{list} ||= [];
  return wantarray ? @{$self->{list}} : $self->{list};
}

#-----------------------------------------------------------------------------

=head2 class

 Title   : class
 Usage   : $a = $self->class()
 Function: Get/Set the value of class.
 Returns : The value of class.
 Args    : A value to set class to.

=cut

sub class {
  my ($self, $class) = @_;
  $class =~ s/GAL::List:://;
  $class = 'GAL::List::' . $self->{class};
  $self->{class} = $class if $class;
  return $self->{class};
}

#-----------------------------------------------------------------------------
#                                   Methods                                 
#-----------------------------------------------------------------------------

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

=for author to fill in:
     List every single error and warning message that the module can
     generate (even the ones that will "never happen"), with a full
     explanation of each problem, one or more likely causes, and any
     suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::List> requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

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
