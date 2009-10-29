package GAL::Parser::gff;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base ;

=head1 NAME

GFF - <One line description of module's purpose here>

=head1 VERSION

This document describes GFF version 0.01

=head1 SYNOPSIS

     use GFF;

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
     Usage   : GFF->new();
     Function: Creates a GFF object;
     Returns : A GFF object
     Args    :

=cut

sub new {
	my ($class, $args) = @_;
	my $self = {};
	bless $self, $class;
	$self->_initialize_args($args);
	return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {
	my ($self, $args) = @_;

	my @data_types = qw(gff_file);

	for my $type (@data_types) {
		$args->{$type} && $self->$type($args->{$type});
       }
}

#-----------------------------------------------------------------------------
=head2 parse_file

 Title   : parse_file
 Usage   : $a = $self->_parse_file();
 Function: Parses the GFF file.
 Returns : GFF object.
 Args    : None.

=cut

sub parse_file {
	my $self = shift;

	my $file = $self->gff_file;

	open (my $IN, '<', $file) or die
	  "Can't open GFF file $file for reading\n$!\n";

      LINE:
	while (my $line = <$IN>) {

		$self->parse($line);

	}
	close $IN;
}
#-----------------------------------------------------------------------------
=head2 _parse_line

 Title   : _parse_line
 Usage   : $a = $self->_parse_line();
 Function: Parse the feature line
 Returns : N/A
 Args    : A 9 column text string in GFF

=cut

sub _parse_line {

	my ($self, $line) = @_;

	my ($seq, $source, $type, $start, $end, $score,
	    $strand, $phase, $attrb_text) = split /\t/, $line;

	$seq    =     $self->_parse_seq($seq);
	$source =     $self->_parse_source($source);
	$type   =     $self->_parse_type($type);
	$start  =     $self->_parse_start($start);
	$end    =     $self->_parse_end($end);
	$score  =     $self->_parse_score($score);
	$strand =     $self->_parse_strand($strand);
	$phase  =     $self->_parse_phase($phase);
	$attributes = $self->_parse_attributes($attrb_text);

	$self->annotation->add_feature(seq    	  => $seq,
				       source 	  => $source,
				       type   	  => $type,
				       start  	  => $start,
				       end    	  => $end,
				       score  	  => $score,
				       strand 	  => $strand,
				       phase  	  => $phase,
				       attributes => $attributes,
				      );
}
#-----------------------------------------------------------------------------
sub _parse_seq {
	my ($self, $seq) = @_;
	return $seq;
}
#-----------------------------------------------------------------------------
sub _parse_source {
	my ($self, $source) = @_;
	return $source;
}
#-----------------------------------------------------------------------------
sub _parse_type {
	my ($self, $type) = @_;
	return $type;
}
#-----------------------------------------------------------------------------
sub _parse_start {
	my ($self, $start) = @_;
	return $start;
}
#-----------------------------------------------------------------------------
sub _parse_end {
	my ($self, $end) = @_;
	return $end;
}
#-----------------------------------------------------------------------------
sub _parse_score {
	my ($self, $score) = @_;
	return $score;
}
#-----------------------------------------------------------------------------
sub _parse_strand {
	my ($self, $strand) = @_;
	return $strand;
}
#-----------------------------------------------------------------------------
sub _parse_phase {
	my ($self, $phase) = @_;
	return $phase;
}
#-----------------------------------------------------------------------------
sub _parse_attributes {
	my ($self, $attrb_txt) = @_;
	return $attrb_txt;
}
#-----------------------------------------------------------------------------
sub gff_file {
	my ($self, $gff_file) = @_;

	$self->{_gff_file} = $gff_file if $gff_file;
	return $self->{_gff_file};
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

<GFF> requires no configuration files or environment variables.

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
