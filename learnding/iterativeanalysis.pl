#!/usr/bin/perl

#*************************************************************************
#
#   Program:    analyseabYmod
#   File:       iterativeanalysis.pl
#   Date:       03.10.17
#   Function:   Used for queing jobs to run analyseabYmod.pl in serial/parrellel. 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	iterativeanalysis 
#		Control the jobs by editing the code below. 
#		perl analyseabYmod.pl [jobname] [-abYmodflags] [<optional> 2> 
#		results/abyModSTDERR/jobname.txt] 
#		Optional allows the printing of STDERR readout into seperate file.
#  
#               
#*************************************************************************

use strict;

my $var = `perl analyseabYmod.pl normal 2> results/abyModSTDERR/normal.txt`; 
my $var = `perl analyseabYmod.pl verbose -v=3 2> results/abyModSTDERR/verbose.txt`; 


