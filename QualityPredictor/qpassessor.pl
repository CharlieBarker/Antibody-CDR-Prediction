#!/usr/bin/perl
use strict;
#openoutput of machine learning file
open(FILE, "<out.txt"); 
if(!open(FILE, "<out.txt"))
{
	print STDERR "Error in qpassessor: unable to open file out.txt";
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
	print STDERR "unable to open file loopdb.xls";
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
			my $idealThresh = $parts[3];
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

my @fudgeFactors = (0.5, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10);
	print "T F1\n";
foreach my $fudgeFactor (@fudgeFactors){
	my $FN;
	my $TP; 
	my $FP;
	foreach my $proteinName (@pdb){
		if ($idealThreshold{$proteinName} <= $modelThreshold{$proteinName} - $fudgeFactor){
			$FN++;
		}
		if ($modelThreshold{$proteinName} - $fudgeFactor <= $idealThreshold{$proteinName} & 
		$modelThreshold{$proteinName} + $fudgeFactor >= $idealThreshold{$proteinName}){
			$TP++;
		}
		if ($idealThreshold{$proteinName} >= $modelThreshold{$proteinName} + $fudgeFactor){
			$FP++;
		}
		$totalCount++;
	}
	my $TPR = $TP/($TP+$FN);
	my $PPV = $TP/($TP+$FP);
	my $FNR = $FN/($FN+$TP);
	my $FDR = $FP/($FP+$TP);
	my $F1a = (2*$PPV*$TPR) / ($PPV+$TPR);
	my $F1b = 2*$TP/(2*$TP+$FP+$FN);

	print "$fudgeFactor $F1a\n";

}

