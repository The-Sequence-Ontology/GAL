package GAL::Base;

use strict;
use vars qw($VERSION);
use Carp qw(croak cluck);

$VERSION = '0.01';

=head1 NAME

GAL::Base - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Base version 0.01

=head1 SYNOPSIS

     use GAL::Base;

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

=head2

     Title   : new
     Usage   : GAL::Base->new();
     Function: Creates a GAL::Base object;
     Returns : A GAL::Base object
     Args    :

=cut

sub new {
	my ($class, @args) = @_;
	my $self = bless {}, ref($class) || $class;
	$self->_initialize_args(@args);
	return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {

}

#-----------------------------------------------------------------------------

=head2 throw

 Title   : throw
 Usage   : $a = $self->throw(message => $error_message);
 Function: Throw an error - print an error message and die.
 Returns : N/A
 Args    : message => $error_message

=cut

sub throw {
	my ($self, @args) = @_;

	my $args = $self->prepare_args(@args);

	my $caller = ref($self);

	$args->{message} ||= join '',
	  ("GAL::Base is throwing an exception for $caller ",
	   "But someone called throw without an appropriate ",
	   "error message in $caller ");

	chomp $args->{message};
	$args->{message} = $self->wrap_text($args->{message}, 50);
	$args->{message} .= "\n";

	my $message = "\n\n";
	$message .= '#' x 60;
	$message .= "\n";
	$message .= $args->{message};
	$message .= '#' x 60;
	$message .= "\n\n\n";

	croak $message;
}

#-----------------------------------------------------------------------------

=head2 warn

 Title   : warn
 Usage   : $a = $self->warn(message => $warning_message);
 Function: Send a warning.
 Returns : N/A
 Args    : message => $warning_message

=cut

sub warn {
	my ($self, @args) = @_;

	my $args = $self->prepare_args(@args);

	my $caller = ref($self);

	$args->{message} ||= join '',
	  ("GAL::Base is sending a warning for $caller ",
	   "But someone called warn without an appropriate ",
	   "message in $caller ");

	chomp $args->{message};
	$args->{message} = $self->wrap_text($args->{message}, 50);
	$args->{message} .= "\n";

	my $message = "\n\n";
	$message .= '#' x 60;
	$message .= "\n";
	$message .= $args->{message};
	$message .= '#' x 60;
	$message .= "\n\n\n";

	cluck $message;
}

#-----------------------------------------------------------------------------

=head2 wrap

 Title   : wrap
 Usage   : $text = $self->wrap($text, 50);
 Function: Wrap text to the specified column width.
 Returns : Wrapped text
 Args    : A string of text and an integer value.

=cut

sub wrap_text {
	my ($self, $text, $cols) = @_;
	$cols ||= 50;
	$text .= " ";
	$text =~ s/(.{0,$cols})\s+/$1\n/g;
	chomp $text;
	return $text;
}
#-----------------------------------------------------------------------------

=head2 trim_whitespace

 Title   : trim_whitespace
 Usage   : $trimmed_text = $self->trim_whitespace($text);
 Function: Trim leading and trailing whitespace from text;
 Returns : Whitespace trimmed text.
 Args    : Text.

=cut

sub trim_whitespace {
	my ($self, $text) = @_;

	$text =~ s/^\s+//;
	$text =~ s/\s+$//;

	return $text;
}

#-----------------------------------------------------------------------------

=head2 first_word

 Title   : first_word
 Usage   : $word = $self->first_word($text);
 Function: Grab the first word from a string of text
 Returns : A single word as text.
 Args    : Text.

=cut

sub first_word {
	my ($self, $text) = @_;

	my $word;
	($word) = $text =~ /^\s*(\S+)\s*/;

	return $word;
}

#-----------------------------------------------------------------------------

=head2 prepare_args

 Title   : prepare_args
 Usage   : $args = $self->prepare_args(@args);
 Function: Take a list of key value pairs that may be an array, hash or ref
	   to either and return them as a hash or hash reference depending on
	   calling context.
 Returns : Hash or hash reference.
 Args    : An array, hash or reference to either of those containing key,
	   value pairs.

=cut

sub prepare_args {

	my ($self, @args) = @_;

	my %args_hash;

	if (scalar @args == 1 && ref $args[0] eq 'ARRAY') {
		%args_hash = @{$args[0]};
	}
	elsif (scalar @args == 1 && ref $args[0] eq 'HASH') {
		%args_hash = %{$args[0]};

	}
	elsif (scalar @args % 2 == 0) {
		%args_hash = @args;
	}
	else {
		my $class = ref($self);
		my $error = join "\n",
		  ("Bad arguments passed to ${class}->new",
		   "We always expect a list of key value pairs or a",
		   "reference to such a list, But we got:\n",
		   @args);
		$self->throw(message => $error);
	}
	return wantarray ? %args_hash : \%args_hash;
}

#-----------------------------------------------------------------------------

=head2 set_attributes

 Title   : set_attributes
 Usage   : $args = $self->set_attributes($args, @valid_attributes);
 Function: Take a hash reference of arguments and a list of valid attribute
           names and call the methods to set those attribute values.
 Returns : N/A
 Args    : A hash reference of arguments and an array or array reference of
           valid attributes names.

=cut

sub set_attributes {

	my $self = shift;
	my $args = shift;

	# Allow @valid_attributes to be passed as array or arrayref.
	my @valid_attributes = ref($_[0]) eq 'ARRAY' ? @{$_[0]} : @_;

	my $package = __PACKAGE__;
	my $caller = ref($self);

	for my $attribute (@valid_attributes) {
		next unless exists $args->{$attribute};
		if (exists $self->{$attribute}) {
			my $package = __PACKAGE__;
			my $caller = ref($self);
			my $warning_message = 
			  ("$package is about to reset the value of $attribute " .
			   "on behalf of a $caller object.  This is probably "   .
			   "a bad idea.");
			$self->warn(message => $warning_message);
		}
		$self->$attribute($args->{$attribute});
		delete $args->{$attribute};
	}

#	my @leftover_args = keys %{$args};
#	for my $arg (@leftover_args) {
#		my $message = "Invalid argument $arg passed to $caller.";
#		$self->throw(message => $message);
#	}
}

#-----------------------------------------------------------------------------

=head2 expand_nucleotide_ambiguity

 Title   : expand_nucleotide_ambiguity
 Usage   : @nucleotides = $self->expand_nucleotide_ambiguity('W');
 Function: Expands and IUPAC ambiguity codes to an array of nucleotides
 Returns : An array or array ref of nucleotides
 Args    : An IUPAC Nucleotide ambiguity code

=cut

sub expand_iupac_nt_codes {
	my ($self, $code) = @_;

	my %iupac_code_map = (A => ['A'],
			      C => ['C'],
			      G => ['G'],
			      T => ['T'],
			      U => ['T'],
			      M => ['A', 'C'],
			      R => ['A', 'G'],
			      W => ['A', 'T'],
			      S => ['C', 'G'],
			      Y => ['C', 'T'],
			      K => ['G', 'T'],
			      V => ['A', 'C', 'G'],
			      H => ['A', 'C', 'T'],
			      D => ['A', 'G', 'T'],
			      B => ['C', 'G', 'T'],
			      N => ['G', 'A', 'T', 'C'],
			     );

	my $nts = $iupac_code_map{$code};

	return wantarray ? @{$nts} : $nts;
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

<GAL::Base> requires no configuration files or environment variables.

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
