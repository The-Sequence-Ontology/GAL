#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------

my $usage = "

This script will take one or more datafiles and build a histogram of
one or more columns of data from each file.  The options described
below allow control of the binning, input and output.  Items sort into
bins if they are greater then the bin's lower bound and less than or
equal to the bin's upper bound.

histogram [options] datafile1 [datafile2 datafile3...]

Options:

    --col n
      Which column of the input data should we use?  You can also pass
      a list of column numbers and all of those columns will be porcessed
      in the same manner i.e. (1 3 7 10) - output will include histograms
      of columns 1, 3, 7 and 10 all with the same binning.

    --bin_auto [n]
      Automatically makes n bins divided evenly over the data range.  The
      value of n defaults to 10 and if no bin options are given, then this
      option is the default.

    --bin_range 'min max step'
      Builds bins begining at min, continuing to max by step.

    --bin_range_log 'min max step base'
      Builds bins begining at min, continuing to max by step where the base
      is raised to the power of step.

    --bin_file filename
      Build bins based on the data given in a file.  Each value in the first
      column of the file becomes a bin.

   --find filename
     Use the linux command 'find' to search for all files of a given name below
     the current working directory and then add these files to any passed on the
     command line.

  --accuracy
     Determines the accuracy at which to compare floating point numbers.  Integers
     are converted to floating point.  Default is 6 digits after the decimal place.

  --graph
     Print a ASCII graph of the histogram.

";

my $bin_auto = 10;

my ($bin_range, $bin_range_log, $bin_file, $col_string, $find,
    $accuracy, $graph);

my $opt_results = GetOptions('bin_auto=i'      => \$bin_auto,
			     'bin_range=s'     => \$bin_range,
			     'bin_range_log=s' => \$bin_range_log,
			     'bin_file=s'      => \$bin_file,
			     'col=s'           => \$col_string,
			     'find=s'          => \$find,
			     'accuracy=i'      => \$accuracy,
			     'graph'           => \$graph,
			     );

#Split column values from the argument
my @cols;
@cols = split /[\s,;-_]+/, $col_string if $col_string;
#Map them to 0 based array indexes
@cols = map{$_ - 1} @cols if @cols;
#If no columns given use the last (-1) column.
push @cols, -1 if scalar @cols < 1;

my @files = @ARGV;
my @find_files;
@find_files = `find ./ -name $find` if $find;
#This allows files to come both from the command line and from the --find
#argument
push @files, @find_files;
chomp @files;
push @files, '-' if  ! @files;

$accuracy ||= 6;

die $usage unless $opt_results && @files;
die "Can't specify multiple files and multiple columns at the same time\n"
    if (scalar @files > 1 and scalar @cols > 1);

my ($data, $data_min, $data_max) = parse_data(@files);
my $bin = build_bin($data_min, $data_max, $bin_auto, $bin_range, $bin_file);
my $histogram = build_histogram($bin, $data, @files);

if ($graph) {
    print_graph($histogram, $bin_range);
}
else {
    print_histogram($histogram);
}

exit 0;

#-----------------------------------------------------------------------------
#----------------------------------- SUBS ------------------------------------
#-----------------------------------------------------------------------------
sub parse_data {
	my @files = @_;
	my @data;
	my ($min, $max);

	my $index = 0;
	for my $file (@files) {
		my $IN;
		if (! -t STDIN) {
			open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
		}
		else {
			open ($IN, '<', $file) or die "Can't open $file for reading:\n$!\n";
		}
		#This looks like it would allow evaluation of multiple columns
		#from multiple files, but that is prevented at the begining of
		#the script with a die.
	      COL:
		for my $col (@cols) {
		  LINE:
		    while (<$IN>) {
			my @line_data = split;
			my $datum;
			$datum = $line_data[$col];
			next unless $datum =~ /-?\d*\.?\d+/;
			push @{$data[$index]}, $datum;
			$min ||= $datum;
			$max ||= $datum;
			$min = $datum if $datum < $min;
			$max = $datum if $datum > $max;
		    }
		    #Reposition the file pointer to the start of the file
		    seek($IN, 0, 0);
		    $index++ if scalar @cols > 1;
		}
		$index++;
	}
	return (\@data, $min, $max);
}
#-----------------------------------------------------------------------------
sub build_bin {
	my ($data_min, $data_max, $bin_auto, $bin_range, $bin_file) = @_;

	my @bin;
	my $step;
	if ($bin_file) {
		open (my $BIN, '<', $bin_file) or die "Can't open $bin_file for reading:\n$!\n";
		while (<$BIN>) {
			my @line_data = split;
			my $datum = shift @line_data;
			push @bin, $datum;
		}
		push @bin, $data_max if $bin[-1] < $data_max;
		my @steps;
		my $previous = $bin[0];
		for my $i (1 .. $#bin) {
		    push @steps, $previous - $bin[$i];
		    $previous = $bin[$i];
		}
		my $step_sum;
		map {$step_sum += $_} @steps;
		$step = $step_sum / scalar @steps;
	}
	elsif ($bin_range) {
	    my ($bin_min, $bin_max);
		($bin_min, $bin_max, $step) = split'\s+', $bin_range;
		unless (defined $bin_min  &&
			defined $bin_max  &&
			defined $step &&
			$bin_min < $bin_max &&
			$step < ($bin_max - $bin_min)) {
			die "Incorrect min, max, or step defined with " .
			    "--bin-range option ($bin_range)\n";
		}
		my $i;
		for ($i = $bin_min; $i <= $bin_max; $i += $step) {
			push @bin, $i;
		}
		push @bin, $data_max if float_lt($bin[-1], $data_max, $accuracy);
	}
	elsif($bin_range_log) {
	    my ($bin_min, $bin_max, $base);
		($bin_min, $bin_max, $step, $base) = split '\s+', $bin_range_log;
		unless (defined $bin_min  &&
			defined $bin_max  &&
			defined $step &&
			defined $base &&
			$bin_min < $bin_max &&
			$step < ($bin_max - $bin_min)) {
			die "Incorrect min, max, step, or base defined with " .
			    "--bin-range_log option ($bin_range)\n";
		}
		my $i;
		for ($i = $bin_min; $i <= $bin_max; $i += $step) {
			push @bin, $base ** $i;
		}
		push @bin, $data_max if $bin[-1] < $data_max;
	}
	else {
		my $i;
		$step = ($data_max - $data_min) / $bin_auto;
		for ($i = $data_min; $i < $data_max; $i += $step) {
			push @bin, $i;
		}
		$bin_range = "$data_min $data_max $step";
	}

	my $step_sd = $step;
	$step_sd = $step_sd =~ /\./ ? $step_sd : $step_sd . '.';
	$step_sd =~ s/.*\.//;
	$step_sd = length($step_sd);
	
	map {$_ = sprintf "%.${step_sd}f", $_} @bin;
	
	return \@bin;
}
#-----------------------------------------------------------------------------
sub build_histogram {
	my ($bin, $data, @files) = @_;
	my $bin_count = @$bin;
	my $column_count = scalar @$data;

	#Initialize histogram array;
	my @histogram;

	unshift @files, 'Bin';

	my $x_index = 0;
	for my $column ( @$data) {
		for my $datum (@$column) {
			my $y_index = 0;
		      BIN:
			for my $this_bin (@$bin) {
				$histogram[$y_index][$x_index] ||= 0;
				if (float_le($datum, $this_bin, $accuracy)) {
					$histogram[$y_index][$x_index]++;
					last BIN;
				}
				$y_index++;
			}
			print '';
		}
		$x_index++;
	}

	my $y_index = 0;
	for my $row (@histogram) {
		unshift @$row, $$bin[$y_index++];
	}
	unshift @histogram, \@files;

	return \@histogram;
}

#-----------------------------------------------------------------------------

sub print_histogram {
	my $histogram = shift;

	for my $row (@$histogram) {
		print join "\t", @$row;
		print "\n";
	}
}

#-----------------------------------------------------------------------------

sub print_graph {
	my ($histogram, $bin_range) = @_;

	my ($bin_min, $bin_max, $step);
	if ($bin_range) {
	    ($bin_min, $bin_max, $step) = split'\s+', $bin_range;
	}
	else {
	    $bin_min = $data_min;
	    $bin_max = $data_max;
	    $step = ($data_max - $data_min) / $bin_auto;
	}

	my $max = 0;
	for my $row (@{$histogram}) {
	    my ($bin, $count) = @{$row};
	    next if $bin eq 'Bin';
	    next if $bin > $bin_max;
	    my $length = $row->[1];
	    $max = $length > $max ? $length : $max;
	}
	$max++;

      ROW:
	for my $row (@{$histogram}) {
	    my ($bin, $count) = @{$row};
	    if ($bin eq 'Bin') {
		print "$bin\t$count\n";
		next ROW;
	    }

	    my $width = 80;
	    my $points = int($count / $max * $width); # - length($count);
	    my $bar;
	    if ($points >= $width) {
		$points = $width - 1;
		$bar = '=' x $points;
		$bar .= '+';
		$bar .= ' ' x ($width + 9 - $points - length($count) - 1);
	    }
	    else {
		$bar = '=' x $points;
		$bar .= ' ' x ($width + 10 - $points - length($count) - 1);
	    }
	    $bar .= " $count";
	    print "$bin\t$bar\n";
	}
}

#-----------------------------------------------------------------------------

sub float_lt {
	my ($A, $B, $accuracy) = @_;

        $A = sprintf("%.${accuracy}f", $A);
        $B = sprintf("%.${accuracy}f", $B);
        $A =~ s/\.//;
        $B =~ s/\.//;
        return $A < $B;
}

#-----------------------------------------------------------------------------

sub float_le {
	my ($A, $B, $accuracy) = @_;

        $A = sprintf("%.${accuracy}f", $A);
        $B = sprintf("%.${accuracy}f", $B);
        $A =~ s/\.//;
        $B =~ s/\.//;
        return $A <= $B;

}
