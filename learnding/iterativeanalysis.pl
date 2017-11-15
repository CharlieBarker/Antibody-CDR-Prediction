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
#		Don't forget to use -noopt
#	        Ensure you are running the tests on martin-cs00 (i.e. use "ssh
#		martin-cs00") to get on the right machine.
#  
#               
#*************************************************************************


use strict;



###########################################ENTER JOBS HERE###########################################
#DON'T FORGET TO USE -noopt
# Usage - perl analyseabYmod.pl [job_name] [-abYmodflags] [<optional> 2> results/abyModSTDERR/job_name.txt]  
#I would recomend taking 
#Ensure you are running the tests on martin-cs00 (i.e. use "ssh
#martin-cs00") to get on the right machine.

		

my $job1 = "perl analyseabYmod.pl 1 -noopt"; 
my $job2 = "perl analyseabYmod.pl 2 -v=3 -noopt"; 
my $job3 = "";
my $job4 = "";
my $job5 = "";
my $job6 = "";
my $job7 = "";
my $job8 = "";
my $job9 = "";
my $job10 = "";
my $job11 = "";
my $job12 = "";
my $job13 = "";
my $job14 = "";
my $job15 = "";

#####################################################################################################

my @jobs = ($job1, $job2, $job3, $job4, $job5, $job6, $job7, $job8, $job9, $job10, $job11, $job12,
	$job13, $job14, $job15);
#foreach $job (@jobs)
#{
#	split
#}
#go through jobs running them while the total number of abymods that are running is less than 4
foreach $job (@jobs)
{
    my $nRunning  = 0;
    my $firstCall = 1;
    do
    {
        # Check how many abymods are running
        $nRunning = `ps auxwww | grep abymod.pl | grep -v grep | wc -l`;
        if($firstCall)
        {
            $firstCall = 0;
        }
        else
        {
            sleep 5;
        }
    } while($nRunning >= 4);

    StartJob($job);
	
}

############################################SUBROUTINES############################################
sub StartJob
{
	my ($job) = @_; 
	`$job`;
}
