#!/usr/bin/perl

#*************************************************************************
#
#   Program:    machinelearning
#   File:       mlassessor.pl
#   Date:       13.03.2018
#   Function:   Quickly running various weka machine learning methods over all
#				thresholds. 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	
#  
#               
#*************************************************************************


use strict; 
use util;
use config;
#list all the classifiers to be tested.
my @classifiers = ("trees.DecisionStump", "trees.HoeffdingTree", "trees.J48", "trees.RandomTree",
					"bayes.NaiveBayes", "bayes.NaiveBayesUpdateable", "functions.Logistic",
					"functions.SGD", "functions.SimpleLogistic", "functions.SMO", "functions.VotedPerceptron",
					"lazy.IBk", "lazy.KStar", "lazy.LWL", "rules.JRip", "rules.OneR", "rules.PART");
					
#get a list of all the arffs excluding backups
my @arffs = `ls $config::arrfresults -B`;
my @nArffs;
foreach my $arf (@arffs){
	chop($arf);
	push @nArffs, $arf;
}
 
#start loop
print "Classifier ARFF MCC\n"; 
foreach my $classifier (@classifiers){
	foreach my $arff (@nArffs){
		#remove return
		my $mcc = TestModel($classifier, $arff);
		print "$classifier $arff $mcc\n"; 
	}
		
}


sub TestModel 

{
	my($classifier, $arff) = @_;
	#set bool in order to determine that dat is stratified cross validation and not bog standard error
	my $bool = 0; 
	#write command and store response 
	my $result = `java weka.classifiers.$classifier -t $config::arrfresults/$arff`;
	#split result by returns 
	my @lines = split(/\n/, $result);
	my $mcc;
	for my $line (@lines){
		#if we are passed the line saying that the next lines are refering to strat cv then set bool to 1. 
		if ($line eq "=== Stratified cross-validation ==="){
			$bool = 1;
		}
		if ($line =~ /Weighted Avg./ & $bool == 1){
			my @numbers = split(/\s+/, $line);
			my $length = @numbers;
			$mcc = $numbers[7]; 
			(defined($mcc) && $length == 10) || die "Something went wrong with WEKA output for $classifier, $arff";
		}
	}	
	
	return ($mcc);
}
	
