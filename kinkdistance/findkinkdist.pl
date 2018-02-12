#!/usr/bin/perl
use strict;
my @pdbList = `ls /acrm/www/html/abs/abdb/LH_Combined_Kabat/*`;
foreach my $file (@pdbList){
	my $dist = `./findkinkdist $file`;
	my $protein  = substr $file, 42, 6;
	print "$protein $dist";

}
