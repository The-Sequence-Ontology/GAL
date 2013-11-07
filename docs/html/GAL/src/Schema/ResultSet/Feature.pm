package GAL::Schema::ResultSet::Feature;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use GAL::List::Numeric;
use GAL::List::Categorical;

sub seqids {
  return GAL::List::Categorical->new(list => [shift->get_column('seqid')->all]);
}

sub sources {
  return GAL::List::Categorical->new(list => [shift->get_column('source')->all]);
}

sub types {
  return GAL::List::Categorical->new(list => [shift->get_column('type')->all]);
}

sub starts {
  return GAL::List::Numeric->new(list => [shift->get_column('start')->all]);
}

sub ends {
  return GAL::List::Numeric->new(list => [shift->get_column('end')->all]);
}

sub spans {
  my $self = shift;

  return $self->{_gal_spans} if exists $self->{_gal_spans};
  my $spans = GAL::Interval::Span->new();
  while (my $feature = $self->next) {
    $spans->add_feature($feature);
  }
  $self->{_gal_spans} = $spans;
  return $self->{_gal_spans};
}

## Attribute aggregation


1;
