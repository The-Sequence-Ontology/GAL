package GAL::Schema::Result::Attribute;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('attribute');
__PACKAGE__->add_columns(qw/ attribute_id feature_id att_key att_value /);
__PACKAGE__->set_primary_key('attribute_id');
__PACKAGE__->belongs_to(features => 'GAL::Schema::Result::Feature', 'feature_id');

1;
