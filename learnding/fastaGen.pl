#!/usr/bin/perl

#*************************************************************************
#
#   Program:     - 
#   File:       fastaGen.pl
#   Date:       13.12.17
#   Function:   Turns abseqlib into one giant long concatenated FASTA file.  
#               
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	
#   Inputs: 	
#   Outputs:	
#               
#*************************************************************************

use config;
use strict; 

my $dirName = "$config::abseqlib";
opendir(DIR, $dirName) or die "Could not open $dirName\n";
my @fileNames = ();
while (my $fileName = readdir(DIR)) {
  push @fileNames, $fileName;
}

closedir(DIR);

my @fasta = ();
my @elements = ();
foreach my $seqFile (@fileNames)
{
	open(DATA, "<$config::abseqlib/$seqFile"); 
	if(!open(DATA, "<$config::abseqlib/$seqFile"))
	{
		print STDERR "Error: unable to open file $seqFile\n";
        	exit 1;
	}
	push @fasta, ">$seqFile\n";
	while(my $line = <DATA>)
	{
		@elements = split ' ', $line;
		push @fasta, $elements[1]; 
 
	}
	push @fasta, "\n";		
}
print @fasta


