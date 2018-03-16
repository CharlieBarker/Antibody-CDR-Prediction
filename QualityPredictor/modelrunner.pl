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
#get list of models
my @models = `ls $config::mlModels -B`;
my @modelList;
my @modelLocation;
my %goodOrBad;
my %errorPrediction;
#remove the model location and model name from the model file name. 
foreach my $model (@models){
	chop($model);
	push @modelList, $model;
	my @elements = split(/DATA/, $model);
	my $modelLoc = $elements[0];
	push @modelLocation, $modelLoc;
}
my $no = 40; 
#for each model. 
for(my $i=0; $i<$no; $i++) {
	#run the model through weka with the input file. 
	my $result =`java weka.classifiers.$modelLocation[$i] -T $input -l $config::mlModels/$modelList[$i] -p 0\n`;
	my @lines = split(/\n/, $result);
	#extract the relevant information (good or bad and error prediction)
	for my $line (@lines){
			if ($line =~ /\?/){
				my @elements = split(/\s+/, $line);
				my @ele = split("DATA", $modelList[$i]);
				my @ele1 = split(".arff", $ele[1]);
				my @ele2 = split(":", $elements[3]);
				my $threshold = $ele1[0];
				my $goodOrBad = $ele2[1];
				my $errorPrediction = $elements[4];
				#put goodorbad and error prediction into two hashes with threshold as key
				$goodOrBad{$threshold} = $goodOrBad;
				$errorPrediction{$threshold} = $errorPrediction;
			}
	}
}
#order the threshold keys by their numerical value
my @orderedKeys;
for my $key (sort {$a<=>$b} keys %goodOrBad) {
	push @orderedKeys, $key; 
	print "($key)->($goodOrBad{$key})->($errorPrediction{$key})\n";
}
my $modelQuality;
my $rmsdThreshold;
my $certainty; 
#go through the ordered keys 
#threshold for what is a bad model result is arbitary, needs to be tested. 
for my $orderedKey (@orderedKeys){
	if ($errorPrediction{$orderedKey} <= 0.9){
		#if error prediction is below threshold, remove the results
		delete $errorPrediction{$orderedKey};
		delete $goodOrBad{$orderedKey};
	}
	if ($goodOrBad{$orderedKey} eq "GOOD"){
		$modelQuality = $goodOrBad{$orderedKey};
		$rmsdThreshold = $orderedKey;
		$certainty = $errorPrediction{$orderedKey}; 
		last;	
	}
}
for my $key (sort {$a<=>$b} keys %goodOrBad) {
	print "($key)->($goodOrBad{$key})->($errorPrediction{$key})\n";
}
print "RESULT IS (DRUMROLL..) model is <$rmsdThreshold A, with a certainty of $certainty\n";
