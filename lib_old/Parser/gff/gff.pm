package GFF;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base ;

=head1 NAME

GFF - <One line description of module's purpose here>

=head1 VERSION

This document describes GFF version 0.01

=head1 SYNOPSIS

     use GFF;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 METHODS

=cut

#-----------------------------------------------------------------------------

=head2

     Title   : new 
     Usage   : GFF->new();
     Function: Creates a GFF object;
     Returns : A GFF object
     Args    : 

=cut

sub new {
        my ($class, $args) = @_;
        my $self = {};
        bless $self, $class;
        $self->_initialize_args($args);
	$self->_parse_gff_file;
        return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {
        my ($self, $args) = @_;

        my @data_types = qw(gff_file);

        for my $type (@data_types) {
                $args->{$type} && $self->$type($args->{$type});
       }
}

#-----------------------------------------------------------------------------

=head2 _parse_gff_file

 Title   : _parse_gff_file
 Usage   : $a = $self->_parse_gff_file();
 Function: Parses the GFF file.
 Returns : GFF object.
 Args    : None.

=cut

sub _parse_gff_file {
        my $self = shift;

	my $file = $self->gff_file;

	open (my $IN, '<', $file) or die
	  "Can't open GFF file $file for reading\n$!\n";

	my (%mrnas, %cdss, %exons, %introns);
	while (my $line = <$IN>) {

		# Parse meta data here if ##
		last if $line =~ /^\s*\#\#FASTA/;
		next if $line =~ /^\s*\#/; # Skip comment lines and meta-data for now.
		next if $line =~ /^\s*$/;  # Skip blank lines.

		# GFF::Feature->new($line);
		my ($seq, $source, $type, $start, $end, $score,
		    $strand, $phase, $attrb_text) = split /\t/, $line;

		my $attrb  = $self->_parse_attrb($attrb_text);

		my $feature = {seq    => $seq,
			       source => $source,
			       type   => $type,
			       start  => $start,
			       end    => $end,
			       score  => $score,
			       strand => $strand,
			       phase  => $phase,
			       attrb  => $attrb};

		$self->validate_feature($feature);

		my @parents = ();
		@parents = @{$attrb->{Parent}} if ref $attrb->{Parent} eq 'ARRAY';
		my $id     = shift @{$attrb->{ID}};

		# Here $self->add_features can cache features that have parents
		# and $self->resolve_features on ### will place features on parents
		# if ($feature->has_parent) {$self->add_feature}
		# else {$self->cache_feature}

		if ($type eq 'gene') {
			$self->{genes}{$id} = $feature;
		}
		elsif ($type eq 'mRNA') {
			$mrnas{$id} = $feature;
		}
		elsif ($type eq 'CDS') {
			for my $parent (@parents) {
				$feature->{attrb}{Parent} = $parent;
				push @{$cdss{$parent}}, $feature;
			}
		}
		elsif ($type eq 'exon') {
			for my $parent (@parents) {
				$feature->{attrb}{Parent} = $parent;
				push @{$exons{$parent}}, $feature;
				# Grab some feature details from the first exon seen;
				$introns{$parent}{seq}    ||= $feature->{seq};
				$introns{$parent}{source} ||= $feature->{source};
				$introns{$parent}{strand} ||= $feature->{strand};
				push @{$introns{$parent}{coords}}, ($start, $end);
			}
		}
	}

	close $IN;

	# Place CDS features
	for my $mrna_id (keys %cdss) {
		my %cds_count;
		for my $feature (@{$cdss{$mrna_id}}) {
			my $id      = shift @{$feature->{attrb}{ID}};
			$id ||= "$mrna_id:CDS:" . ++$cds_count{$mrna_id};
			$mrnas{$mrna_id}{cdss}{$id} = $feature;
		}
	}
	# Place exon features
	for my $mrna_id (keys %exons) {
		my %exon_count;
		for my $feature (@{$exons{$mrna_id}}) {
			my $id      = shift @{$feature->{attrb}{ID}};
			$id ||= "$mrna_id:exon:" . ++$exon_count{$mrna_id};
			$mrnas{$mrna_id}{exons}{$id} = $feature;
		}
	}
	# Place intron features
	my %intron_count;
      INTRON:
	for my $mrna_id (keys %introns) {
		my @coords = sort @{$introns{$mrna_id}{coords}};
		# Deal with single exon transcripts;
		if (scalar @coords <= 2) {
			$mrnas{$mrna_id}{introns} = {};
			next INTRON;
		}
		shift @coords;
		pop   @coords;
		while (@coords) {
			my $start = shift @coords;
			my $end   = shift @coords;
			die "Bad intron coordinates\n" unless $start && $end;
			my $id = $mrna_id . ':intron:' . ++$intron_count{$mrna_id};
			my $attrb = {Parent => $mrna_id,
				     ID     => $id,
				    };
			my $feature = {seq    => $introns{$mrna_id}{seq},
				       source => $introns{$mrna_id}{source},
				       type   => 'intron',
				       start  => $start,
				       end    => $end,
				       score  => '.',
				       strand => $introns{$mrna_id}{strand},
				       phase  => '.',
				       attrb  => $attrb,
				      };
			$mrnas{$mrna_id}{introns}{$id} = $feature;
		}
	}
	# Place mRNA features
	for my $mrna_id (keys %mrnas) {
		my $parent = shift @{$mrnas{$mrna_id}{attrb}{Parent}};
		$self->{genes}{$parent}{mrnas}{$mrna_id} = $mrnas{$mrna_id};
	}
}
#-----------------------------------------------------------------------------
sub gff_file {
	my ($self, $gff_file) = @_;

	$self->{_gff_file} = $gff_file if $gff_file;
	return $self->{_gff_file};
}
#-----------------------------------------------------------------------------
sub _parse_attrb {
	my ($self, $attrb_text) = @_;

	my @attrbs = split /\s*;\s*/, $attrb_text;
	my %attrbs;
	for my $attrb (@attrbs) {
		$attrb =~ s/^\s*(.*?)\s*$/$1/;
		my ($key, $value_txt) = split /\s*=\s*/, $attrb;
		my @values = split /\s*,\s*/, $value_txt;
		for my $value (@values) {
			push @{$attrbs{$key}}, $value;
		}
	}
	return \%attrbs;
}
#-----------------------------------------------------------------------------
sub validate_feature {
	my ($self, $feature) = @_;

	if (! $feature->{seq}) {
		my $id = $feature->{attrb}{ID};
		die "Bad feature: No seq field ($id)\n";
	}
	if (! $feature->{source}) {
		my $id = $feature->{attrb}{ID};
		die "Bad feature: No source field ($id)\n";
	}
	if (! $feature->{type}) {
		my $id = $feature->{attrb}{ID};
		die "Bad feature: No type field ($id)\n";
	}
	if ($feature->{start} !~ /^-?\d+$/) {
		my $id = $feature->{attrb}{ID};
		my $start = $feature->{start};
		die "Bad feature: start=$start ($id)\n";
	}
	if ($feature->{end} !~ /^-?\d+$/) {
		my $id = $feature->{attrb}{ID};
		my $end = $feature->{end};
		die "Bad feature: end=$end ($id)\n";
	}
}
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=for author to fill in:
     List every single error and warning message that the module can
     generate (even the ones that will "never happen"), with a full
     explanation of each problem, one or more likely causes, and any
     suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GFF> requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

1;






