#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

random_list file.txt
cat file.txt | random_list
random_list --permute 1000 --pick 11 file.txt | histogram


Description:

This script will take a text file as input and print out the file in
random order.  It uses the Fisher-Yates Shuffle to randomize the list.
With the options described below you can pick a given number of values
from the list and print just those, and you can permute the shuffle
pick sequence a given number of times.

Options:

  --permute, -m 1

    Lists are randomized by a Fisher-Yates shuffle.  The permute
    option describes how many rounds of shuffling are done.  The
    default is 1 which is sufficient for most purposes.

  --pick, -p 100

    Provide an integer value to --print and the script will print only
    that given number of values from the top of the shuffled list.
    Default is to print the entire shuffled list.

  --prob_emit, -e 1e-3

    Emit lines with the given probability.  For example if you supply
    a value of 1e-3 each line will have a 1/1000 chance of being
    printed and thus over a large number of lines you should print
    about 1 line for every 1000 lines.

";

my ($help, $permute, $pick, $prob_emit);
my $opt_success = GetOptions('help'          => \$help,
			     'permute=i'     => \$permute,
			     'pick=i'        => \$pick,
			     'prob_emit|e=s' => \$prob_emit,
			      );

die $usage if $help || ! $opt_success;

my $file = shift;
die $usage unless $file || ! -t;

$permute ||= 1;

my $IN;
if (! -t STDIN) {
	open ($IN, "<&=STDIN") or die "Can't open STDIN\n";
}
else {
	open ($IN, '<', $file) or die "Can't open $file for reading:\n$!\n";
}

if ($prob_emit) {
    print_prob_emit($IN, $prob_emit);
}
else {
    shuffle($IN, $permute, $pick)
}

exit(0);

#-----------------------------------------------------------------------------
#----------------------------------- SUBS ------------------------------------
#-----------------------------------------------------------------------------

sub shuffle {

    my ($IN, $permute, $pick) = @_;

    my @list = <$IN>;
    chomp @list;

    $pick ||= scalar @list;
    $pick = $pick > scalar @list ? scalar @list : $pick;
    
    for (1 .. $permute) {
	#Fisher-Yates Shuffle
	my $n = scalar @list;
	while ($n > 1) {
	    
	    my $k = int rand($n--);
	    ($list[$n], $list[$k]) = ($list[$k], $list[$n]);
	}
	
	print join "\n", @list[0 .. $pick - 1];
	print "\n";
    }
}

#-----------------------------------------------------------------------------

sub print_prob_emit {

    my ($IN, $prob_emit) = @_;

    $prob_emit =1 if $prob_emit > 1;
    my $rand_max = int(1/$prob_emit);

    while (<$IN>) {
	print if int(rand($rand_max)) == ($rand_max - 1);
    }
}

#-----------------------------------------------------------------------------
