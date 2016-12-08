#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = '

Synopsis:

flagstat_reporter *.flagstat

Description:

A script to parse and produce reports on the output of samtools
flagstat.  The script is primarily designed to aggregate data on many
flagstat output files into a single report.

Options:

  --report, -r [summary]

    The style of report to produce.  Available reports are:
      * summary: A summary of all flagstat output.

  --format, -f [tab]

    The file format to print the report.  Available formats are:
      * tab: Tab delimited (the default)

  --aggregate, -a \'(^\S+?)_\'

    Aggregate data by sample which are spread out across multiple
    files.  The argument to aggregate can be a perl regular expression
    which captures and returns the portion of the name to aggregate
    on.  The argument can also be a filename, in which case the file
    must have at least two columns per row with the first column
    having the flagstat file names and the second column having an ID
    value on which to aggregate.

';


my ($help, $report, $format, $aggregate);
my $opt_success = GetOptions('help'          => \$help,
			     'report|r=s'    => \$report,
			     'format|f=s'    => \$format,
			     'aggregate|a=s' => \$aggregate,
			    );

die $usage if $help || ! $opt_success;

$report ||= 'summary';
$format ||= 'tab';

$report = lc $report;
$format = lc $format;

my @files = @ARGV;

die $usage unless @files;

my $flagstat = parse_flagstat(@files);

if ($report eq 'summary') {
	build_report_summary($flagstat, $format);
}
else {
	die "FATAL : invalid_report : $report\n";
}

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

sub parse_flagstat {

	my @files = @_;

	my %flagstat;
	for my $file (@files) {
		open (my $IN, '<', $file) or die "FATAL : cant_open_file_for_reading : $file\n";
		my @data = map {/^(\d+)/} (<$IN>);
		close $IN;
		# my $id = map_filename($file);
		my %data;
		# 68483134 + 0 in total (QC-passed reads + QC-failed reads)
		# 28061245 + 0 duplicates
		# 68172818 + 0 mapped (99.55%:-nan%)
		# 68483134 + 0 paired in sequencing
		# 34193331 + 0 read1
		# 34289803 + 0 read2
		# 66556513 + 0 properly paired (97.19%:-nan%)
		# 68002553 + 0 with itself and mate mapped
		# 170265 + 0 singletons (0.25%:-nan%)
		# 1228319 + 0 with mate mapped to a different chr
		# 495708 + 0 with mate mapped to a different chr (mapQ>=5)

		@data{qw(Total Dups Mapped Paired Read1 Read2
			 Prop_Paired Self_Mate_Mapped Single Mate_Map_Chr
			 Mat_Map_Chr_Q5)} = @data;

		$data{Pct_Dups}        = $data{Dups}    	/ $data{Total}  * 100;
		$data{Pct_Mapped}      = $data{Mapped}  	/ $data{Total}  * 100;
		$data{Pct_Prop_Paired} = $data{Pct_Prop_Paired} / $data{Paired} * 100;

		print '';

	}


}

#-----------------------------------------------------------------------------

sub build_report_summary {

	my ($flagstat, $format) = @_;

}

