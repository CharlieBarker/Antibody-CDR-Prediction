#!/usr/bin/perl
use strict;
my $path = "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/machineLearning/ARFFDATA/Indielearningset.arff";
open(DATA, "<$path"); 
if(!open(DATA, "<$path"))
{
	print STDERR "Error: unable to open file $path\n";
       	exit 1;
} 
while(my $line = <DATA>) {
	$line =~ s/GOOD/?/g;
	$line =~ s/BAD/?/g;
	print "$line";
}
