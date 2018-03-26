#!/usr/bin/perl
#*************************************************************************
#
#   Program:    QualityPredictor
#   File:       modelrunner.pl
#   
#   Date:       15.03.2018
#   Function:   Runs the machine learning models 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#
#*************************************************************************
use strict;
use config; 
#extract input
my $input = shift(@ARGV);
#create temporary folder for seperated arff storage
my $tmpdir = "/tmp/QualityPredictor_$$";
`mkdir $tmpdir`;
#open the input file
open(DATA, "<$input"); 
if(!open(DATA, "<$input"))
{
    print STDERR "Error: unable to open file $input\n";
    exit 1;
}
#extract the data of the arff file from the intro
my $bool = 0; 
my $arffIntro;
my @arffData;
while(my $line = <DATA>) #cycle through lines in file
{	
	if ($bool == 1){
		push @arffData, $line;
	}
	if ($line =~ "data" & $line !~ "relation"){
		$bool = 1; 
		
	}
		if ($bool == 0){
		$arffIntro = "$arffIntro" . "$line";
	}	
}
my $instanceFile;
my $proteinPdb;
#go through each seperated arff and write a file for each. 
foreach my $instance (@arffData){
	my @words = split /,/, $instance;
	$proteinPdb = $words[8];
	$proteinPdb  = substr $proteinPdb, 0, 5;
	$instanceFile = "$arffIntro" . "\@data\n" . "$instance";
	open(my $fh, '>', "$tmpdir/$proteinPdb.arff");
	print $fh "$instanceFile";
	close $fh;
}
#list and go through the seperated arrf files in the temporary directory. 
my @arrfFiles = `ls $tmpdir -B`;
foreach my $file (@arrfFiles){
		my $result =`./modelrunner.pl $tmpdir/$file`; 
		print $file;
		print $result;
}
#delete temporary directory
`rm -rf $tmpdir`;
