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
use config;

#STDERR path
my $stderrPath = "$config::abYmodSTDERR"; 
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


#removing those values with no RMSD data. 
#remove .txt and add .xls
$file = substr $file, 0, -4;
$file = "$file" . ".xls";
#path
my $path = "$config::spreadsheets/nloops1-3.20.12.17+";
my $filePath = "$path/$file";
open(SPREAD, "<$filePath"); 
if(!open(SPREAD, "<$filePath"))
{
	print STDERR "Error: unable to open file $filePath\n";
       	exit 1;
}
my @redundant;
#put the pdb files and the loop name of the template used for CDRH3 together
for(my $i=0; $i<$no; $i++) {
	#open spreadsheet file (for some reason i have to do this with each
	# iteration)
	open(SPREAD, "<$filePath"); 
	my $name = $names[$i];
	$name = "$name.pdb";
	my $loop = $loops[$i];
	# go through spreadsheet, and keep the pdb name and template loop name if 
	#the name exists in the spreadsheet. 
	while(my $line = <SPREAD>) {
		my @entries = split(/\t+/, $line);
		if($name eq $entries[0]){
			my $ele = "$name " . "$loop";
			push @redundant, $ele;
		}		
	}
}




#my $num = @redundant;
#print results 
foreach my $element (@redundant){
	my @entries = split(/\s+/, $element);
	my @out = CDRH3seq($entries[0]);
	my @res = util::PdbToSeq($entries[1], "$config::loopdb");
	@out = grep /\S/, @out; #remove empty strings in array
	@res = grep /\S/, @res; #remove empty strings in array
	my $noOut = @out;
	my $noRes = @res;
	if ($noOut == $noRes){
		print "$element # TRUE # ";
		print "@out # @res\n";
	}
	else {
		#print "$element # FALSE # ";
		#print "@out # @res\n";
	}
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

sub CDRH3seq
{
	my($pdb) = @_;
	#used abymod_V1.20 from bsmhome as for some reason some pdbs dont exist in my abymod build. 
	my $path = "$config::abpdblibBSM";
	my $pdbPath = "$path/$pdb";
	open(FILE, "<$pdbPath"); 
	if(!open(FILE, "<$pdbPath"))
	{
	    print STDERR "Error: unable to open file $pdbPath\n";
	}
	my @res;
	#step through lines in PDB loop file
	while(my $line = <FILE>){
		my @entries = split(/\s+/, $line);
		#only push if their on heavy chain and an atom. 
		if($entries[0] == "ATOM" && $entries[4] eq "H"){
			#add the residue name and the residue number
			push @res, "$entries[3]" . " $entries[5]";
		}

	}
	#remove repeated values 
	@res = util::uniq(@res);
	my $resNo = @res;
	my $start;
	my $end;
	#get indexes of start and end.. minus and add three respectively to include framework
	for(my $i=0; $i<$resNo; $i++) {
		my @entries = split(/\s+/, $res[$i]);
		if($entries[1] == 95){
			$start = $i-3;
		}
		if($entries[1] == 102){
			$end = $i+3;
		}
	}
	#isolate array between start and end scalars. 
	my @cdrh3 = @res[$start..$end];
	my @threeCode;
	#isolate three letter code 
	foreach my $residue (@cdrh3){
		my @entries = split(/\s+/, $residue);
		push @threeCode, $entries[0];
	}
	my @out;
	#translate code to one letter code 
	foreach my $ele (@threeCode){
		my $translatedCode = $util::throneData{$ele};
		push @out, $translatedCode;
	}
	return @out;
}


