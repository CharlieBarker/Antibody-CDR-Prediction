#!/usr/bin/perl

#*************************************************************************
#
#   Program:    analyseabYmod
#   File:       timeextract.pl
#   Date:       03.10.17
#   Function:   Gets the real time measurements from a run of abymod. 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	perl timeextract.pl [name of tmp time dir]
#		
#   Inputs: 	Name of tmp time dir. 
#   Outputs:	File containing times of both succesful and nonsuccesful abymod runs. 
#		(planned R script to isolate succesful times.)
#		        
#*************************************************************************

use config;
use strict;
my $timeDir = shift(@ARGV);
my @files = <$timeDir/*>;
my @values; 
foreach my $file (@files) {
	my $tail =`tail -n3 $file`;
	my @entries = split(/\n+/, $tail);
	my $real = $entries[0];
	my $time  = substr $real, 5, 9;
	$file = substr $file, 29, 5;
	print "$file $time\n"
}

