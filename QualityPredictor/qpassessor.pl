#!/usr/bin/perl
use strict;
#openoutput of machine learning file
open(FILE, "<out.txt"); 
if(!open(FILE, "<out.txt"))
{
	print STDERR "Error in csvgen.pl: unable to open file out.txt";
       	exit 1;
}
#declare arrays 
my @pdb;
my @threshold;
#cycle through output finding pdb names and thresholds 
while(my $line = <FILE>) {
	if($line =~ /.arff/){
		$line  = substr $line, 0, 5;
		push @pdb, $line; 
	}
	else
	{
		my @ele = split / /, $line;
		my $thresh  = substr $ele[2], 1, 10;
		push @threshold, $thresh;
	}
}
#open csv containing real RMSDs 
open(FILE, "<loopdb.xls"); 
if(!open(FILE, "<loopdb.xls"))
{
	print STDERR "Error in csvgen.pl: unable to open file loopdb.xls";
       	exit 1;
}
#decleare arrays 
my @idealThresher;
#cycle through csv extracting those RMSDs from all the pdbs tested in out, finding the ideal threshold. 
while(my $line = <FILE>) {
	my @parts = split(/\s+/, $line);
	foreach my $protein (@pdb){
		my $pdbName = "$protein" . ".pdb"; 
		if ($parts[0] eq $pdbName){
			#part that finds the ideal threshold 
			my $idealThresh = int($parts[3] + 0.49);
			if ($idealThresh <= $parts[3]){
				$idealThresh = $idealThresh + .5;
			}
			push @idealThresher, $idealThresh;
		}	
	}
}
#put ideal thresholds and real thresholds into array with the keys as the protein pdb name. 
my %modelThreshold;
my %idealThreshold; 
my $no = @pdb;
for(my $i=0; $i<$no; $i++) {
	$modelThreshold{$pdb[$i]} = $threshold[$i];
	$idealThreshold{$pdb[$i]} = $idealThresher[$i];
	
}
#find relevant information
my $count = 0; 
my $totalCount = 0;
foreach my $proteinName (@pdb){
	print "$idealThreshold{$proteinName} $modelThreshold{$proteinName}\n";
	if ($idealThreshold{$proteinName} == $modelThreshold{$proteinName}){
		print "YAAS\n";
		$count++;
	}
	else{
		print "no\n";
		
	}
	$totalCount++;
}
my $end = $count/$totalCount;
print "$end\n";
