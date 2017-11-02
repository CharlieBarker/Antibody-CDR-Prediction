#!/usr/bin/perl

#
use strict;
#first element of argv is the name of xls file  
my $xlsName = shift(@ARGV);
#RUN CYCLESCRIPT
my $var = `./makemodel/cyclescript.pl @ARGV`; 
#RUN EXTRACT RMSD
my $var = `./testmodel/extractRmsd.pl > results/RMSDoutput.txt`;
#RUN CDRH3WRITER
my $var = `./testmodel/cdrh3writer.pl results/RMSDoutput.txt > results/spreadsheets/$xlsName.xls`;


