#!/usr/bin/perl

#*************************************************************************
#
#   Program:    machinelearningprep
#   File:       csvgen.pl  
#   Date:       05.02.2018
#   Function:   gets amino acid sequence of loops and then extracts properties 
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
my $file = "$config::dataSource.txt";

#get threshold and tmpfile name
my $tmpDir = shift(@ARGV);
my $threshold = shift(@ARGV);

#STDERR file 
my $stderrFile = "$stderrPath/$file";
#template file 
my $templateFile = "$tmpDir/$config::templateName";
#get blosum or dayhoff matrices for sequence similarity calculations. 
my %mdm = util::ReadMDM($config::matrix);
if(!defined($mdm{'A'}{'A'}))
{
    print STDERR "Error: Cannot read mutation matrix file\n   $config::MDMFile\n";
    exit 1;
}
open(DATA, "<$templateFile"); 
if(!open(DATA, "<$templateFile"))
{
	print STDERR "Error: unable to open file $templateFile\n";
       	exit 1;
}
print "NAME,ENERGY,LENGTH,LOOPSeqID,FRAMEWORKSeqID,FRAMEWORKSeqSIMILARITY,LOOPSeqSIMILARITY,HYDROPHOBICITYINDEXDIFFERENCE,CHARGEDIFFERENCE,GOODORBAD\n";
while(my $line = <DATA>) {
	my @entries = split(/#/, $line);
	my @pdbLoop = split (/\s+/, $entries[0]);
	my $pdbName = $pdbLoop[0];	#antibody pdb name
	my $loopName = $pdbLoop[1];	#top loop template name 
	my $pdbSeq = $entries[2];	#antibody sequence 
	my $loopSeq = $entries[3];	#top loop template sequence
	print STDERR "extracting data for $pdbName\r";
	#extract energy 
	my $energy = extractenergy($pdbName, $loopName);
	#get length
	my $length = extractlength($pdbSeq, $loopSeq, $pdbName);
	#get sequence identity for loop and framework seperatley 
	my($loopSID, $frameSID) = extractseqID($pdbSeq, $loopSeq, $pdbName);
	#get sequence similarity for loop and framework 
	my ($similarityFrame, $similarityLoop) = extractseqsim($pdbSeq, $loopSeq, $pdbName, %mdm); 
	#get the average difference in hydorpobicity index per residue 
	my $hydrophobicity = extracthydrophobicity($pdbSeq, $loopSeq); 
	#get the average charge difference per residue 
	my $charge = extractcharge($pdbSeq, $loopSeq); 
	#get whether the model is below the threshold in RMSD
	my $threshBool = belowthreshold($pdbName, $threshold); 
	print "$pdbName,$energy,$length,$loopSID,$frameSID,$similarityFrame,$similarityLoop,$hydrophobicity,$charge,$threshBool\n";
	

	  
}
print STDERR "\n";


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
	my $file = "$config::dataSource.txt";
	#open STDERR file 
	my $stderrFile = "$stderrPath/$file";
	open(FILE, "<$stderrFile"); 
	if(!open(FILE, "<$stderrFile"))
	{
		print STDERR "csvgen Error: unable to open file $stderrFile\n";
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
		print STDERR "csvgen WARNING: Loop does not match CDRH3 for $pdbName\n";
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
#					in the standard	PDB format. This is for the warning 
# 						
#
#  Returns basic sequence identity of two sequences split between framework and the loop itself. 
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
	#find length of loop (minus 6 because of the included 3 residue of framework either side of the loop)
	my $lengthOfLoop = $noLoop - 6;
	#define various variables	
	my $bool;	 
	my @bools;
	my @match;
	#loop through the variables, checking whether they are the same 
	if($noPdb == $noLoop){		
		for(my $i=0; $i<$noPdb; $i++) {
			if($residuesPdb[$i] eq $entriesLoop[$i]){
				$bool = 1;
			}
			else {
				$bool = 0; 
			}
			push @bools, $bool; 
		}
	}
	#if the loop seq and the pdb seq are different then print a warning 
	else {			
		print STDERR "csvgen SeqID WARNING: Sequences do no match for $pdbName\n"
	}
	#get data for framework and loops seperately 
	my @loop = splice @bools, 3, $lengthOfLoop;
	my @framework = @bools;
	my $totalLoop;
	my $countLoop; 
	foreach my $ele (@loop){
		if($ele == 1){
			$countLoop++;
		}
		$totalLoop++; 
	}
	my $loopSID = $countLoop/$totalLoop;
	my $totalFrame;
	my $countFrame; 
	foreach my $ele (@framework){
		if($ele == 1){
			$countFrame++;
		}
		$totalFrame++; 
	}
	my $frameSID = $countFrame/$totalFrame;
	

	return ($loopSID, $frameSID);
}
#*************************************************************************
#> extractseqsim($pdbSeq, $loopSeq, $pdbName, %mdm)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbSeq		Scalar containing antibody one letter 
#					amino acid code.
#	     \scalar	$loopSeq	Scalar containing loop one letter 
#					amino acid code. 
#	     \scalar	$pdbName 	Scalar containing antibody pdbname 
#					in the standard	PDB format. This is for the warning 
# 						
#
#  Returns basic sequence similarity of two sequences split between framework and the loop itself. 
#
#  14.02.2018 by C.G.B.
sub extractseqsim
{		
	my($pdbSeq, $loopSeq, $pdbName, %mdm) = @_;	
	my @residuesPdb = split(/\s/, $pdbSeq);	#split arrays by whitespace
	my @entriesLoop = split(/\s/, $loopSeq);
	@residuesPdb = grep /\S/, @residuesPdb; #remove empty strings in array
	@entriesLoop = grep /\S/, @entriesLoop; #remove empty strings in array
	my $noPdb = @residuesPdb;	#get numbers to double check they are the same 
	my $noLoop = @entriesLoop;
	#find length of loop (minus 6 because of the included 3 residue of framework either side of the loop)
	my $lengthOfLoop = $noLoop - 6;
	# Initialize scores
	my @targetTarget;
	my @targetTemplate;
	my $targetTargetScore   = 0.0;
	my $targetTemplateScore = 0.0;
	if($noPdb == $noLoop){		
		for(my $i=0; $i<$noPdb; $i++) {
                	# Calculate similarity score
			my $res = $residuesPdb[$i];
			my $tplRes = $entriesLoop[$i]; 
                	push @targetTarget, $mdm{$res}{$res};
                	push @targetTemplate, $mdm{$res}{$tplRes};			
		}
	}
	#if the loop seq and the pdb seq are different then print a warning 
	else {			
		print STDERR "csvgen SeqSIM WARNING: Sequences do no match for $pdbName\n"
	}
	#split into sections of loop and framework
	my @loopTrgtTrgt = splice @targetTarget, 3, $lengthOfLoop;
	my @frameworkTrgtTrgt = @targetTarget;
	my @loopTrgtTmpl = splice @targetTemplate, 3, $lengthOfLoop;
	my @frameworkTrgtTmpl = @targetTemplate;
	my $totalFrmwrkTrgtTmpl = util::addarray(@frameworkTrgtTmpl);
	my $totalLoopTrgtTmpl = util::addarray(@loopTrgtTmpl);
	my $totalFrmwrkTrgtTrgt = util::addarray(@frameworkTrgtTrgt);
	my $totalLoopTrgtTrgt = util::addarray(@loopTrgtTrgt);
	my $similarityFrame = $totalFrmwrkTrgtTmpl/$totalFrmwrkTrgtTrgt;
	my $similarityLoop = $totalLoopTrgtTmpl/$totalLoopTrgtTrgt;

	return ($similarityFrame, $similarityLoop);
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
#  19.02.2018 by C.G.B.

sub extracthydrophobicity
{
	my ($pdbSeq, $loopSeq) = @_;
	my @residuesPdb = split(/\s/, $pdbSeq);	#split arrays by whitespace
	my @entriesLoop = split(/\s/, $loopSeq); 
	#set count for difference totals to zero. 
	my $diffCount = 0;
	#get length 
	my $length = @residuesPdb;
	#for each residue 
	for(my $i=0; $i<$length; $i++) {
		#get hydrophobicity for real loop value from hash in util.pm
		my $hydrophobicityPdb = $util::hydrophobicscale{$residuesPdb[$i]};
		#get hydrophobicity for template loop value from hash in util.pm
		my $hydrophobicityLoop = $util::hydrophobicscale{$entriesLoop[$i]};
		#get difference 
		my $diffHydrophobicity = $hydrophobicityPdb - $hydrophobicityLoop; 
		#get modulus of this 
		my $diffHydrophobicity = util::modulus($diffHydrophobicity);
		#add this to the previous iteration 
		$diffCount = $diffCount + $diffHydrophobicity;  
	}
	my $averageLoop = $diffCount/$length;  
	#round numbers using subroutine in util. 
	my $difference = util::round($averageLoop); 

	return $difference; 
}

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
#  19.02.2018 by C.G.B.

sub extractcharge
{
	my ($pdbSeq, $loopSeq) = @_;
	my @residuesPdb = split(/\s/, $pdbSeq);	#split arrays by whitespace
	my @entriesLoop = split(/\s/, $loopSeq); 
	#set count for difference totals to zero. 
	my $diffCount = 0;
	#get length 
	my $length = @residuesPdb;
	#for each residue 
	for(my $i=0; $i<$length; $i++) {
		#get charge from hash in utilities module 
		my $chargePdb = $util::charge{$residuesPdb[$i]};
		my $chargeLoop = $util::charge{$entriesLoop[$i]};
		#get difference 
		my $diffCharge= $chargePdb - $chargeLoop; 
		#get modulus of this 
		my $diffCharge = util::modulus($diffCharge);
		#add this to the previous iteration 
		$diffCount = $diffCount + $diffCharge;  
	}
	my $averageLoop = $diffCount/$length;  

	return $averageLoop; 
}


#*************************************************************************
#> belowthreshold($pdbName, $threshold)
#  ----------------------------------------------
#  Inputs:   \scalar	$pdbName	Scalar containing antibody pdbname in 
#					the standard PDB format.
#	     \scalar 	$threshold	Scalar containing the threshold value 
#					of RMSD through which the model is 
#					determined 'good' or 'bad.	
# 						
#
#  returns true or false depending on whether or not the RMSD of this protein
#  is below the threshold set in ARGV. 
#
#  06.02.2018 by C.G.B.
sub belowthreshold
{
	my ($pdbName, $threshold) = @_;
	my $spreadsheetsPath = "$config::spreadsheets"; 
	# the file name to be used 
	my $file = "$config::dataSource.xls";
	#open STDERR file 
	my $spreadFile = "$spreadsheetsPath/$file";
	open(FILE, "<$spreadFile"); 
	if(!open(FILE, "<$spreadFile"))
	{
		print STDERR "Error in csvgen.pl: unable to open file $spreadFile\n";
	       	exit 1;
	}
	my $rmsd;
	while(my $line = <FILE>) {
		my @lines = split(/\s+/, $line);
		if ($lines[0] eq $pdbName) {
			$rmsd = $lines[4];
		}
	}
	my $result;
	if ($rmsd <= $threshold){
		$result = "GOOD";	
	} 
	else {
		$result = "BAD";
	}

	return $result;
}

