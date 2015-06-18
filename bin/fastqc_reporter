#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Template;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------

my $usage = "

Synopsis:

fastqc_reporter sample1_fq_fastqc/fastqc_data.txt \
		sample2_fq_fastqc/fastqc_data2.txt

fastqc_reporter sample1.fq_fastqc.zip \
		sample2.fq_fastqc.zip

Description:

The fastqc_reporter script will print text reports and generate
graphical output from the text output of FastQC
(http://www.bioinformatics.babraham.ac.uk/projects/fastqc/).  It is
primarily designed to generate aggregate reports/graphics of multiple
FastQC output files as FastQC already generates very nice reports for
single samples.

Options:

  --report, -r [summary]

    Describes which type of report to generate.  Currently available
    reports are:
	* summary : Generate a summary table of the module status for
	  all FastQC output files.  This is the default report.
	* basic : Generate a table of the basic stats for all FastQC
	  output files.  These include read count, read length, base
	  count, depth, % GC and quality.


  --format, -f [tab]

    Describes the format of the generated report.  Currently available
    formats are:
      * tab: A tab-delimited table. This is the default.
      * text: A pretty-printed formatted text table.
      * html: An HTML formated table.

  --trim_name, -t

    Trim the filenames to remove path and fastqc_data.txt so that we
    have a shorter core name that is likely to still have the relevant
    IDs.

";


my ($help, $report, $format, $TRIM_NAME);
my $opt_success = GetOptions('help'        => \$help,
			     'report|r=s'  => \$report,
			     'format|f=s'  => \$format,
                             'trim_name|t' => \$TRIM_NAME,
			     );

die $usage if $help || ! $opt_success;

$report ||= 'summary';
$format ||= 'tab';

map {$_ = lc $_} ($report, $format);

my @files = @ARGV;

if ($report eq 'basic') {
	build_basic_report($format, \@files);
}
elsif ($report eq 'summary') {
	build_summary_report($format, \@files);
}
else {
	die "FATAL : invalid_report_type : $report\n";
}

#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

sub build_basic_report {

	my ($format, $files) = @_;

	my %data;
	for my $file (@{$files}) {
		my @parts = split m|/|, $file;
		pop @parts if scalar @parts > 1;
		my $path = join '/', @parts;
		$path =~ s/\.zip$//;
		my $name = $parts[-1];
		$data{files}{$file}{path} = $path;
		$data{files}{$file}{name} = $name;
		my $my_data = parse_fastqc($file);
		my %my_basics;

		# read count, read length, base count, depth, % GC and quality.
		$data{files}{$file}{read_count}  = $my_data->{modules}{Basic_Statistics}{Total_Sequences};
		$data{files}{$file}{read_length} = $my_data->{modules}{Basic_Statistics}{Sequence_length};
		$data{files}{$file}{base_count}  = ($my_data->{modules}{Basic_Statistics}{Total_Sequences} *
						    $my_data->{modules}{Basic_Statistics}{Sequence_length});
		$data{files}{$file}{wgs_depth}   = $data{files}{$file}{base_count} / 3_000_000_000;
		$data{files}{$file}{'%GC'}       = $my_data->{modules}{Basic_Statistics}{'%GC'};
	}

	if ($format eq 'tab') {
		print_summary_tab(\%data);
	}
	elsif ($format eq 'text') {
		print_summary_text(\%data);
	}
	elsif
 ($format eq 'html') {
		print_summary_html(\%data);
	}
}

#-----------------------------------------------------------------------------

sub print_basic_tab {

	my ($data) = @_;

	for my $file (sort {$data->{files}{$a} <=> $data->{files}{$b}} keys %{$data->{files}}) {
	  my $this_data = $data->{files}{$file};
	  print join @{$this_data}{qw(name read_count read_length base_count wgs_depth %GC)};
	  print "\n";
	}
}

#-----------------------------------------------------------------------------

sub build_summary_report {

	my ($format, $files) = @_;

	my @modules = qw(Per_base_sequence_quality
			 Per_tile_sequence_quality
			 Per_sequence_quality_scores
			 Per_base_sequence_content
			 Per_sequence_GC_content
			 Per_base_N_content
			 Sequence_Length_Distribution
			 Sequence_Duplication_Levels
			 Overrepresented_sequences
			 Adapter_Content
			 Kmer_Content
		       );

	my %data = (module_list => \@modules);
	for my $file (@{$files}) {
		my @parts = split m|/|, $file;
		pop @parts if scalar @parts > 1;
		my $path = join '/', @parts;
		$path =~ s/\.zip$//;
		my $name = $parts[-1];
		$data{files}{$file}{path} = $path;
		$data{files}{$file}{name} = $name;
		my $my_data = parse_fastqc($file);
		for my $module (keys %{$my_data->{modules}}) {
			my $my_status = $my_data->{modules}{$module}{status};
			$data{files}{$file}{modules}{$module} = $my_status;
			my $this_score = $my_status eq 'fail' ? 3 : $my_status eq 'warn' ? 1 : 0;
			$data{files}{$file}{score} += $this_score;
			$data{modules}{$module}{score} += $this_score;
		}
	}

	if ($format eq 'tab') {
		print_summary_tab(\%data);
	}
	elsif ($format eq 'text') {
		print_summary_text(\%data);
	}
	elsif ($format eq 'html') {
		print_summary_html(\%data);
	}
}

#-----------------------------------------------------------------------------

sub print_summary_tab {

	my ($data) = @_;

	print join "\t", ('File', @{$data->{module_list}}, 'Composite_Score');
	print "\n";

	for my $file (sort {$data->{files}{$b}{score} <=> $data->{files}{$a}{score}} keys %{$data->{files}}) {
		print $data->{files}{$file}{name};
		for my $module (@{$data->{module_list}}) {
			my $this_status = $data->{files}{$file}{modules}{$module};
			print "\t$this_status";
		}
		print "\t" . $data->{files}{$file}{score};
		print "\n";
	}
	print "Module_Score";
	for my $module (@{$data->{module_list}}) {
		print "\t" . $data->{modules}{$module}{score}
	}
	print "\n";
}

#-----------------------------------------------------------------------------

sub print_summary_text {

	my ($data) = @_;

	die ("FATAL : report_format_not_implimented_yet : The summary " .
	     "report is not avaialbe in text format yet - try tab format.\n");

}

#-----------------------------------------------------------------------------

sub print_summary_html {

	my ($data) = @_;

	my $template = <<'END';
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>

    <style>
    table.tablesorter {border-collapse: collapse}
    table.tablesorter { width: 100%; border: 1px solid black}
    table.tablesorter th { width: 10%; border: 1px solid black; background-color: lightgray; text-align: center;}
    table.tablesorter td { width: 10%; border: 1px solid black; text-align: center;}
    table.tablesorter td.pass{ background-color:lightgreen; }
    table.tablesorter td.warn{ background-color:lightyellow; }
    table.tablesorter td.fail{ background-color:salmon; }
    </style>

    <link rel="stylesheet" href="http://topaz.genetics.utah.edu/js/jquery/tablesorter/themes/blue/style.css" type="text/css" media="print, projection, screen" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
    <script src="http://topaz.genetics.utah.edu/js/jquery/tablesorter/jquery.tablesorter.min.js"></script>

    <script>
    $(document).ready(function()
	{
	    $("#myTable").tablesorter();
	}
    );
    </script>

    <title>Aggregate FastQC Report</title>
  </head>
  <body>
    <table id="myTable" class="tablesorter">
      <thead>
      <tr>
	<th>Files</th>
      [%- FOREACH module IN data.module_list %]
	<th>[% module.replace('_', ' ') %]</th>
      [%- END %]
	<th>Composite Score</th>
      </tr>
      </thead>
      <tbody>
      [%- FOREACH file IN data.files.values.sort('name').reverse.nsort('score').reverse %]
      <tr>
	<td><a href="[% file.path %]/fastqc_report.html">[% file.name %]</a></td>
	[%- FOREACH module IN data.module_list %]
	<td class=[% file.modules.$module %]><a href="[% file.path %]/fastqc_report.html#M[% loop.count %]">[% file.modules.$module %]</a></td>
	[%- END %]
	<td>[% file.score %]</td>
      </tr>
	[%- END %]
      </tbody>
    </table>
  </body>
</html>
END
	my $tt = Template->new() || die "$Template::ERROR\n";

	 $tt->process(\$template, {data => $data})
	   || die $tt->error(), "\n";
}

#-----------------------------------------------------------------------------

sub parse_fastqc {

	my $file = shift;

	my $fh = get_file_handle($file);

	my $version_line = <$fh>;
	my ($label, $version) = split /\s+/, $version_line;

	my @lines = <$fh>;
	my $data = join '', @lines;
	my @modules = $data =~ /^(>>.*?>>END_MODULE)/gms;

	my %fqc_data = (fastqc_version => $version);

	my %valid_modules = map {$_ => 1} (qw(
						     Per_base_sequence_quality
						     Per_tile_sequence_quality
						     Per_sequence_quality_scores
						     Per_base_sequence_content
						     Per_sequence_GC_content
						     Per_base_N_content
						     Sequence_Length_Distribution
						     Sequence_Duplication_Levels
						     Overrepresented_sequences
						     Adapter_Content
						     Kmer_Content
					    ));

	for my $module_txt (@modules) {

		my @lines = split /\n/, $module_txt;
		my $module_name_txt = shift @lines;
		my ($module_name, $status) = split /\t/, $module_name_txt;
		$module_name =~ s/^>>//;
		$module_name =~ s/\s+/_/g;
		$fqc_data{modules}{$module_name}{status} = $status;

		if ($module_name eq 'Basic_Statistics') {
			# >>Basic Statistics	pass
			# #Measure	Value
			# Filename	100042-100042_L5_2.fq.gz
			# File type	Conventional base calls
			# Encoding	Sanger / Illumina 1.9
			# Total Sequences	57860176
			# Sequences flagged as poor quality	0
			# Sequence length	151
			# %GC	40
			# >>END_MODULE
		      LINE:
			for my $line (@lines) {
				chomp $line;
				next LINE if $line =~ /^\#/;
				last LINE if $line eq '>>END_MODULE';
				my ($key, $value) = split /\t/, $line;
				$key =~ s/\s+/_/g;
				$fqc_data{modules}{$module_name}{$key} = $value;
			}
		}
		elsif ($valid_modules{$module_name}) {
			my ($headers, $data) = parse_column_data(\@lines);
			$fqc_data{modules}{$module_name}{headers} = $headers;
			$fqc_data{modules}{$module_name}{data}    = $data;
		}
		else {
			die "FATAL : invalid_module_name : $module_name\n";
		}
	}
	return wantarray ? %fqc_data : \%fqc_data;
}

#-----------------------------------------------------------------------------

sub parse_column_data {

	my $lines = shift;
	my $header_txt = shift @{$lines};
	$header_txt =~ s/^\#//;
	my @headers = split /\t/, $header_txt;
	map {s/\s/_/g} @headers;
	my @data;
      LINE:
	for my $line (@{$lines}) {
		next LINE if $line =~ /^\#/;
		last LINE if $line eq '>>END_MODULE';
		my @these_data = split /\t/, $line;
		push @data, \@these_data;
	}
	return (\@headers, \@data);
}

#-----------------------------------------------------------------------------

sub get_file_handle {

	my $file = shift;

	my $FH;

	die("FATAL : missing_file : get_file_handle was called without " .
	    "an file argument\n") unless $file;

	die("FATAL : file_does_not_exist : $file") unless -e $file;

	die("FATAL : file_not_readable : $file")   unless -r $file;

	if ($file =~ /\.zip$/) {
		my $base = $file;
		$base =~ s/\.zip$//;
		open($FH, '-|', "unzip -p $file $base/fastqc_data.txt") or
		  die "FATAL : cant_open_pipe_for_reading : $file\n";
	}
	elsif ($file =~ /\.tar.gz/) {
		my $base = $file;
		$base =~ s/\.tar\.gz$//;
		open($FH, '-|', "tar -xzfO $file $base/fastqc_data.txt") or
		  die "FATAL : cant_open_pipe_for_reading : $file\n";
	}
	elsif ($file =~ /\.gz/) {
		open($FH, '-|', "gunzip -c $file") or
		  die "FATAL : cant_open_pipe_for_reading : $file\n";
	}
	else {
		open($FH, '<', $file) or
		  die "FATAL : cant_open_file_for_reading : $file\n";
	}
	return $FH;
}


__END__

# >>Per base sequence quality     fail
# #Base	Mean	Median	Lower Quartile	Upper Quartile	10th Percentile	90th Percentile
# 1	30.264183002139504	32.0	32.0	32.0	27.0	32.0
# 2	30.27674768911868	32.0	32.0	32.0	27.0	32.0
# 3	33.8113099414008	37.0	32.0	37.0	27.0	37.0
# ...
# >>END_MODULE

# >>Per tile sequence quality	fail
# #Tile	Base	Mean
# 1221	1	0.44900000024897224
# 1221	2	0.37417975849317386
# 1221	3	0.4847128863782757
# 1221	4	0.6124775013553005
# 1221	5	0.6734518179145823
# ...
# >>END_MODULE

# >>Per base sequence content	warn
# #Base	G	A	T	C
# 1	16.675219157801433	32.95855200360647	29.986911421086905	20.3793174175052
# 2	19.589917501579826	33.08908043220466	29.1262756646383	18.194726401577213
# 3	19.408541288380782	31.756611785377785	29.57467430326407	19.260172622977358
# 4	19.7009200248544	30.947085262927647	29.780820231172473	19.571174481045478
# 5	19.8928395931599	31.095365143721647	30.07304886179399	18.93874640132446
# ...
# 140-144	20.959792618678687	31.09148415629525	29.362697005249082	18.58602621977698
# 145-149	21.135535966182275	31.121461069744544	29.330257785698937	18.41274517837424
# 150-151	21.048087290947482	31.47182500747029	29.482376728175513	17.997710973406715
# >>END_MODULE

# >>Per base sequence content     warn
# #GC Content	Count
# 0	1429.0
# 1	1614.5
# 2	2071.0
# 3	2767.5
# 4	3687.5
# 5	4602.0
# ...
# >>END_MODULE

# >>Per sequence GC content    warn
# #GC Content Count
# 0 724.0
# 1 896.5
# 2 1327.0
# 3 1823.5
# 4 2360.5
# ...
# 95 697.5
# 96 617.5
# 97 517.5
# 98 452.5
# 99 480.0
# 1
# >>Per base N content	warn
			# #Base	N-Count
# 1	0.030037931443554544
# 2	0.007188018232091102
# 3	0.0027618305205293534
# 4	0.0
# 5	0.0
# ...
# 140-144	6.7043563780379785
# 145-149	10.578895577503946
# 150-151	11.647595921588625
# >>END_MODULE

# >>Sequence Length Distribution	pass
# #Length	Count
# 151	5.7860176E7
# >>END_MODULE

# >>Sequence Duplication Levels	pass
# #Total Deduplicated Percentage	91.08113934253443
# #Duplication Level	Percentage of deduplicated	Percentage of total
# 1	93.9897689764823	85.60695244919603
# 2	5.18009744672436	9.436183547060164
# 3	0.41626708677302604	1.1374224160225455
# 4	0.10979255320237473	0.4000012334799247
# 5	0.05764519981236591	0.2625195238269169
# 6	0.043465749142055046	0.23753459725410964
# 7	0.02745400912385454	0.17503797013647046
# 8	0.02917196414177297	0.21256125847137933
# 9	0.02135616269976719	0.17506292676113983
# >10	0.11881574409515029	1.889902619804461
# >50	0.00513244013089181	0.3013513429114083
# >100	0.0010253572086583868	0.12631381477634127
# >500	0.0	0.0
# >1k	4.690684717240537E-6	0.016170765580778082
# >5k	2.619778637305946E-6	0.0229855347182882
# >10k+	0.0	0.0
# >>END_MODULE

# >>Overrepresented sequences	pass
# >>END_MODULE

# >>Adapter Content	pass
# #Position	Illumina Universal Adapter	Illumina Small RNA Adapter	Nextera Transposase Sequence
# 1	1.901134901490794E-5	1.7283044559007217E-6	3.4566089118014434E-6
# 2	2.2467957926709384E-5	3.4566089118014434E-6	2.073965347080866E-5
# 3	2.4196262382610105E-5	5.184913367702165E-6	3.4566089118014435E-5
# 4	2.7652871294411547E-5	5.184913367702165E-6	5.357743813292238E-5
# 5	3.629439357391516E-5	6.913217823602887E-6	6.740387378012815E-5
# ...
# 130-131	0.1674070262074557	2.5146829833355504E-4	0.001453504047412507
# 132-133	0.17496317328865368	2.5319660278945574E-4	0.0014777003097951173
# 134-135	0.1827249886001038	2.5751736392920754E-4	0.0014958475065820747
# 136-137	0.1910692425131925	2.6356642952486003E-4	0.0015165871600528835
# 138-139	0.1998308819523812	2.678871906646119E-4	0.0015399192702075432
# >>END_MODULE

# >>Kmer Content	fail
# #Sequence	Count	PValue	Obs/Exp Max	Max Obs/Exp Position
# TCCGATC	4675	0.0	12.702508	3
# CCGATCT	6225	0.0	9.539354	4
# AGCGTCG	15870	0.0	9.14664	9
# TTCCGAT	7430	0.0	8.614466	2
# GAGCGTC	20235	0.0	7.2387834	8
# CTTCCGA	8655	0.0	6.7868094	1
# ATCGGAA	24565	0.0	6.233241	1
# AGAGCGT	25400	0.0	6.026568	7
# TCGGAAG	25340	0.0	5.937091	2
# CGCCGTA	5465	0.0	5.3444567	55-59
# CGGAAGA	29210	0.0	5.105114	3
# >>END_MODULE
