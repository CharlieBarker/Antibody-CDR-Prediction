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
#		Ensure for tests you use a TEST redundancy file (doesnt contain 
#		of proteins so quicker) and do not use energybuildmodel.pl (
#		change in abymod.pl ) as this is 20 times slower. 
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
#Check you are always using the right version of abymod. 
#check you are always using the right VERSION OF BUILDMODEL
#check you are always using the right REDUNDANCY FILE 
		



 
my $job2 = "perl analyseabYmod.pl energynLoops1 -noopt -loopdb -nloophits=1 2> results/abyModSTDERR/energynLoops1.txt"; 
my $job3 = "perl analyseabYmod.pl energynLoops2 -noopt -loopdb -nloophits=2 2> results/abyModSTDERR/energynLoops2.txt"; 
my $job4 = "perl analyseabYmod.pl energynLoops3 -noopt -loopdb -nloophits=3 2> results/abyModSTDERR/energynLoops3.txt"; 
my $job5 = "perl analyseabYmod.pl energynLoops4 -noopt -loopdb -nloophits=4 2> results/abyModSTDERR/energynLoops4.txt"; 
my $job6 = "perl analyseabYmod.pl energynLoops5 -noopt -loopdb -nloophits=5 2> results/abyModSTDERR/energynLoops5.txt"; 
my $job7 = "perl analyseabYmod.pl energynLoops6 -noopt -loopdb -nloophits=6 2> results/abyModSTDERR/energynLoops6.txt"; 
my $job8 = "perl analyseabYmod.pl energynLoops7 -noopt -loopdb -nloophits=7 2> results/abyModSTDERR/energynLoops7.txt"; 
my $job9 = "perl analyseabYmod.pl energynLoops8 -noopt -loopdb -nloophits=8 2> results/abyModSTDERR/energynLoops8.txt"; 
my $job10 = "perl analyseabYmod.pl energynLoops9 -noopt -loopdb -nloophits=9 2> results/abyModSTDERR/energynLoops9.txt"; 
my $job11 = "perl analyseabYmod.pl energynLoops10 -noopt -loopdb -nloophits=10 2> results/abyModSTDERR/energynLoops10.txt"; 
my $job12 = "perl analyseabYmod.pl energynLoops11 -noopt -loopdb -nloophits=11 2> results/abyModSTDERR/energynLoops11.txt";
my $job13 = "perl analyseabYmod.pl energynLoops12 -noopt -loopdb -nloophits=12 2> results/abyModSTDERR/energynLoops12.txt";
my $job14 = "perl analyseabYmod.pl energynLoops13 -noopt -loopdb -nloophits=13 2> results/abyModSTDERR/energynLoops13.txt";
my $job15 = "perl analyseabYmod.pl energynLoops14 -noopt -loopdb -nloophits=14 2> results/abyModSTDERR/energynLoops14.txt";
my $job16 = "perl analyseabYmod.pl energynLoops15 -noopt -loopdb -nloophits=15 2> results/abyModSTDERR/energynLoops15.txt";







#####################################################################################################

my @jobs = ($job2, $job3, $job4, $job5, $job6, $job7, $job8, $job9, $job10, $job11, $job12,
	$job13, $job14, $job15, $job16);
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
    } while($nRunning >= 12);

    StartJob($job);
	print "$nRunning\n";

	
}

############################################SUBROUTINES############################################
sub StartJob
{
	my ($job) = @_; 
	system("$job &")
}
