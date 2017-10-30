#!/usr/bin/perl

use strict; 
my $xlsName = shift(@ARGV);
#my $var = `./makemodel/cyclescript.pl @ARGV`;

print STDERR "SELECTING TEMPLATES...\n" if($::v >= 1);
my $var = `./testmodel/extractRmsd.pl > results/RMSDoutput.txt`;
print STDERR "Running: $var\n" if($::v >= 5);
system($var);

my $var = `./testmodel/cdrh3writer.pl results/RMSDoutput.txt > results/lol.xls`;


