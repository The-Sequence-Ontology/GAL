package GAL::Parser::smith_ant_snps;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use base qw(GAL::Parser);
use GAL::Reader::DelimitedLine;

=head1 NAME

GAL::Parser::smith_ant_snps - Parse SMITH_ANT_SNPS files

=head1 VERSION

This document describes GAL::Parser::smith_ant_snps version 0.01

=head1 SYNOPSIS

    my $parser = GAL::Parser::smith_ant_snps.gff->new(file => 'smith_ant_snps.gff');

    while (my $feature_hash = $parser->next_feature_hash) {
	print $parser->to_gff3($feature_hash) . "\n";
    }

=head1 DESCRIPTION

L<GAL::Parser::smith_ant_snps> provides a parser for SMITH_ANT_SNPS
data.  This is a one off parser for data that came from Chris Smith
for the ant genome paper.

=head1 Constructor

New L<GAL::Parser::smith_ant_snps> objects are created by the class method
new.  Arguments should be passed to the constructor as a list (or
reference) of key value pairs.  All attributes of the
L<GAL::Parser::smith_ant_snps> object can be set in the call to new. An
simple example of object creation would look like this:

    my $parser = GAL::Parser::smith_ant_snps->new(file => 'smith_ant_snps.gff');

The constructor recognizes the following parameters which will set the
appropriate attributes:

=item * C<< file => feature_file.gff >>

This optional parameter provides the filename for the file containing
the data to be parsed. While this parameter is optional either it, or
the following fh parameter must be set.

=item * C<< fh => feature_file.gff >>

This optional parameter provides a filehandle to read data from. While
this parameter is optional either it, or the following fh parameter
must be set.

=cut

#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Parser::smith_ant_snps->new();
     Function: Creates a GAL::Parser::smith_ant_snps object;
     Returns : A GAL::Parser::smith_ant_snps object
     Args    : See the attributes described above.

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {
	my ($self, @args) = @_;

	######################################################################
	# This block of code handels class attributes.  Use the
	# @valid_attributes below to define the valid attributes for
	# this class.  You must have identically named get/set methods
	# for each attribute.  Leave the rest of this block alone!
	######################################################################
	my $args = $self->SUPER::_initialize_args(@args);
	my @valid_attributes = qw(file fh); # Set valid class attributes here
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : A hash ref needed by Feature.pm to create a Feature object
 Args    : A hash ref of fields that this sub can understand (In this case GFF3).

=cut

sub parse_record {
	my ($self, $record) = @_;

	# seqid              start  end    ref	var      total_reads   variant % ?? 
	# >scf7180001004166  576    576    T  	C	 587  	       11%
	# >scf7180001005075  31603  31603  T  	A	 548  	       99%
	# >scf7180001005075  31652  31652  T  	C	 546  	       100%
	# >scf7180001005075  31490  31490  A  	T	 545  	       99%
	# >scf7180001005075  31679  31679  A  	G	 512  	       100%
	# >scf7180001005075  31700  31700  T  	C	 490  	       99%
	# >scf7180001002780  530    530    G  	A	 458  	       99%
	# >scf7180001004665  27505  27505  A  	G	 451  	       98%
	# >scf7180001004295  2127   2127   G  	A	 441  	       98%
	# >scf7180001005054  5467   5467   T  	C	 422  	       98%      
	
	# $record is a hash reference that contains the keys assigned
	# in the $self->fields call in _initialize_args above

	# Fill in the first 8 columns for GFF3
	# See http://www.sequenceontology.org/gff3.html for details.
	my $seqid      = $record->{seqid};
	$seqid =~ s/^>//;
	my $source     = 'Smith';
	my $type       = 'SNV';
	my $start      = $record->{start};
	my $end        = $record->{end};
	my $score      = '.',
	my $strand     = '+',
	my $phase      = '.',

	my $feature_id = join ':', ($seqid, $start);
	
	my $variant_seq   = $record->{var};
	my $reference_seq = $record->{ref};
	my $fasta_ref ||= uc $self->fasta->seq($seqid, $start, $end);

	$self->warn(message => ("Warning : reference_seq_not_equal_to_fasta : " . 
				join ', ', values %{$record})
		    )
	    unless $reference_seq eq $fasta_ref;

	my $total_reads = $record->{total_reads};
	my $var_pct = $record->{var_pct};
	$var_pct =~ s/%//;
	$var_pct /= 100;
	# my $variant_reads = sprintf("%.0f", ($total_reads * $var_pct)); 

	my $attributes = {Reference_seq => [$reference_seq],
			  Variant_seq   => [$variant_seq],
			  ID            => [$feature_id],
			  Total_reads   => [$total_reads],
			  #Variant_reads => [$variant_reads],
		      };

	my $feature_data = {feature_id => $feature_id,
			    seqid      => $seqid,
			    source     => $source,
			    type       => $type,
			    start      => $start,
			    end        => $end,
			    score      => $score,
			    strand     => $strand,
			    phase      => $phase,
			    attributes => $attributes,
			   };

	return $feature_data;
}

#-----------------------------------------------------------------------------

=head2 reader

 Title   : reader
 Usage   : $a = $self->reader
 Function: Return the reader object.
 Returns : A L<GAL::Reader::DelimitedLine> singleton.
 Args    : None

=cut

sub reader {
  my $self = shift;

  if (! $self->{reader}) {
    my @field_names = qw(seqid start end ref var total_reads var_pct);
    my $reader = GAL::Reader::DelimitedLine->new(field_names => \@field_names);
    $self->{reader} = $reader;
  }
  return $self->{reader};
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

L<GAL::Parser::smith_ant_snps> does not throw any warnings or errors.

=head1 CONFIGURATION AND ENVIRONMENT

L<GAL::Parser::smith_ant_snps> requires no configuration files or
environment variables.

=head1 DEPENDENCIES

L<GAL::Parser>
L<GAL::Reader::DelimitedLine>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Barry Moore <barry.moore@genetics.utah.edu>.  All
rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut

1;
