#!/usr/bin/perl

#*************************************************************************
#
#   Program:    machinelearningprep
#   File:       findtemplateused.pl  
#   Date:       05.02.2018
#   Function:   gets amino acid sequence of loops  
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	perl loopproperties.pl
#   Inputs: 	STDERR file of job
#   Outputs:	txt file with .pdb name followed by top template.
#               
#*************************************************************************

use strict;
use util;

#STDERR path
my $stderrPath = "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding/results/abyModSTDERR"; 
# the file name to be used 
my $file = "nLoops10.txt";

#open STDERR file 
my $stderrFile = "$stderrPath/$file";
open(DATA, "<$stderrFile"); 
if(!open(DATA, "<$stderrFile"))
{
	print STDERR "Error: unable to open file $stderrFile\n";
       	exit 1;
}

#declare variable 
my @loops;
my @names;
my $spliceLoop;
my $count;
#cycle through lines in the STDERR file (output from iterativeanalysis.pl)
while(my $line = <DATA>) {
	#search for file name to get the name of model
	if ($line =~ /FILE NAME: /){
		$line = substr $line, 11, 5;		
		push @names, $line;
	}
	#get lines containing into CDR H3 of to find all the templates used for H3
	if ($line =~ / into CDR H3 of /) {
        	$spliceLoop = $line;
		my @entries = split(/ into CDR H3 of /, $spliceLoop);
		$spliceLoop = @entries[0];
		@entries = split(/PDB/, $spliceLoop);
		$spliceLoop = @entries[1];
		$spliceLoop = substr $spliceLoop, 1;
		
        } 
	#only "bank" (keep) the last such template used for this model (truncating 
	# structure means abymod has finished)
	if ($line =~ /Truncating structure...done/) {
		#keep this loop name in the array loops 
        	push @loops, $spliceLoop; 
		$count++;
        } 
}
my $no = @loops;
my $noNames = @names;
#put the pdb files and the loop name of the template used for CDRH3 together
for(my $i=0; $i<$no; $i++)
{
	my $name = $names[$i];
	my $loop = $loops[$i];
	print "$name.pdb " . "$loop\n";
}


#my @out = util::PdbToSeq($loop, $path);
#print "@out";


