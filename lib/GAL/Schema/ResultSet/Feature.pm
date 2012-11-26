package GAL::Schema::ResultSet::Feature;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use List::Util;

sub seqids {
  my $self = shift;
  my %seen;
  my @seqids = grep {! $seen{$_}++} $self->get_column('seqid')->all;
  return wantarray ? @seqids : \@seqids;
}

sub seqid_counts {
  my $self = shift;
  my %seqids;
  map {$seqids{$_}++} $self->get_column('seqid')->all;
  return wantarray ? %seqids : \%seqids;
}

# sub sources {
# 
# }
# 
# sub types {
# 
# }
# 
# sub type_counts {
# 
# }
# 
# sub min_start {
# 
# }
# 
# sub max_start {
# 
# }
# 
# sub min_end {
# 
# }
# 
# sub max_end {
# 
# }
# 
# sub min_length {
# 
# }
# 
# sub max_length {
# 
# }
# 
# sub footprint {
# 
# }
# sub min_score {
# 
# }
# 
# sub max_score {
# 
# }
# 
# sub stats {
# 
# }
# Attribute aggreation



1;
