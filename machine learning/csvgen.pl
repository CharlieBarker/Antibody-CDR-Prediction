#!/usr/bin/perl

#*************************************************************************
#
#   Program:    machinelearningprep
#   File:       csvgen.pl  
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
use config;

#STDERR path
my $stderrPath = "$config::abYmodSTDERR"; 
# the file name to be used 
my $file = "nLoops10.txt";

#STDERR file 
my $stderrFile = "$stderrPath/$file";
#template file 
my $templateFile = "$config::templateFile";
open(DATA, "<$templateFile"); 
if(!open(DATA, "<$templateFile"))
{
	print STDERR "Error: unable to open file $templateFile\n";
       	exit 1;
}
while(my $line = <DATA>) {
	my @entries = split(/#/, $line);
	my @pdbLoop = split (/\s+/, $entries[0]);
	my $pdbName = $pdbLoop[0];	#antibody pdb name
	my $loopName = $pdbLoop[1];	#top loop template name 
	my $pdbSeq = $entries[2];	#antibody sequence 
	my $loopSeq = $entries[3];	#top loop template sequence
	#my $energy = extractenergy($pdbName, $loopName); #find energy
	#print STDERR "$pdbName .. $energy\n"; 
	my $length = extractlength($pdbSeq, $loopSeq, $pdbName);
	print "$pdbName $length\n";
	#print STDERR "$pdbName .. $pdbSeq\n"; 
	

	  
}

#*************************************************************************
#> extractenergy($pdbName, $loopName)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbName	Scalar containing antibody pdbname 
#					in the standard	PDB format
#	     \scalar	$loopName	Scalar containing the name of the 
#					top template loop		
# 						
#  returns scalar of the energy of the top template value
#
#  13.02.2018 by C.G.B.

sub extractenergy
{
	my($pdbName, $loopName) = @_;
	#STDERR path
	my $stderrPath = "$config::abYmodSTDERR"; 
	# the file name to be used 
	my $file = "nLoops10.txt";
	#open STDERR file 
	my $stderrFile = "$stderrPath/$file";
	open(FILE, "<$stderrFile"); 
	if(!open(FILE, "<$stderrFile"))
	{
		print STDERR "Error: unable to open file $stderrFile\n";
	       	exit 1;
	}
	my $pdbPredName = substr $pdbName, 0, 5;
	$pdbPredName = "$pdbPredName" . "PRED.pdb";
	my $count = 0;  
	my $energy; 
	while(my $line = <FILE>) {
		#search for file name to get the name of model
		if ($line =~ /FILE NAME: $pdbPredName/){
			$count = 1; 
		}
		if ($count ==1 and $line =~ /^\s*$loopName/){
			my @entries = split(/\s/, $line);
			$energy = $entries[1];
		} 
		if ($line =~ /Truncating structure...done/){
			$count = 0;
			
		}
	}
	return $energy;
}
#*************************************************************************
#> extractlength($pdb)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbSeq		Scalar containing antibody one letter 
#					amino acid code.
#	     \scalar	$loopSeq	Scalar containing loop one letter 
#					amino acid code. 
#	     \scalar	$pdbName 	Scalar containing antibody pdbname 
#					in the standard	PDB format.	
# 						
#
#  returns length and an warning if these two values aren't identical 
#
#  14.02.2018 by C.G.B.

sub extractlength
{
	my($pdbSeq, $loopSeq, $pdbName) = @_;

	#LOOP
	my @entriesSeq = split(/\s/, $loopSeq);
	@entriesSeq = grep /\S/, @entriesSeq; #remove empty strings in array 
	my $lengthSeq = @entriesSeq; #length plus framework
	$lengthSeq = $lengthSeq-6; #length minus framework 
	my $length = $lengthSeq;




	#ANTIBODY 
	my @entriesPdb = split(/\s/, $pdbSeq);
	@entriesPdb = grep /\S/, @entriesPdb; #remove empty strings in array 
	my $lengthPdb = @entriesPdb; #length plus framework
	$lengthPdb = $lengthPdb-6; #length minus framework 
	if ($lengthSeq != $lengthPdb){
		print STDERR "WARNING: Loop does not match CDRH3 for $pdbName\n";
	}

 	return $length; 
	
}

#*************************************************************************
#> CDRH3seq($pdb)
#  ----------------------------------------------
#  Inputs:   \scalar  $pdbSeq	Scalar containing antibody pdbname in the standard
#				PDB format
# 						
#
#  returns array of amino acid one letter sequence including the 3 residue shoulder 
#  sequence each side
#
#  06.02.2018 by C.G.B.

#*************************************************************************
#> CDRH3seq($pdb)
#  ----------------------------------------------
#  Inputs:   \scalar  $pdb	Scalar containing antibody pdbname in the standard
#				PDB format
# 						
#
#  returns array of amino acid one letter sequence including the 3 residue shoulder 
#  sequence each side
#
#  06.02.2018 by C.G.B.

