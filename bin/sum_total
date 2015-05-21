#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "

Synopsis:

cat numbers.txt | sum_total

Options:

  --round, -r

    Round final sum.


Description:

No really, how the hell do you use this thing!

";

my ($help, $round);
my $opt_success = GetOptions('help'      => \$help,
			     'round|r=i' => \$round,
			           );

die $usage if $help || ! $opt_success;

my $sum;
while (<STDIN>) {
    $sum += $_;
}

$sum =  sprintf("%.${round}f", $sum) if defined $round;
print "$sum\n";


#-----------------------------------------------------------------------------
#-------------------------------- SUBROUTINES --------------------------------
#-----------------------------------------------------------------------------

