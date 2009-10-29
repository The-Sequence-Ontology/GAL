package GAL::DB::Dbxref;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('dbxref');
__PACKAGE__->add_columns(qw/
			    idx
			    feature_id
			    dbtag
			    dbvalue
			 /);
__PACKAGE__->set_primary_key(qw/idx/);
1;
