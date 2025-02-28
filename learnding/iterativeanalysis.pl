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
#nohup [command] & for no hangup 
#ALWAYS CHECK JOBS ARE RUNNING BY TYPING ps auxwww | grep abymod.pl  AFTER EXECUTION
#Check you are always using the right version of abymod. 
#check you are always using the right VERSION OF BUILDMODEL
#check you are always using the right REDUNDANCY FILE 
#COMMIT THIS TO GITHUB AFTER EVERY TEST
		




my $job1 = "perl analyseabYmod.pl optimum -nloophits=5 2> results/abyModSTDERR/optimum.txt";  
 
 








#####################################################################################################

my @jobs = ($job1);		
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
    } while($nRunning >= 8);

    StartJob($job);
	print "$nRunning\n";

	
}

############################################SUBROUTINES############################################
sub StartJob
{
	my ($job) = @_; 
	system("$job &")
}
