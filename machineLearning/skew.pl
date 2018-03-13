#!/usr/bin/perl
use strict;
use config;
#set path for arrf files 
my $arrfparf = "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/machineLearning/ARFFDATA"; 
#list files in arrfpath 
my @arffs = `ls $arrfparf -B`;
my @nArffs;
#chop off the \n
foreach my $arf (@arffs){
	chop($arf);
	push @nArffs, $arf;
}
#for each arff collect information 
foreach my $arf (@arffs){
	my $File = "$arrfparf/$arf";
	open(DATA, "<$File"); 
	if(!open(DATA, "<$File"))
	{
    		print STDERR "Error: unable to open file $File\n";
    		exit 1;
	}
	my @total; 
	my @good;
	my $bool = 0; 
	while(my $line = <DATA>){
		
		if ($line =~ /data/ & $line !~ /relation CSV/){
			$bool = 1;
		}
		if ($bool == 1){
			my @data = split(/,/, $line);
			push @total, $data[-1];
			if ($data[-1] eq "GOOD\n"){
				push @good, $data[-1];				
			}
		}
	}
	my $noTotal = @total;
	my $noGood = @good;
	my $proportion = $noGood/$noTotal;
	#print result 
	print "$arf\t$proportion\n";
}
