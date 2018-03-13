#!/usr/bin/perl

#*************************************************************************
#
#   Program:    machinelearningprep
#   File:       loopproperties.pl
#   Date:       05.02.2018
#   Function:   gets amino acid sequence of loops  
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	perl loopproperties.pl
#   Inputs: 	.pdb file
#   Outputs:	.seq file
#               
#*************************************************************************

use strict;
use util;

my $stderrPath = "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding/results/abyModSTDERR
"; 
my $file = "nLoops10.txt";
my $path = "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/abymod/DATA/loopdb/PDB";
my $loop = "2b1a-H92-H105-15";
my @out = util::PdbToSeq($loop, $path);
print "@out";


