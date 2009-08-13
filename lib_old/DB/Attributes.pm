package GAL::DB::Attributes;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('attributes');
__PACKAGE__->add_columns(qw/
			    idx
			    feature_id
			    tag
			    value
			 /);
__PACKAGE__->set_primary_key(qw/idx/);
1;
