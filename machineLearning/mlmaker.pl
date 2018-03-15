
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
#add weka.jar to classpath
`export CLASSPATH=\$CLASSPATH:/home/charlie/weka-3-8-2/weka.jar`;
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
		print STDERR ">>>>>>>>>>>>>>$classifier $arff <<<<<<<<<<<<<<<<<\n"; 
		my $mcc = TestModel($classifier, $arff);
		print STDERR "......END......\n";

	}
		
}


sub TestModel 

{
	my($classifier, $arff) = @_;
	#set bool in order to determine that dat is stratified cross validation and not bog standard error
	my $bool = 0; 
	#write command and store response 
	my $result = `java weka.classifiers.$classifier -t $config::arrfresults/$arff -d $config::MLalgorithms/$classifier$arff.model`;
	print STDERR "$result\n"; 
}
	
