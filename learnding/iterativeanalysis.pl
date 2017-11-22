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
#		perl analyseabYmod.pl [jobname] [-abYmodflags] [2> 
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
#no hup [command] & for no hangup 
#ALWAYS CHECK JOBS ARE RUNNING BY TYPING ps auxwww | grep abymod.pl  AFTER EXECUTION
		


my $job1 = "perl analyseabYmod.pl nLoops19 -noopt -loopdb -nloophits=19 2> results/abyModSTDERR/nLoops19.txt"; 
my $job2 = "perl analyseabYmod.pl nLoops16 -noopt -loopdb -nloophits=16 2> results/abyModSTDERR/nLoops16.txt"; 
my $job3 = "perl analyseabYmod.pl nLoops23 -noopt -loopdb -nloophits=23 2> results/abyModSTDERR/nLoops23.txt"; 
my $job4 = "perl analyseabYmod.pl nLoops27 -noopt -loopdb -nloophits=27 2> results/abyModSTDERR/nLoops27.txt"; 
my $job5 = "perl analyseabYmod.pl nLoops10 -noopt -loopdb -nloophits=10 2> results/abyModSTDERR/nLoops10.txt"; 
my $job6 = "perl analyseabYmod.pl nLoops11 -noopt -loopdb -nloophits=11 2> results/abyModSTDERR/nLoops11.txt"; 
my $job7 = "perl analyseabYmod.pl nLoops12 -noopt -loopdb -nloophits=12 2> results/abyModSTDERR/nLoops12.txt"; 
my $job8 = "perl analyseabYmod.pl nLoops29 -noopt -loopdb -nloophits=29 2> results/abyModSTDERR/nLoops29.txt"; 
my $job9 = "perl analyseabYmod.pl nLoops30 -noopt -loopdb -nloophits=30 2> results/abyModSTDERR/nLoops30.txt";
my $job10 = "perl analyseabYmod.pl nLoops21 -noopt -loopdb -nloophits=21 2> results/abyModSTDERR/nLoops21.txt";



#####################################################################################################

my @jobs = ($job1, $job2, $job3, $job4, $job5, $job6, $job7, $job8, $job9, $job10);
#go through jobs running them while the total number of abymods that are running is less than 4
foreach my $job (@jobs)
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
    } while($nRunning >= 6);

    StartJob($job);
	print "$nRunning\n";

	
}

############################################SUBROUTINES############################################
sub StartJob
{
	my ($job) = @_; 
	system("$job &")
}
