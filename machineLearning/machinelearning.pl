#!/usr/bin/perl

#*************************************************************************
#
#   Program:    machinelearningprep
#   File:       machinelearning.pl 
#   Date:       06.03.2018
#   Function:   master script  
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	perl machinelearning.pl [threshold]
#   Inputs: 	threshold by which we assess whether a model is good or bad. 
#   Outputs:	arff file ending in the number of the threshold in angstroms
#               
#*************************************************************************

use strict;
use util;
use config;

#first element of argv is the name of xls file  
my $threshold = shift(@ARGV);

#create temporary folder for pdb data storage (produced by cyclescript.pl
my $tmpdir = "/tmp/mlprep_$$";
`mkdir $tmpdir`;
#print errors if they don't fit
if(! -d $tmpdir)
{
    print STDERR "Error: unable to create directory $tmpdir\n";
    exit 1;
}
my $vString = "";
$vString = "-v=$::v" if($::v > 0);
$vString .= " -q" if(defined($::q));
my $kString = (($::k >= 2)?' -k ':'');

#RUN FINDTEMPLATEUSED.pl
print STDERR "Finding the target sequence and top template.\n"; # if($::v >= 1);
`./findtemplateused.pl > $tmpdir/$config::templateName`;
#RUN CSVGEN.pl
print STDERR "Compiling CSV.\n"; 
`./csvgen.pl $tmpdir $threshold > $tmpdir/DATA.csv`; 
#RUN CSV2ARFF
print STDERR "Converting CSV to ARFF format.\n";
`perl csv2arff -v -norm -inputs=NAME,ENERGY,LENGTH,LOOPSeqID,FRAMEWORKSeqID,FRAMEWORKSeqSIMILARITY,LOOPSeqSIMILARITY,HYDROPHOBICITYINDEXDIFFERENCE,CHARGEDIFFERENCE GOODORBAD $tmpdir/DATA.csv > DATA$threshold.arff`;
#remove tmpdirectory
`rm -rf $tmpdir`;
