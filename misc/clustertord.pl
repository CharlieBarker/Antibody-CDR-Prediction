#!/usr/bin/perl

#*************************************************************************
#
#   Program:    
#   File:       clustertord.pl
#   Date:       13.12.17
#   Function:   takes cd-hit cluster analysis and turns it into a redundancy file. 
#		You can now set the sequence similarity of your redundancy files (woo!) 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	perl clustertord.pl > [nameofredundancyfile.txt]
#   Inputs: 	the output file from your cd-hit cluster analysis
#   Outputs:	redundancy file. 
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
my @allRedundant = ();
#go through different proteins (and their clusters) pushing ones containing * as the starters
for my $ele (@lines){
	if ($ele =~ /\*/) {
		push @starters, $ele;
	}
	#if no * is found push into redundant array. 
	else {
		push @allRedundant, $ele;
	}
}
#for every starting protein
for my $starter (@starters){
	#isolate the cluster no.
	my $clusterNo  = substr $starter, 1, 11; 
	#remove whitespace either side. 
	$clusterNo =~ s/^\s+|\s+$//g;
	my @redundant = ();
	#ho through all redundant proteins of the same cluster no. 
	for my $allRedun (@allRedundant){
		if ($allRedun =~ /$clusterNo\s/) {
			#get the pdb code of these proteins 
			my $char = ', >';
			my $loc = index($allRedun, $char);
			$loc = $loc+3;  
			my $redunPdb = substr $allRedun, $loc, 5;
			$redunPdb = deProcessLine($redunPdb);
			#push into their own array 
			push @redundant, $redunPdb;
		}	
	}
	my $starterPdb = substr $starter, -15, 5;
	$starterPdb = deProcessLine($starterPdb);
	print "$starterPdb,";
	for my $redun (@redundant){
		print " $redun,";
	}
	print "\n";
}

##########SUBROUTINES##########
#(opposite of Andrew's subroutine; ProccessLine)
sub deProcessLine
{
	my($entry) = @_;
	$entry = "\U$entry";
	my $number = substr $entry, -1, 1;
	$number = "$number" + 1; 
	$entry = substr($entry, 0, -1);
	$entry = "$entry\_$number";

	return($entry);
}


