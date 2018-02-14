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
	my $seqID = extractseqID($pdbSeq, $loopSeq, $pdbName);
	

	  
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
#> extractlength($pdbSeq, $loopSeq, $pdbName)
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
#> extractseqID($pdbSeq, $loopSeq, $pdbName)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbSeq		Scalar containing antibody one letter 
#					amino acid code.
#	     \scalar	$loopSeq	Scalar containing loop one letter 
#					amino acid code. 
#	     \scalar	$pdbName 	Scalar containing antibody pdbname 
#					in the standard	PDB format.	
# 						
#
#  Returns basic sequence identity of two sequences. 
#
#  14.02.2018 by C.G.B.

sub extractseqID
{
	my($pdbSeq, $loopSeq, $pdbName) = @_;	
	my @residuesPdb = split(/\s/, $pdbSeq);	#split arrays by whitespace
	my @entriesLoop = split(/\s/, $loopSeq);
	@residuesPdb = grep /\S/, @residuesPdb; #remove empty strings in array
	@entriesLoop = grep /\S/, @entriesLoop; #remove empty strings in array
	my $noPdb = @residuesPdb;	#get numbers to double check they are the same 
	my $noLoop = @entriesLoop;
	#define various variables	
	my $bool;	 
	my @bools;
	my @match;
	#loop through the variables, checking whether they are the same 
	if($noPdb == $noLoop){		
		for(my $i=0; $i<$noPdb; $i++) {
			if($residuesPdb[$i] eq $entriesLoop[$i]){
				$bool = 1;
				push @match, $bool; 
			}
			else {
				$bool = 0; 
			}
			push @bools, $bool; 
		}
	}
	#if the loop seq and the pdb seq are different then print a warning 
	else {			
		print STDERR "SeqID WARNING: Sequences do no match for $pdbName\n"
	}
	#calculate percentage and round. 
	my $total = @bools;
	my $matching = @match;
	my $seqID = $matching/$total;
	$seqID = $seqID*100; 
	$seqID = util::round($seqID);
	
	return $seqID;

}

#*************************************************************************
#> extracthydrophobicity($pdbSeq, $loopSeq)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbSeq		Scalar containing antibody one letter 
#					amino acid code.
#	     \scalar	$loopSeq	Scalar containing loop one letter 
#					amino acid code. 
# 						
#
#  returns the difference in average hydrophobicity index between the top 
#  template (loop) and the model (pdb)
#
#  06.02.2018 by C.G.B.

#*************************************************************************
#> extractcharge($pdbSeq, $loopSeq)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbSeq		Scalar containing antibody one letter 
#					amino acid code.
#	     \scalar	$loopSeq	Scalar containing loop one letter 
#					amino acid code. 
# 						
#
#  returns the difference in average charge between the top template 
#  (loop) and the actual sequence (pdb). 
#
#  06.02.2018 by C.G.B.

#*************************************************************************
#> checkforcysteine($pdbSeq, $loopSeq)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbSeq		Scalar containing antibody one letter 
#					amino acid code.
#	     \scalar	$loopSeq	Scalar containing loop one letter 
#					amino acid code. 
# 						
#
#  returns a statement checking whether the conserved H92 residue is the 
#  between the template and the real sequence. 
#
#  06.02.2018 by C.G.B.

#*************************************************************************
#> belowthreshold($pdbName)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbName	Scalar containing antibody pdbname in 
#					the standard PDB format.
# 						
#
#  returns true or false depending on whether or not the RMSD of this protein
#  is below the threshold set in ARGV. 
#
#  06.02.2018 by C.G.B.

