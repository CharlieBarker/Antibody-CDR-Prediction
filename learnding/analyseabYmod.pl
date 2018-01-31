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
#make a directory where all the time files will go. 
my $timeDir = "$tmpdir/time"; 
`mkdir $tmpdir`;
#print errors if they don't fit
if(! -d $tmpdir)
{
    print STDERR "Error: unable to create directory $tmpdir\n";
    exit 1;
}
`mkdir $timeDir`;
if(! -d $timeDir)
{
    print STDERR "Error: unable to create time directory $timeDir\n";
    exit 1;
}


#RUN CYCLESCRIPT
my $var = `./cyclescript.pl $tmpdir @ARGV`; 
#RUN EXTRACT RMSD
my $var = `./extractRmsd.pl $tmpdir > $tmpdir/RMSDoutput.txt`;
#RUN CDRH3WRITER
my $var = `./cdrh3writer.pl $tmpdir/RMSDoutput.txt > results/spreadsheets/$xlsName.xls`;
#RUN TIMEEXTRACT
my $var = `./timeextract.pl $timeDir > results/time/$xlsName.txt`;
#count pdb files and remove tmp folder
my $dir = 'directory name goes here';
my @files = <$tmpdir/*>;
my $count = @files;
print "PDB FILES PRODUCED: $count\n";
`rm -rf $tmpdir`;
