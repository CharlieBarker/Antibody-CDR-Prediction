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
#		Can edit the code to redirect STDOUT into files 
#		if you want to keep the STDOUT of the seperate scripts being
#		ran.   
#   Inputs: 	Name of the job
#		Any abYmod flags. 
#   Outputs:	SpreadSheet of RMSD
#		Any STDOUT.txt of the individual scripts.
#		        
#*************************************************************************

use strict;
#first element of argv is the name of xls file  
my $xlsName = shift(@ARGV);
#RUN CYCLESCRIPT
my $var = `./makemodel/cyclescript.pl @ARGV`; 
#RUN EXTRACT RMSD
my $var = `./testmodel/extractRmsd.pl > results/RMSDoutput.txt`;
#RUN CDRH3WRITER
my $var = `./testmodel/cdrh3writer.pl results/RMSDoutput.txt > results/spreadsheets/$xlsName.xls`;


