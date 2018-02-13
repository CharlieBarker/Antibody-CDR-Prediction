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
	my @pdbLoop = split (/\s+/, $entries[0])
	my $pdbName = $pdbLoop[0];	#antibody pdb name
	my $loopName = $pdbLoop[1];	#top loop template name 
	my $pdbSeq = $entries[2];	#antibody sequence 
	my $loopSeq = $entries[3];	#top loop template sequence
	  
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


}
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

