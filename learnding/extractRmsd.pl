#!/usr/bin/perl

#*************************************************************************
#
#   Program:    analyseabYmod
#   File:       extractRmsd.pl
#   Date:       03.10.17
#   Function:   Calculated RMSDs using the program ProFit. This script produces 
#		an output more readable to cdrh3writer.pl. If an unexpected 
#		error occurs use the script extractRmsd&Error.pl to debug.
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	extractRmsd.pl [location of protein structures]
#		To switch from testRedundancy file to regular (or visa versa), 
#		change "$config::testRedundancyFile" to "$config::redundancyFile".
#   Inputs: 	pdb folder in \tmp file.
#   Outputs:	RMSDoutput.txt in \tmp file. 
#               
#*************************************************************************

use strict;
use config;
#path for profit files
my $pftPath = $config::pftScripts;
#swap testRedundancyFile for redundancyFile if not testing 
my $rdFile = $config::redundancyFile;
#open redundancy file or print error message.
open(DATA, "<$rdFile"); 
if(!open(DATA, "<$rdFile"))
{
    print STDERR "Error: unable to open file $rdFile\n";
    exit 1;
}
#start counting succesful rmsd calculations for means and stats
my $successCount = 0;	#no. of successfully calculated rmsds
my $totalCount = 0; 	#no. of calculated rmsds (including errors)
my $rdFileCount = 0;	#total no. of proteins to be calculated
print STDERR "CALCULATING RMSD VALUES\n";
while(my $line = <DATA>){
	#total no. of lines in the rdFile (equivalent to the total no. of calculations required)
	$rdFileCount = $.;
	my ($ACTUALpdb, $MODELpdb) = ProcessLine($line); #use subroutine below to extract file
	                                                 #names of predicted and actual PDB structures to compare
	my $ACTUALpath= "$config::abpdblib"; #specify path for the actual pdb structure 
	my $MODELpath= "@ARGV"; #specify path for the model pdb structure 

	#LIGHT CHAIN RMSD

	#use Testmodel sub to call ProFit and calc RMSD for alpha carbons in light chain.
	my($l1cal, $l2cal, $l3cal, $l1cag, $l2cag, $l3cag, $valueCount, @preambleErrors) = 
		TestModel("$pftPath/L_ca.pft","$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	#increment total count (used for progress calculation) 
	$totalCount++;
	#create count to incrememnt every time RMSD is correctly calculated for every profit instruction file
	#if this count is the correct number (4) we print. Otherwise we discard all the errors
	my $count = 0;
	#if the RMSD value count is 9 then we assume everything went well with the ProFit RMSD calcs. 
	my($l1CaLocal, $l2CaLocal, $l3CaLocal, $l1CaGlobal, $l2CaGlobal, $l3CaGlobal); 
	if($valueCount == 9)
	{
		$count++;
		$l1CaLocal = $l1cal;
		$l2CaLocal = $l2cal;
		$l3CaLocal = $l3cal;
		$l1CaGlobal = $l1cag;
		$l2CaGlobal = $l2cag;
		$l3CaGlobal = $l3cag;
	}

	#Do same again for all light chain atoms (using ProFit instruction file L_all.pft)
	my($l1cal, $l2cal, $l3cal, $l1cag, $l2cag, $l3cag, $valueCount, @preambleErrors) = 
		TestModel("$pftPath/L_all.pft","$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	my($l1AllLocal, $l2AllLocal, $l3AllLocal, $l1AllGlobal, $l2AllGlobal, $l3AllGlobal); 
	if($valueCount == 9)
	{
		$count++;
		$l1AllLocal = $l1cal;
		$l2AllLocal = $l2cal;
		$l3AllLocal = $l3cal;
		$l1AllGlobal = $l1cag;
		$l2AllGlobal = $l2cag;
		$l3AllGlobal = $l3cag;
	}


	#HEAVY CHAIN RMSD 
	#same again for alpha carbon atoms in heavy chain
	my($H1cal, $H2cal, $H3cal, $H1cag, $H2cag, $H3cag, $valueCount, @preambleErrors) = 
		TestModel("$pftPath/H_ca.pft","$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	my($h1CaLocal, $h2CaLocal, $h3CaLocal, $h1CaGlobal, $h2CaGlobal, $h3CaGlobal);
	if($valueCount == 9)
	{
		$count++;
		$h1CaLocal = $H1cal;
		$h2CaLocal = $H2cal;
		$h3CaLocal = $H3cal;
		$h1CaGlobal = $H1cag;
		$h2CaGlobal = $H2cag;
		$h3CaGlobal = $H3cag;
	}


	#same again for all atoms in heavy chain
	my($H1cal, $H2cal, $H3cal, $H1cag, $H2cag, $H3cag, $valueCount, @preambleErrors) = 
		TestModel("$pftPath/H_all.pft","$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	my($h1AllLocal, $h2AllLocal, $h3AllLocal, $h1AllGlobal, $h2AllGlobal, $h3AllGlobal); 
	if($valueCount == 9)
	{
		$count++;
		$h1AllLocal = $H1cal;
		$h2AllLocal = $H2cal;
		$h3AllLocal = $H3cal;
		$h1AllGlobal = $H1cag;
		$h2AllGlobal = $H2cag;
		$h3AllGlobal = $H3cag;
	}
	
	#if all of these 4 ProFit instruction files have been conducted without error (if($valueCount == 9) for all 4)
	#print the results
	if($count == 4)
	{
		print "L1(CA)(local) = $l1CaLocal	$ACTUALpdb \n";
		print "L2(CA)(local) = $l2CaLocal	$ACTUALpdb \n";
		print "L3(CA)(local) = $l3CaLocal	$ACTUALpdb \n";
		print "L1(CA)(global) = $l1CaGlobal	$ACTUALpdb \n";
		print "L2(CA)(global) = $l2CaGlobal	$ACTUALpdb \n";
		print "L3(CA)(global) = $l3CaGlobal	$ACTUALpdb \n";
		print "L1(all)(local) = $l1AllLocal	$ACTUALpdb \n";
		print "L2(all)(local) = $l2AllLocal	$ACTUALpdb \n";
		print "L3(all)(local) = $l3AllLocal	$ACTUALpdb \n";
		print "L1(all)(global) = $l1AllGlobal	$ACTUALpdb \n";
		print "L2(all)(global) = $l2AllGlobal	$ACTUALpdb \n";
		print "L3(all)(global) = $l3AllGlobal	$ACTUALpdb \n";
		print "H1(CA)(local) = $h1CaLocal	$ACTUALpdb \n";
		print "H2(CA)(local) = $h2CaLocal	$ACTUALpdb \n";
		print "H3(CA)(local) = $h3CaLocal	$ACTUALpdb \n";
		print "H1(CA)(global) = $h1CaGlobal	$ACTUALpdb \n";
		print "H2(CA)(global) = $h2CaGlobal	$ACTUALpdb \n";
		print "H3(CA)(global) = $h3CaGlobal	$ACTUALpdb \n";
		print "H1(all)(local) = $h1AllLocal	$ACTUALpdb \n";
		print "H2(all)(local) = $h2AllLocal	$ACTUALpdb \n";
		print "H3(all)(local) = $h3AllLocal	$ACTUALpdb \n";
		print "H1(all)(global) = $h1AllGlobal	$ACTUALpdb \n";
		print "H2(all)(global) = $h2AllGlobal	$ACTUALpdb \n";
		print "H3(all)(global) = $h3AllGlobal	$ACTUALpdb \n";
		$successCount++;
	}
	
	#next bit is to keep track of progress. 

	my $percentage = round(($totalCount/$rdFileCount)*100);
	print STDERR "Progress : $percentage %\r";
	


}
print STDERR "\n";

#print warning if only half the maximum possible RMSDs are created 

if($successCount <= $rdFileCount/2)
{
	print STDERR "WARNING: RMSDs for only HALF the number of pdb files were created. 
	 You may want to run extractRmsd&Error.pl to find the issue\n"
}
print STDERR "$rdFileCount\n";
print STDERR "$totalCount\n"; 
print STDERR "$successCount\n";
####################SUBROUTINES##############################

sub TestModel
{
    my($pftfile, $actual, $model) = @_; #pass the inputed scalars into a default array

    my $result = `profit -f $config::testmodel/$pftfile $actual $model`; #call external code and store output in scalar $results
    my @values = (); #create array @values 
    my @lines = split(/\n/, $result); #split on returns to produce lines 
    for my $line (@lines) #for every line in the array @lines
    {
        if($line =~ /RMS:\s+(.+)/) #search for lines that start with RMS (these are the things we are interested in). 
        {
            push @values, $1; #push values into empty array @values
        }
    }
    my $valueCount = @values; 		
    return($values[0], $values[1], $values[2],
           $values[4], $values[6], $values[8], $valueCount);
}
sub ProcessLine
{
    my($line) = @_;

    # Remove any return character at the end and all the commas
    chomp $line;
    $line =~ s/\,//g;

    # Split the line into an array of entries (split at spaces)
    my @entries = split(/\s+/, $line);

    # Deal with working out the sequence file name from the first entry
    my $seqfile = $entries[0];
    # Split into the parts before (PDB code) and after (instance number)
    # the underscore
    my @parts = split(/_/, $seqfile);
    $parts[1]--; # Decrement the instance number
    # Reassemble the parts without the underscore
    $seqfile = $parts[0] . $parts[1];
    my $MODELpdb = "\L$seqfile" . "PRED" . ".pdb"; # make pdb name by using seqfile name and add .pdb
    my $ACTUALpdb = "\L$seqfile" . ".pdb"; # Change to lower case and add .seq
    # Now deal with getting the list of PDB files
    return($ACTUALpdb, $MODELpdb);
}
#subroutine for rounding. 
#any number greater than .5 will be increased to the next highest integer, and any number less than 
#.5 will remain the current integer, which has the same effect as rounding. 
sub round 
{
    my($number) = shift;
    return int($number + .5);
}
