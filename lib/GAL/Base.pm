package GAL::Base;

use strict;
use vars qw($VERSION);
use Carp qw(croak cluck);
use Bio::DB::Fasta;
use Scalar::Util qw(blessed);

$VERSION = '0.01';

=head1 NAME

GAL::Base - Base class for the Genome Annotation Library

=head1 VERSION

This document describes GAL::Base version 0.01

=head1 SYNOPSIS

    use base qw(GAL::Base);

=head1 DESCRIPTION

GAL::Base serves as a base class for all of the other classes in the
GAL.  It is not intended to be instantiated directly, but rather to be
used with the 'use base' pragma.  GAL::Base provides object
instantiation, argument preparation and attribute setting functions
for other classes during object construction.  In addition it provides
a wide range of utility functions that are expected to be widly
applicable throughout the library.

=head1 CONSTRUCTOR

GAL::Base is not intended to by instantiated on it's own.  It does
however, handle object creation for the rest of the library.  Each
class in GAL calls:

    my $self = $class->SUPER::new(@args);

This means that GAL::Base - at the bottom of the inheritance chain
does the actual object creation.  It creates the new object based on
the calling class, and then checks to see if there is a 'class'
argument provided.  If there is it calls the class attribute, which
GAL::Base provides, and reblesses the object using the value to the
class argument as a subclass of the current calling class.  This
allows this kind of an idiom for any class that has subclasses:

    my $parser = GAL::Parser->(class => 'gff3');

That invocation would return a GAL::Parser::gff3 object instead of a
GAL::Parser object.

L<GAL::Base> provides the following attributes to all other classes in
the GAL.

=over 4

=item * C<< fasta => '/path/to/fasta/files/' >>

This optional parameter defines a path to fasta files that are (or
will be) indexed and available to all objects in the library.

=item * C<< class => 'subclass' >>

This optional parameter will cause the current object to be reblessed
as the given subclass of the calling object.

=cut

#-----------------------------------------------------------------------------
#--------------------------------- Constructor -------------------------------
#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::SomeClass->new();
     Function: Creates on object of the calling class
     Returns : An object of the calling class
     Args    : See the attributes described above

=cut

sub new {
	my ($class, @args) = @_;
	$class = ref($class) || $class;
	my $self = bless {}, $class;

	my $args = $self->prepare_args(@args);

	# Call attribute class first so that objects get reblessed
	# into the appropriate subclass before they set their
	# attributes.
	if ($args->{class}) {
	  $self = $self->class($args->{class});
	  delete $args->{class};
	}

	$self->_initialize_args($args);
	return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {
	my ($self, $args) = @_;

	######################################################################
	# This block of code handels class attributes.  Use the
	# @valid_attributes below to define the valid attributes for
	# this class.  You must have identically named get/set methods
	# for each attribute.  Leave the rest of this block alone!
	######################################################################
	my @valid_attributes = qw(fasta class); # Set valid class attributes here
	$self->set_attributes($args, @valid_attributes);
	######################################################################
	return $args;
}

#-----------------------------------------------------------------------------
#-------------------------------- Attributes ---------------------------------
#-----------------------------------------------------------------------------

=head1  ATTRIBUTES

All attributes can be supplied as parameters to the constructor as a
list (or referenece) of key value pairs.

=cut

=head2 fasta

  Title   : fasta
  Usage   : $fasta = $self->fasta($fasta_dir);
  Function: Provides a Bio::DB::Fasta object
  Returns : A Bio::DB::Fasta object
  Args    : A directory of fasta files.

=cut

 sub fasta {
   my ($self, $fasta_path) = @_;

   if ($fasta_path) {
     # $fasta_path ||= $self->config('default_fasta_path');
     my $fasta_index = Bio::DB::Fasta->new($fasta_path);
     $self->{fasta} = $fasta_index;
   }
   return $self->{fasta};
 }

#-----------------------------------------------------------------------------

=head2 class

  Title   : class
  Usage   : $class = $self->class($subclass);
  Function: Reblesses an object into the appropriate subclass.
  Returns : A object blessed into $subclass
  Args    : A class name of a subclass of the calling object.

=cut

 sub class {
   my ($self, $subclass) = @_;

   my $class = ref($self);
   $subclass =~ s/$class//;
   $subclass = $class . "::$subclass";
   $self->load_module($subclass);
   bless $self, $subclass;
   return $self;
 }

#-----------------------------------------------------------------------------
#------------------------------------ Methods --------------------------------
#-----------------------------------------------------------------------------

=head1 METHODS

=head2 handle_message

 Title   : handle_message
 Usage   : $base->handle_message($level, $code, $message);
 Function: Handle a message.
 Returns : None
 Args    : level (INFO, WARM, FATAL)
           code (a_single_string_description)
           message (Free text explination)

=cut

sub handle_message {
	my ($self, $level, $code, $message) = @_;

	my $caller = ref($self);

	$level   ||= 'FATAL';
	$code    ||= 'unspecified_code';
	$message ||= $caller;

	print STDERR join ' : ', ($level, $code, $message);
	print STDERR "\n";

	die $caller if $level eq 'FATAL';
}

#-----------------------------------------------------------------------------

=head2 throw

 Title   : throw
 Usage   : $base->throw(message => $err_msg, code => $err_code);
 Function: Throw an error - print an error message and die.
 Returns : None
 Args    : message => $err_msg  # Free text description of error
	   code    => $err_code # single_word_code_for_error

=cut

sub throw {
	shift->handle_message('FATAL', @_);
}

#-----------------------------------------------------------------------------

=head2 warn

 Title   : warn
 Usage   : $base->warn($code, $warning_message);
 Function: Send a warning.
 Returns : None
 Args    : message => $warning_message

=cut

sub warn {
	shift->handle_message('WARN', @_);
}

#-----------------------------------------------------------------------------

=head2 info

 Title   : info
 Usage   : $base->info(message => $info_message);
 Function: Send a INFO message.
 Returns : None
 Args    : message => $info_message

=cut

sub info {
	shift->handle_message('INFO', @_);
      }

#-----------------------------------------------------------------------------

=head2 wrap_text

 Title   : wrap_text
 Usage   : $text = $self->wrap_text($text, 50);
 Function: Wrap text to the specified column width.
 Returns : Wrapped text
 Args    : A string of text and an optional integer value.

=cut

sub wrap_text {
	my ($self, $text, $cols) = @_;
	$cols ||= 50;
	$text =~ s/(.{0,$cols})/$1\n/g;
	$text =~ s/\n+$//;
	return $text;
}
#-----------------------------------------------------------------------------

=head2 trim_whitespace

 Title   : trim_whitespace
 Usage   : $trimmed_text = $self->trim_whitespace($text);
 Function: Trim leading and trailing whitespace from text;
 Returns : Trimmed text.
 Args    : Text

=cut

sub trim_whitespace {
	my ($self, $text) = @_;
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;
	return $text;
}

#-----------------------------------------------------------------------------

=head2 prepare_args

 Title   : prepare_args
 Usage   : $args = $self->prepare_args(@_);
 Function: Take a list of key value pairs that may be an array, hash or ref
	   to either and return them as a hash or hash reference depending on
	   calling context.
 Returns : Hash or hash reference
 Args    : An array, hash or reference to either

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
		my $err_code = 'invalid_arguments_to_prepare_args';
		my $err_msg  = ("Bad arguments passed to $class. A list "   .
				"of key value pairs or a reference to "     .
				"such a list was expected, But we got:\n"   .
				join ' ', @args);
		$self->throw($err_code, $err_msg);
	}

	return wantarray ? %args_hash : \%args_hash;
}

#-----------------------------------------------------------------------------

=head2 set_attributes

 Title   : set_attributes
 Usage   : $base->set_attributes($args, @valid_attributes);
 Function: Take a hash reference of arguments and a list of valid attribute
	   names and call the methods to set those attribute values.
 Returns : None
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

	$args ||= {};

	for my $attribute (@valid_attributes) {
		next unless exists $args->{$attribute};
		if (exists $self->{$attribute}) {
			my $package = __PACKAGE__;
			my $caller = ref($self);
			my $warning_message =
			  ("$package is about to reset the value of $attribute " .
			   "on behalf of a $caller object.  This is probably "   .
			   "a bad idea.");
			$self->warn('resetting_attribute_values', $warning_message);
		}
		$self->$attribute($args->{$attribute});
		delete $args->{$attribute};
	}
}

#-----------------------------------------------------------------------------

=head2 expand_iupac_nt_codes

 Title   : expand_iupac_nt_codes
 Usage   : @nucleotides = $self->expand_iupac_nt_codes('W');
 Function: Expands an IUPAC ambiguity codes to an array of nucleotides
 Returns : An array or array ref of nucleotides
 Args    : An IUPAC Nucleotide ambiguity code or an array of such

=cut

sub expand_iupac_nt_codes {
	my ($self, @codes) = @_;

	my %iupac_code_map = ('A' => ['A'],
			      'C' => ['C'],
			      'G' => ['G'],
			      'T' => ['T'],
			      'U' => ['T'],
			      'M' => ['A', 'C'],
			      'R' => ['A', 'G'],
			      'W' => ['A', 'T'],
			      'S' => ['C', 'G'],
			      'Y' => ['C', 'T'],
			      'K' => ['G', 'T'],
			      'V' => ['A', 'C', 'G'],
			      'H' => ['A', 'C', 'T'],
			      'D' => ['A', 'G', 'T'],
			      'B' => ['C', 'G', 'T'],
			      'N' => ['A', 'C', 'G', 'T'],
			      'X' => ['A', 'C', 'G', 'T'],
			      '-' => ['-'],
			     );

	my @nts;
	for my $code (@codes) {
	  my $nts = $iupac_code_map{$code};
	  $self->throw('invalid_ipuac_nucleotide_code', $code)
	    unless $nts;
	  push @nts, @{$nts};
	}


	return wantarray ? @nts : \@nts;
}

#-----------------------------------------------------------------------------

=head2 load_module

 Title   : load_module
 Usage   : $base->load_module(Some::Module);
 Function: Do runtime loading (require) of a module/class.
 Returns : 1 on success - throws exception on failure
 Args    : A valid module name

=cut

sub load_module {

	my ($self, $module_name) = @_;
	eval "require $module_name";
	if ($@) {
	  my $self_class = ref $self;
	  my $err_code = "failed_to_load_module : $module_name";
	  my $err_msg  = "Failed to load $module_name in $self_class:\n$@";
	  $self->throw($err_code, $err_msg);
	}
	return 1;
}

#-----------------------------------------------------------------------------

=head2 revcomp

 Title   : revcomp
 Usage   : $base->revcomp($sequence);
 Function: Get the reverse compliment of a nucleotide sequence
 Returns : The reverse complimented sequence
 Args    : A nucleotide sequence

=cut

sub revcomp {

  my ($self, $sequence) = @_;

  my $revcomp_seq = reverse $sequence;
  $revcomp_seq =~ tr/acgtrymkswhbvdnxACGTRYMKSWHBVDNX/tgcayrkmswdvbhnxTGCAYRKMSWDVBHNX/;
  return $revcomp_seq;
}

#-----------------------------------------------------------------------------

=head2 get_feature_bins

 Title   : get_feature_bins
 Usage   : $base->get_feature_bins($feature);
 Function: Get the genome bins for a range
 Returns : An array of bins that the given
	   range falls in.
 Args    : A hash reference with key values seqid, start, end (i.e. a
	   feature hash) or an object with methods seqid, start, end.

=cut

sub get_feature_bins {

    my ($self, $feature) = @_;

    my ($seqid, $start, $end);
    if (ref $feature eq 'HASH') {
      ($seqid, $start, $end) = @{$feature}{qw(seqid start end)};
    }
    elsif (blessed $feature && $feature->can('seqid') &&
	   $feature->can('start') && $feature->can('end')) {
      ($seqid, $start, $end) = ($feature->seqid, $feature->start,
				$feature->end)
    }
    else {
      my $data = ref $feature || $feature;
      $self->throw('invalid_arguments_to_get_feature_bins', $data);
    }
    my @feature_bins;
    my $count;
    my $single_bin;
    for my $bin_size (128_000, 1_000_000, 8_000_000, 64_000_000,
		      512_000_000) {
      $count++;
      my $start_bin = int($start/$bin_size);
      my $end_bin   = int($end/$bin_size);
      my @these_bins = map {$_ = join ':', ($seqid, $count, $_)} ($start_bin .. $end_bin);
	if (! $single_bin && scalar @these_bins == 1) {
	    $single_bin = shift @these_bins;
	}
	unshift @feature_bins, @these_bins;
    }
    unshift @feature_bins, $single_bin;
    return wantarray ? @feature_bins : \@feature_bins;
}

#-----------------------------------------------------------------------------

=head2 translate

 Title   : translate
 Usage   : $base->translate($sequence, $offset, $length);
 Function: Translate a nucleotide sequence to an amino acid sequence
 Returns : An amino acid sequence
 Args    : The sequence as a scalar, and integer offset and an integer
	   length

=cut

sub translate {
  my ($self, $sequence, $offset, $length) = @_;

  my $genetic_code = $self->genetic_code;

  $offset ||= 0;
  $length ||= length($sequence);

  my $polypeptide;
  for (my $i = (0 + $offset); $i < $length; $i += 3) {
    my $codon = uc substr($sequence, $i, 3);
    my $aa = $genetic_code->{$codon};
    $polypeptide .= $aa;
  }
  return $polypeptide;
}

#-----------------------------------------------------------------------------

=head2 genetic_code

 Title   : genetic_code
 Usage   : $base->genetic_code;
 Function: Returns a hash reference of the genetic code
 Returns : A hash reference of the genetic code
 Args    : None

=cut

sub genetic_code {
  my $self = shift;

  return {AAA => 'K',
	  AAC => 'N',
	  AAG => 'K',
	  AAT => 'N',
	  ACA => 'T',
	  ACC => 'T',
	  ACG => 'T',
	  ACT => 'T',
	  AGA => 'R',
	  AGC => 'S',
	  AGG => 'R',
	  AGT => 'S',
	  ATA => 'I',
	  ATC => 'I',
	  ATG => 'M',
	  ATT => 'I',
	  CAA => 'Q',
	  CAC => 'H',
	  CAG => 'Q',
	  CAT => 'H',
	  CCA => 'P',
	  CCC => 'P',
	  CCG => 'P',
	  CCT => 'P',
	  CGA => 'R',
	  CGC => 'R',
	  CGG => 'R',
	  CGT => 'R',
	  CTA => 'L',
	  CTC => 'L',
	  CTG => 'L',
	  CTT => 'L',
	  GAA => 'E',
	  GAC => 'D',
	  GAG => 'E',
	  GAT => 'D',
	  GCA => 'A',
	  GCC => 'A',
	  GCG => 'A',
	  GCT => 'A',
	  GGA => 'G',
	  GGC => 'G',
	  GGG => 'G',
	  GGT => 'G',
	  GTA => 'V',
	  GTC => 'V',
	  GTG => 'V',
	  GTT => 'V',
	  TAA => '*',
	  TAC => 'Y',
	  TAG => '*',
	  TAT => 'Y',
	  TCA => 'S',
	  TCC => 'S',
	  TCG => 'S',
	  TCT => 'S',
	  TGA => '*',
	  TGC => 'C',
	  TGG => 'W',
	  TGT => 'C',
	  TTA => 'L',
	  TTC => 'F',
	  TTG => 'L',
	  TTT => 'F',
	 };
}

#-----------------------------------------------------------------------------

=head2 time_stamp

 Title   : time_stamp
 Usage   : $base->time_stamp;
 Function: Returns a YYYYMMDD time_stamp
 Returns : A YYYYMMDD time_stamp
 Args    : None

=cut

sub time_stamp {

  my $self = shift;

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,
      $yday,$isdst) = localtime(time);
  my $time_stamp = sprintf("%02d%02d%02d", $year + 1900,
			   $mon + 1, $mday);
  return $time_stamp;
}

#-----------------------------------------------------------------------------

=head2 random_string

 Title   : random_string
 Usage   : $base->random_string;
 Function: Returns a random alphanumeric string
 Returns : A random alphanumeric string
 Args    : The length of the string to be returned [8]

=cut

sub random_string {
  my ($self, $length) = @_;
  $length ||= 8;
  my $random_string = join "", map { unpack "H*", chr(rand(256)) } (1 .. $length);
  return substr($random_string, 0, $length);
}

#-----------------------------------------------------------------------------

=head2 float_lt

 Title   : float_lt
 Usage   : $base->float_lt(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is less than (<) the
	   second number at a given level of accuracy.
 Returns : 1 if the first number is less than the second, otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut

sub float_lt {
	my ($self, $A, $B, $accuracy) = @_;

	$accuracy ||= 6;
	$A = sprintf("%.${accuracy}f", $A);
	$B = sprintf("%.${accuracy}f", $B);
	$A =~ s/\.//;
	$B =~ s/\.//;
	return $A < $B;
}

#-----------------------------------------------------------------------------

=head2 float_le

 Title   : float_le
 Usage   : $base->float_le(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is less than or equal to
	   (<=) the second number at a given level of accuracy.
 Returns : 1 if the first number is less than or equal to the second,
	   otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut

sub float_le {
	my ($self, $A, $B, $accuracy) = @_;

	$accuracy ||= 6;
	$A = sprintf("%.${accuracy}f", $A);
	$B = sprintf("%.${accuracy}f", $B);
	$A =~ s/\.//;
	$B =~ s/\.//;
	return $A <= $B;
}

#-----------------------------------------------------------------------------

=head2 float_gt

 Title   : float_gt
 Usage   : $base->float_gt(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is greater than (>) the
	   second number at a given level of accuracy.
 Returns : 1 if the first number is greater than the second, otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut

sub float_gt {
	my ($self, $A, $B, $accuracy) = @_;

	$accuracy ||= 6;
	$A = sprintf("%.${accuracy}f", $A);
	$B = sprintf("%.${accuracy}f", $B);
	$A =~ s/\.//;
	$B =~ s/\.//;
	return $A > $B;
}

#-----------------------------------------------------------------------------

=head2 float_ge

 Title   : float_ge
 Usage   : $base->float_ge(0.0000123, 0.0000124, 7);
 Function: Return true if the first number given is greater than or equal
	   to (>=) the second number at a given level of accuracy.
 Returns : 1 if the first number is greater than or equal to the second,
	   otherwise 0
 Args    : The two values to compare and optionally a integer value for
	   the accuracy.  Accuracy defaults to 6 decimal places.

=cut

sub float_ge {
	my ($self, $A, $B, $accuracy) = @_;

	$accuracy ||= 6;
	$A = sprintf("%.${accuracy}f", $A);
	$B = sprintf("%.${accuracy}f", $B);
	$A =~ s/\.//;
	$B =~ s/\.//;
	return $A >= $B;
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=over

=item C<< invalid_arguments_to_prepare_args >>

C<GAL::Base::prepare_args> accepts an array, a hash or a reference to
either an array or hash, but it was passed something different.

=item C<< invalid_ipuac_nucleotide_code >>

C<GAL::Base::expand_iupac_nt_codes> was passed a charachter that is
not a valid IUPAC nucleotide code
(http://en.wikipedia.org/wiki/Nucleic_acid_notation).

=item C<< failed_to_load_module >>

C<GAL::Base::load_module> was unable to load (require) the specified
module.  The module may not be installed or it may have a compile time
error.

=item C<< invalid_arguments_to_get_feature_bins >>

C<GAL::Base::get_feature_bins> was called with invalid arguments.  It
must have either a hash with the keys qw(seqid start end) or an object
with those same keys as methods.  The error message will try to give
you some idea of what arguments were passed.

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Base> requires no configuration files or environment variables.

=head1 DEPENDENCIES

=over

=item C<< Carp qw(croak cluck) >>

=item C<< Bio::DB::Fasta >>

=back

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
