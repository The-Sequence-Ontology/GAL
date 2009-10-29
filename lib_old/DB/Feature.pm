package GAL::DB::Feature;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('feature');
__PACKAGE__->add_columns(qw/
			    id
			    seq
			    source
			    type
			    score
			    strand
			    phase
			    name
			    alias
			    target_id
			    target_start
			    target_end
			    target_strand
			    gap
			    derives_from
			    note
			 /);
__PACKAGE__->set_primary_key(qw/id/);
__PACKAGE__->has_many(attributes     => 'GAL::DB::Atttributes',   'feature_id');
__PACKAGE__->has_many(dbxrefs        => 'GAL::DB::Dbxref',        'feature_id');
__PACKAGE__->has_many(ontology_terms => 'GAL::DB::Ontology_term', 'feature_id');
1;
