#!/usr/bin/perl

#*************************************************************************
#
#   Program:    
#   File:       clustertord.pl
#   Date:       13.12.17
#   Function:   takes cd-hit cluster analysis and turns it into a redundancy file.  
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	
#   Inputs: 	
#   Outputs:
#               
#*************************************************************************
use strict; 


#clsr file you want to extract redundancies from 
my $clstrFile = "1513175541.fas.1.clstr.sorted";
#open file or print error 
open(DATA, "<$clstrFile"); 
if(!open(DATA, "<$clstrFile"))
{
	print STDERR "Error: unable to open file $clstrFile\n";
       	exit 1;
}
#create empty hashes 
my @clusters = ();
my @lines = (); 
my $count = 0;
#go through clstr file
while(my $line = <DATA>) {
	#find lines with cluster, add them to all other preceding lines till the next cluster line
	
	if ($line =~ /Cluster/) {
        	push @clusters, $line;
  		$count++; 
        } 
	else {
		my $newLine = "$clusters[$count-1] $line";
		push @lines, $newLine;	
	}	
}
#create empty hashes for the starter proteins and the redundant ones to follow 
#(see the format of saba's redundancy files for reference)
my @starters = ();
my @redundant = ();
#go through different proteins (and their clusters) pushing ones containing * as the starters
for my $ele (@lines){
	if ($ele =~ /\*/) {
		push @starters, $ele;
	}
	#if no * is found push into redundant array. 
	else {
		push @redundant, $ele;
	}
}

#create hash of starting proteins with cluster as key 
my %starterHash =(); 
for my $starter (@starters){
	my $clusterNo  = substr $starter, 1, 11; 
	$clusterNo =~ s/^\s+|\s+$//g;
	my $pdbName = substr $starter, -15, 5; 
	$starterHash{$clusterNo} = $pdbName;	
}
#create hash of redundant proteins with cluster as key
my %redundantHash; 
my $clusterNo;
for my $ele (@redundant){
	#print "$ele";
	my $char = ', >';
	my $loc = index($ele, $char);
	$loc = $loc+3;  
	my $pdbName = substr $ele, $loc, 5; 
	my $char1 = '>';
	my $loc1 = index($ele, $char1);
	$loc1 = $loc1+1;
	my $clusterNo  = substr $ele, $loc1, 11;
	$clusterNo =~ s/^\s+|\s+$//g;
	#print "$clusterNo\n";
	$redundantHash{$clusterNo} = $pdbName;
}
print "$redundantHash{'Cluster 1'}\n";


###########SUBROUTINES##########



