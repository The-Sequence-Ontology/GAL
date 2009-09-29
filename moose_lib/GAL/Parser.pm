package GAL::Parser;

use Moose;
use Text::RecordParser;
use GAL::FeatureFactory;

with 'GAL::Base';

has 'file' => ( is       => 'rw',
		required => 1
	      );

has 'record_separator' => ( is  => 'rw',
			    isa => 'Str',
			    default => sub {"\n"},
			  );

has 'field_separator' => ( is => 'rw',
			   isa => 'Str',
			   default => sub {"\t"},
			 );

has 'comment_delimiter' => ( is => 'rw',
			     isa => 'RegexpRef',
			     default => sub {qr|\s*\#|},
			   );

has 'feature_factory' => ( is => 'rw',
			   default => sub {GAL::FeatureFactory->new()},
			 );

has 'fields' => ( is => 'rw',
		  isa => 'ArrayRef',
		  default => sub {[qw(seqid source type start end score strand phase attributes)]},
		);

has 'parser' => ( is      => 'rw',
		  lazy    => 1,
		  builder => '_build_parser',
		);

sub _build_parser {
	my $self = shift;
	my $parser = Text::RecordParser->new({filename         => $self->file,
					      record_separator => $self->record_separator,
					      field_separator  => $self->field_separator,
					      comment          => $self->comment_delimiter,
					     }
					    );
	$parser->bind_fields(@{$self->fields});
	return $parser;
}

#-----------------------------------------------------------------------------

=head2 _read_next_record

 Title   : _read_next_record
 Usage   : $a = $self->_read_next_record();
 Function: Return the next record from the parser
 Returns : The next record from the parser.
 Args    : N/A

=cut

sub _read_next_record {
	my $self = shift;
	return $self->parser->fetchrow_hashref;
}

#-----------------------------------------------------------------------------

=head2 get_all_features

 Title   : get_all_features
 Alias   : get_features
 Usage   : $features = $self->get_all_features();
 Function: Get all the features objects created by this parser.
 Returns : A list of Feature objects.
 Args    : N/A

=cut

sub get_features {shift->get_all_features(@_)}

sub get_all_features {
	my $self = shift;
	$self->_parse_all_features unless $self->{features};
	return wantarray ? @{$self->{features}} : $self->{features};
}

#-----------------------------------------------------------------------------

=head2 _parse_all_features

 Title   : _parse_all_features
 Alias   : parse # Depricated but kept for backwards compatibility
 Usage   : $a = $self->_parse_all_features();
 Function: Parse and store all of the features in a file
 Returns : N/A
 Args    : N/A

=cut

sub parse {
	my $self = shift;
	$self->warn(message => ("The method GAL::Parser::parse is " .
				"depricated.  Please use " .
				"GAL::Parser::_parse_all_features " .
				"instead.")
		   );
	return $self->_parse_all_features(@_);
}

sub _parse_all_features {

	my $self = shift;

	while (my $record = $self->_read_next_record) {

		my $feature_hash = $self->parse_record($record);
		next unless defined $feature_hash;
		my $type = $feature_hash->{type};
		my $feature = $self->feature_factory->create($feature_hash);
		push @{$self->{features}}, $feature;

	}
	return $self;
}

#-----------------------------------------------------------------------------

=head2 parse_next_feature

 Title   : parse_next_feature
 Alias   : next_feature
 Alias   : get_next_feature
 Usage   : $a = $self->parse_next_feature();
 Function: Get/Set the value of parse.
 Returns : The value of parse.
 Args    : A value to set parse to.

=cut

sub next_feature     {shift->parse_next_feature(@_)}
sub get_next_feature {shift->parse_next_feature(@_)}

sub parse_next_feature {

	my $self = shift;

	my $feature_hash;
	until (defined $feature_hash) {
		my $record = $self->_read_next_record;
		last unless $record;

		$feature_hash = $self->parse_record($record);
	}
	return undef unless defined $feature_hash;

	my $type = $feature_hash->{type};
	my $feature = $self->feature_factory->create($feature_hash);

	return $feature;
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : A hash ref needed by Feature.pm to create a Feature object
 Args    : A hash ref of fields that this sub can understand (In this case GFF3).

=cut

sub parse_record {
	my ($self, $record) = @_;

	$record->{attributes} = $self->parse_attributes($record->{attributes});

	return $record;
}

#-----------------------------------------------------------------------------

=head2 parse_attributes

 Title   : parse_attributes
 Usage   : $a = $self->parse_attributes();
 Function: Parse the attributes from column 9 in a GFF3 style file.
 Returns : The value of parse_attributes.
 Args    : A value to set parse_attributes to.

=cut

sub parse_attributes {
	my ($self, $attrb_text) = @_;

	my @attrbs = split /\s*;\s*/, $attrb_text;
	my %attrb_hash;
	for my $attrb (@attrbs) {
		my ($key, $value_text) = split /=/, $attrb;
		my @values = split /,/, $value_text;
		push @{$attrb_hash{$key}}, @values;
	}
	return \%attrb_hash;
}

#-----------------------------------------------------------------------------

=head2 get_genotype

 Title   : get_genotype
 Usage   : $a = $self->get_genotype($reference_allele, \@variant_alleles);
 Function: Determine the genotype.
 Returns : A genotype name
 Args    : The reference allele and an array reference of variant alleles.

=cut

sub get_genotype {
	my ($self, $reference_allele, $variant_alleles) = @_;

	my $variant_count = scalar @{$variant_alleles};

	if ($variant_count == 1) {
		if ($variant_alleles->[0] ne $reference_allele) {
			return 'homozygous';
		}
		else {
			self->warn(message => 'You appear to have a variant that is homozygous for the reference allele:');
		}
	}
	elsif ($variant_count > 1) {
		if (grep {$_ eq $reference_allele} @{$variant_alleles}) {
			return 'heterozygous:with_reference_allele';
		}
		else {
			return 'heterozygous:no_reference_allele';
		}
	}

	$self->throw(message => ("Uncaught combination ref:$reference_allele vars:" .
				 join(q{,}, @{$variant_alleles}) .
				 ' in GAL::Parser::get_genotype!'));
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

<GAL::Parser> requires no configuration files or environment variables.

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

__PACKAGE__->meta->make_immutable;

1;
