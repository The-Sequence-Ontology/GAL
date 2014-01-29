#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $class = Module::Build->subclass
  (
   class => 'Module::Build::Custom',
   code => q{
       sub ACTION_build {
	 my $self = shift;
	 $self->SUPER::ACTION_build;
	 $self->dispatch('installdeps');
       }
       sub ACTION_install {
	   my $self = shift;
	   print "\n\nGAL does not do a system wide install\n\n";
	   print "To make the libraries and scripts accessible\n";
	   print "modify the paths to fit your system and run the following:\n\n";
	   print "export PERL5LIB=\$PERL5LIB:/path/to/GAL/lib\n";
	   print "export PATH=\$PATH:/path/to/GAL/bin\n\n";
	   print "Add those lines to ~/.bash_profile or /etc/profile to\n";
	   print "make those changes permanent.\n\n";
	   print "If you want a system wide install, edit the Build.PL script and\n";
	   print "remove the entire subroutine (ACTION_install) where this message\n";
	   print "is printed run Build realclean and re-install.\n\n";
       }
     },
  );

my $builder = $class->new(
			  # General
			  module_name         => 'GAL',
			  dist_author         => 'Barry Moore <barry.moore@genetics.utah.edu',
			  dist_version_from   => 'lib/GAL/Annotation.pm',
			  license             => 'Perl_5',
			  create_license      => 1,
			  create_readme       => 1,

			  # Prerequisites
			  requires => {
				       'perl'		                   => '5.6.1',
				       'Bio::DB::Fasta'		           => 0,
				       'Carp'				   => 0,
				       'Cwd'				   => 0,
				       'DBI'				   => 0,
				       'DBIx::Class'		           => 0,
				       'Getopt::Long'			   => 0,
				       'IO::All'                           => 0,
				       'List::MoreUtils'		   => 0,
				       'List::Util'			   => 0,
				       'Module::Build'			   => 0,
				       'Number::Format'			   => 0,
				       'Set::IntSpan::Fast'                => 0,
				       'Statistics::Descriptive'           => 0,
				       'Statistics::Descriptive::Discrete' => 0,
				       'Text::Graph'			   => 0,
				       'Text::Graph::DataSet'		   => 0,
				       'URI::Escape'			   => 0,
				       'Text::RecordParser'	           => 0,
				      },
			  build_requires => {
					     'TAP::Harness' => 0,
					     'Test::More'   => 0,
					    },
			  recommends => {
					 'Time::HiRes' => 0,
					 'DBIx::Class::ResultClass::HashRefInflator' => 0,

					},

			  # Testing
			  use_tap_harness     => 1,
			  tap_harness_args    => {verbosity  => -1,
						  timer      => 1,
						  show_count => 1,
						  merge      => 1},
			  test_files => [qw(
					    lib/GAL/t/001_annotation.t
					    lib/GAL/t/001_base.t
					    lib/GAL/t/001_pod_coverage.t
					    lib/GAL/t/001_test_template.t
					    lib/GAL/t/200_parser.t
					    lib/GAL/t/200_parser_basic_snp.t
					    lib/GAL/t/200_parser_bed.t
					    lib/GAL/t/200_parser_complete_genomics.t
					    lib/GAL/t/200_parser_complete_genomics_new.t
					    lib/GAL/t/200_parser_cosmic.t
					    lib/GAL/t/200_parser_dbsnp_flat.t
					    lib/GAL/t/200_parser_gff3.t
					    lib/GAL/t/200_parser_hapmap_genotypes.t
					    lib/GAL/t/200_parser_korean_indel.t
					    lib/GAL/t/200_parser_korean_snp.t
					    lib/GAL/t/200_parser_maq_cns2snp.t
					    lib/GAL/t/200_parser_na18507_sanger_indel.t
					    lib/GAL/t/200_parser_quake_snp.t
					    lib/GAL/t/200_parser_samtools_pileup.t
					    lib/GAL/t/200_parser_soap_snp.t
					    lib/GAL/t/200_parser_solid_snp.t
					    lib/GAL/t/200_parser_template.t
					    lib/GAL/t/200_parser_template_sequence_alteration.t
					    lib/GAL/t/200_parser_trait_o_matic.t
					    lib/GAL/t/200_parser_vcfv4_0.t
					    lib/GAL/t/200_parser_venter_indel.t
					    lib/GAL/t/200_parser_venter_snp.t
					    lib/GAL/t/200_parser_watson_cshl.t
					    lib/GAL/t/300_reader.t
					    lib/GAL/t/300_reader_delimitedline.t
					    lib/GAL/t/300_reader_recordparser.t
					    lib/GAL/t/300_reader_template.t
					    lib/GAL/t/400_storage.t
					    lib/GAL/t/400_storage_mysql.t
					    lib/GAL/t/400_storage_sqlite.t
					    lib/GAL/t/500_schema.t
					    lib/GAL/t/500_schema_result_attribute.t
					    lib/GAL/t/500_schema_result_feature.t
					    lib/GAL/t/500_schema_result_feature_cds.t
					    lib/GAL/t/500_schema_result_feature_exon.t
					    lib/GAL/t/500_schema_result_feature_five_prime_utr.t
					    lib/GAL/t/500_schema_result_feature_gene.t
					    lib/GAL/t/500_schema_result_feature_intron.t
					    lib/GAL/t/500_schema_result_feature_mrna.t
					    lib/GAL/t/500_schema_result_feature_mrna_BIG.t
					    lib/GAL/t/500_schema_result_feature_protein.t
					    lib/GAL/t/500_schema_result_feature_sequence_alteration.t
					    lib/GAL/t/500_schema_result_feature_sequence_feature.t
					    lib/GAL/t/500_schema_result_feature_template.t
					    lib/GAL/t/500_schema_result_feature_three_prime_utr.t
					    lib/GAL/t/500_schema_result_feature_transcript.t
					    lib/GAL/t/500_schema_result_realtionship.t
					    lib/GAL/t/600_list.t
					    lib/GAL/t/600_list_categorical.t
					    lib/GAL/t/600_list_numeric.t
					    bin/t/add_reference_seq.t
					    bin/t/annotation_summary.t
					    bin/t/build_genes.t
					    bin/t/fastq_tool.t
					    bin/t/feature2gff.t
					    bin/t/gal_add_introns.t
					    bin/t/gal_coding_gene_count.t
					    bin/t/gal_dump_CDS_sequence.t
					    bin/t/gal_example_parser.t
					    bin/t/gal_example_seq_features.t
					    bin/t/gal_feature_overlaps.t
					    bin/t/gal_remove_transcripts.t
					    bin/t/gal_protein_genes.t
					    bin/t/gal_splice_complexity.t
					    bin/t/gal_validate_proteins.t
					    bin/t/gff3_validator.t
					    bin/t/gff_tool.t
					    bin/t/gvf_validator.t
					    bin/t/map_seqids.t
					    bin/t/sam_inspector.t
					    bin/t/script_test_template.t
					    bin/t/ucsc2gff.t
					    bin/t/ucsc_gtf2gff3.t
					    bin/t/variant_classifier.t
					  )],
			 );

$builder->create_build_script();
