package GAL::List::Categorical;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::List);

=head1 NAME

GAL::List::Categorical - Provide functions for categorical lists

=head1 VERSION

This document describes GAL::List::Categorical version 0.01

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


=head1 DESCRIPTION

<GAL::List> serves as a base class for the modules below it and
provides basic list summarization details.  It is not intended to be
used on it's own.  You should use it's subclasses instead.

=head1 CONSTRUCTOR

To construct a GAL::List subclass simply pass it an appropriate list.

    my $list_catg = GAL::List::Categorical->new(list => [qw(red red red blue blue
							       green yellow orange orange
							       purple purple purple purple)]);

=cut

#-----------------------------------------------------------------------------
#-------------------------------- Constructor --------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::List::Categorical->new()
     Function: Creates a GAL::List::Categorical object;
     Returns : A GAL::List::Categorical object
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
#--------------------------------- Attributes --------------------------------
#-----------------------------------------------------------------------------
#
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
#
#-----------------------------------------------------------------------------
#------------------------------------ Methods --------------------------------
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
    $self->throw('developer_error', 'Method not implimented yet');
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

<GAL::List::Categorical> currently does not throw any warnings or
errors.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::List::Categorical> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<BAL::Base>

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
