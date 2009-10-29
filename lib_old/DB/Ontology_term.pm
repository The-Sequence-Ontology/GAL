package GAL::DB::Ontology_term;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('ontology_term');
__PACKAGE__->add_columns(qw/
			    idx
			    feature_id
			    dbtag
			    dbid
			 /);
__PACKAGE__->set_primary_key(qw/idx/);
1;
