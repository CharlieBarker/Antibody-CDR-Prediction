#!/usr/bin/perl

#*************************************************************************
#
#   Program:    analyseabYmod
#   File:       analyseabYmod.pl
#   Date:       03.10.17
#   Function:   Master script. 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	analyseabYmod [nameofjob] [-abYmodflags] (see abymod.pl usage)
#			Don't forget to put -noopt
#		Can edit the code to redirect STDOUT into files 
#		if you want to keep the STDOUT of the seperate scripts being
#		ran.   
#   Inputs: 	Name of the job
#		Any abYmod flags. 
#   Outputs:	SpreadSheet of RMSD
#		Any STDOUT.txt of the individual scripts.
#		        
#*************************************************************************

use config;
use strict;
#first element of argv is the name of xls file  
my $xlsName = shift(@ARGV);

#create temporary folder for pdb data storage (produced by cyclescript.pl
my $tmpdir = "/tmp/analyseabymod_$$";
`mkdir $tmpdir`;
if(! -d $tmpdir)
{
    print STDERR "Error: unable to create directory $tmpdir\n";
    exit 1;
}



#RUN CYCLESCRIPT
my $var = `./cyclescript.pl $tmpdir @ARGV`; 
#RUN EXTRACT RMSD
my $var = `./extractRmsd.pl $tmpdir > results/RMSDoutput.txt`;
#RUN CDRH3WRITER
my $var = `./cdrh3writer.pl results/RMSDoutput.txt > results/spreadsheets/$xlsName.xls`;
#remove tmp folder

`rm -rf $tmpdir`;
