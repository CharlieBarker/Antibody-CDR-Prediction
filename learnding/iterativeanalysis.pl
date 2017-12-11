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
#nohup [command] & (for no hangup) 
#ALWAYS CHECK JOBS ARE RUNNING BY TYPING ps auxwww | grep abymod.pl  AFTER EXECUTION
		


my $job1 = "perl analyseabYmod.pl default -noopt -loopdb 2> results/abyModSTDERR/default.txt";  
my $job2 = "perl analyseabYmod.pl nLoops1 -noopt -loopdb -nloophits=1 2> results/abyModSTDERR/nLoops1.txt"; 
my $job3 = "perl analyseabYmod.pl nLoops2 -noopt -loopdb -nloophits=2 2> results/abyModSTDERR/nLoops2.txt"; 
my $job4 = "perl analyseabYmod.pl nLoops3 -noopt -loopdb -nloophits=3 2> results/abyModSTDERR/nLoops3.txt"; 
my $job5 = "perl analyseabYmod.pl nLoops4 -noopt -loopdb -nloophits=4 2> results/abyModSTDERR/nLoops4.txt"; 
my $job6 = "perl analyseabYmod.pl nLoops5 -noopt -loopdb -nloophits=5 2> results/abyModSTDERR/nLoops5.txt"; 
my $job7 = "perl analyseabYmod.pl nLoops6 -noopt -loopdb -nloophits=6 2> results/abyModSTDERR/nLoops6.txt"; 
my $job8 = "perl analyseabYmod.pl nLoops7 -noopt -loopdb -nloophits=7 2> results/abyModSTDERR/nLoops7.txt"; 
my $job9 = "perl analyseabYmod.pl nLoops8 -noopt -loopdb -nloophits=8 2> results/abyModSTDERR/nLoops8.txt"; 
my $job10 = "perl analyseabYmod.pl nLoops9 -noopt -loopdb -nloophits=9 2> results/abyModSTDERR/nLoops9.txt"; 
my $job11 = "perl analyseabYmod.pl nLoops10 -noopt -loopdb -nloophits=10 2> results/abyModSTDERR/nLoops10.txt"; 
my $job12 = "perl analyseabYmod.pl nLoops11 -noopt -loopdb -nloophits=11 2> results/abyModSTDERR/nLoops11.txt";
my $job13 = "perl analyseabYmod.pl nLoops12 -noopt -loopdb -nloophits=12 2> results/abyModSTDERR/nLoops12.txt";
my $job14 = "perl analyseabYmod.pl nLoops13 -noopt -loopdb -nloophits=13 2> results/abyModSTDERR/nLoops13.txt";
my $job15 = "perl analyseabYmod.pl nLoops14 -noopt -loopdb -nloophits=14 2> results/abyModSTDERR/nLoops14.txt";
my $job16 = "perl analyseabYmod.pl nLoops15 -noopt -loopdb -nloophits=15 2> results/abyModSTDERR/nLoops15.txt";
my $job17 = "perl analyseabYmod.pl nLoops16 -noopt -loopdb -nloophits=16 2> results/abyModSTDERR/nLoops16.txt";
my $job18 = "perl analyseabYmod.pl nLoops17 -noopt -loopdb -nloophits=17 2> results/abyModSTDERR/nLoops17.txt";
my $job19 = "perl analyseabYmod.pl nLoops18 -noopt -loopdb -nloophits=18 2> results/abyModSTDERR/nLoops18.txt";
my $job20 = "perl analyseabYmod.pl nLoops19 -noopt -loopdb -nloophits=19 2> results/abyModSTDERR/nLoops19.txt";
my $job21 = "perl analyseabYmod.pl nLoops20 -noopt -loopdb -nloophits=20 2> results/abyModSTDERR/nLoops20.txt";
my $job22 = "perl analyseabYmod.pl nLoops21 -noopt -loopdb -nloophits=21 2> results/abyModSTDERR/nLoops21.txt";
my $job23 = "perl analyseabYmod.pl nLoops22 -noopt -loopdb -nloophits=22 2> results/abyModSTDERR/nLoops22.txt";
my $job24 = "perl analyseabYmod.pl nLoops23 -noopt -loopdb -nloophits=23 2> results/abyModSTDERR/nLoops23.txt";
my $job25 = "perl analyseabYmod.pl nLoops24 -noopt -loopdb -nloophits=24 2> results/abyModSTDERR/nLoops24.txt";
my $job26 = "perl analyseabYmod.pl nLoops25 -noopt -loopdb -nloophits=25 2> results/abyModSTDERR/nLoops25.txt";
my $job27 = "perl analyseabYmod.pl nLoops26 -noopt -loopdb -nloophits=26 2> results/abyModSTDERR/nLoops26.txt";
my $job28 = "perl analyseabYmod.pl nLoops27 -noopt -loopdb -nloophits=27 2> results/abyModSTDERR/nLoops27.txt";
my $job29 = "perl analyseabYmod.pl nLoops28 -noopt -loopdb -nloophits=28 2> results/abyModSTDERR/nLoops28.txt";
my $job30 = "perl analyseabYmod.pl nLoops29 -noopt -loopdb -nloophits=29 2> results/abyModSTDERR/nLoops29.txt";
my $job31 = "perl analyseabYmod.pl nLoops30 -noopt -loopdb -nloophits=30 2> results/abyModSTDERR/nLoops30.txt";






#####################################################################################################

my @jobs = ($job1, $job2, $job3, $job4, $job5, $job6, $job7, $job8, $job9, $job10, $job11, $job12,
	$job13, $job14, $job15, $job16, $job17, $job18, $job19, $job20, $job21, $job22, $job23, $job24, $job25, $job26, $job27, $job28, $job29, $job30, $job31);
@jobs = reverse @jobs;
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
