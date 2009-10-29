package GAL::Schema::Result::Feature;

use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('feature');
__PACKAGE__->add_columns(qw/ feature_id seqid source type start end score strand phase name /);
__PACKAGE__->set_primary_key('feature_id');
__PACKAGE__->has_many(attributes => 'GAL::Schema::Result::Attribute', 'feature_id');

sub inflate_result {
        my $self = shift;
        my $feature = $self->next::method(@_);

	my $feature_map = {SNP                                           => 'sequence_alteration',
			   inversion                                     => 'sequence_alteration',
			   insertion                                     => 'sequence_alteration',
			   indel                                         => 'sequence_alteration',
			   substitution                                  => 'sequence_alteration',
			   deletion                                      => 'sequence_alteration',
			   translocation                                 => 'sequence_alteration',
			   uncharacterised_change_in_nucleotide_sequence => 'sequence_alteration',
			   nucleotide_insertion                          => 'sequence_alteration',
			   nucleotide_deletion                           => 'sequence_alteration',
			   nucleotide_duplication                        => 'sequence_alteration',
			   transgenic_insertion                          => 'sequence_alteration',
			   recombinationally_inverted_gene               => 'sequence_alteration',
			   SNP                                           => 'sequence_alteration',
			   point_mutation                                => 'sequence_alteration',
			   sequence_length_variation                     => 'sequence_alteration',
			   complex_substitution                          => 'sequence_alteration',
			   MNP                                           => 'sequence_alteration',
			   transition                                    => 'sequence_alteration',
			   pyrimidine_transition                         => 'sequence_alteration',
			   purine_transition                             => 'sequence_alteration',
			   A_to_G_transition                             => 'sequence_alteration',
			   G_to_A_transition                             => 'sequence_alteration',
			   C_to_T_transition                             => 'sequence_alteration',
			   T_to_C_transition                             => 'sequence_alteration',
			   C_to_T_transition_at_pCpG_site                => 'sequence_alteration',
			   pyrimidine_to_purine_transversion             => 'sequence_alteration',
			   purine_to_pyrimidine_transversion             => 'sequence_alteration',
			   G_to_T_transversion                           => 'sequence_alteration',
			   A_to_T_transversion                           => 'sequence_alteration',
			   A_to_C_transversion                           => 'sequence_alteration',
			   G_to_C_transversion                           => 'sequence_alteration',
			   T_to_G_transversion                           => 'sequence_alteration',
			   T_to_A_transversion                           => 'sequence_alteration',
			   C_to_A_transversion                           => 'sequence_alteration',
			   C_to_G_transversion                           => 'sequence_alteration',
			  };

	my $subtype = $feature_map->{$feature->type};

	if ($subtype) {
		my $subclass = __PACKAGE__ . '::' . $subtype;
		$self->ensure_class_loaded($subclass);
		bless $feature, $subclass;
	}

        return $feature;
}

#-----------------------------------------------------------------------------

1;
