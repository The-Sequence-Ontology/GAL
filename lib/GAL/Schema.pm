package GAL::Schema;
use base qw/DBIx::Class::Schema/;
use DBIx::Class::ResultClass::HashRefInflator;

__PACKAGE__->load_namespaces();

1;
