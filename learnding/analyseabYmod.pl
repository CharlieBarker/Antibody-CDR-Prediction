#!/usr/bin/perl

use strict; 
my $xlsName = shift(@ARGV);
my $var = `./makemodel/cyclescript.pl @ARGV`; 
my $var = `./testmodel/extractRmsd.pl > results/RMSDoutput.txt`;
my $var = `./testmodel/cdrh3writer.pl results/RMSDoutput.txt > results/$xlsName.xls`;


