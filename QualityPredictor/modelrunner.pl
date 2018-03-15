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

my $input = shift(@ARGV);
my @models = `ls $config::mlModels -B`;
my @modelList;
my @modelLocation;
my %goodOrBad;
my %errorPrediction;
foreach my $model (@models){
	chop($model);
	push @modelList, $model;
	my @elements = split(/DATA/, $model);
	my $modelLoc = $elements[0];
	push @modelLocation, $modelLoc;
}
my $no = 40; 
for(my $i=0; $i<$no; $i++) {
	my $result =`java weka.classifiers.$modelLocation[$i] -T $input -l $config::mlModels/$modelList[$i] -p 0\n`;
	my @lines = split(/\n/, $result);
	for my $line (@lines){
			if ($line =~ /\?/){
				my @elements = split(/\s+/, $line);
				my @ele = split("DATA", $modelList[$i]);
				my @ele1 = split(".arff", $ele[1]);
				my @ele2 = split(":", $elements[3]);
				my $threshold = $ele1[0];
				my $goodOrBad = $ele2[1];
				my $errorPrediction = $elements[4];
				$goodOrBad{$threshold} = $goodOrBad;
				$errorPrediction{$threshold} = $errorPrediction;
			}
	}
}
my %sortedGoodOrBad;
for my $key (sort {$a<=>$b} keys %goodOrBad) {
	$sortedGoodOrBad{$key} = $goodOrBad{$key};
	print "($key)->($goodOrBad{$key})\n";
}

