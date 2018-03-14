
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
my @classifiers = ("trees.J48", "functions.Logistic", "rules.JRip");
					
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
	`java weka.classifiers.$classifier -t $config::arrfresults/$arff -d $config::mlpRoute/$classifier.model`;
}
	
