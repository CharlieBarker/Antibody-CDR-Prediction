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
#`mkdir $tmpdir`;
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
#delete training spaces form @arffData
#s/\s+$// for (@arffData);
foreach my $instance (@arffData){
	$instanceFile = "$arffIntro" . "\@data\n" . "$instance";
	print $instanceFile; 
}

