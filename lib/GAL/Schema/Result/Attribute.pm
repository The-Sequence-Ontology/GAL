package GAL::Schema::Result::Attribute;
use base qw/DBIx::Class/;

=head1 NAME

GAL::Schema::Result::Attribute - Access to feature attributes for GAL::Schema::Result::Features

=head1 VERSION

This document describes GAL::Schema::Result::Attribute version 0.01

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

    my $mrnas = $features->search({type => 'mRNA'});
    while (my $mrna = $mrnas->next) {
	my $attributes = $mrnas->attributes->all;
      }
    }


=head1 DESCRIPTION

<GAL::Schema::Result::Attribute> provides access to a
<GAL::Schema::Result::Feature>'s attributes.  You don't instantiate
objects for it yourself, <DBIx::Class> does that for you, hence there
is no constructor and there are no attributes available and currently there
are no methods except those provided by DBIx::Class.

=cut

#-----------------------------------------------------------------------------


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('attribute');
__PACKAGE__->add_columns(qw/ subject_id attribute_id feature_id att_key att_value /);
__PACKAGE__->set_primary_key('attribute_id');
__PACKAGE__->belongs_to(features => 'GAL::Schema::Result::Feature', 'feature_id');

#-----------------------------------------------------------------------------

=head1 METHODS

=head2 subject_id

 Title   : subject_id
 Usage   : $seqid = $self->subject_id;
 Function: Get the attributes subject_id.
 Returns : A text string for the subject_id.
 Args    : None

=head2 attribute_id

 Title   : attribute_id
 Usage   : $seqid = $self->attribute_id;
 Function: Get the attributes attribute_id.
 Returns : A text string for the attribute_id.
 Args    : None

=head2 feature_id

 Title   : feature_id
 Usage   : $seqid = $self->feature_id;
 Function: Get the attributes feature_id.
 Returns : A text string for the feature_id.
 Args    : None

=head2 att_key

 Title   : att_key
 Usage   : $seqid = $self->att_key;
 Function: Get the attributes key.
 Returns : A text string for the key.
 Args    : None

=head2 subject

 Title   : att_value
 Usage   : $seqid = $self->att_value;
 Function: Get the attributes value(s)
 Returns : A text string for the value(s) as a comma seperated list.
 Args    : None

=head1 DIAGNOSTICS

This module currently throws no errors or warnings.

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Schema::Result::Attribute> requires no configuration files or environment variables.

=head1 DEPENDENCIES

<DBIx::Class>

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
