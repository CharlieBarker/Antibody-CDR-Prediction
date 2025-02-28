#!/usr/bin/perl

#*************************************************************************
#
#   Program:    analyseabYmod
#   File:       cyclescript.pl
#   Date:       03.10.17
#   Function:   Runs abYmod over all the files listed in the protein 
#               redundancy file, excluding redundant proteins. 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	cyclescript.pl [directory you want to put pdb model in ][-abYmodflags]
#		See abYmod.pl for selection of abYmod flags. 
#   Inputs: 	Redundancy file	(specified line 21).
#   Outputs:	tmp file filled with predicted antibody models in pdb format. 
#               
#*************************************************************************
use strict;
use config; 

#swap testRedundancyFile for redundancyFile if not testing 
my $rdFile = $config::redundancyFile;
#open redundancy file or print error message.
open(DATA, "<$rdFile"); 
if(!open(DATA, "<$rdFile"))
{
    print STDERR "Error: unable to open file $rdFile\n";
    exit 1;
}

#get name of tmp folder for the current job from the beginning of @ARGV
my $tmpdir = shift(@ARGV);
#get the name of the time directory. 
my $timeDir = "$tmpdir/time";
print STDERR "$tmpdir\n";
while(my $line = <DATA>) #cycle through lines of redundancy file

{
	my ($seqfile, $exclusions, $pdbfile) = ProcessLine($line); #use subroutine below
	print("Seqfile: $seqfile\n");
	print("Exclusions: $exclusions\n");
	print("PDBfile: $pdbfile\n"); 
	my $stderrFile = "$seqfile" . "stderr.txt"; 
	#@ARGV is adding arguments specfied in the command line. 
	print STDERR "FILE NAME: $pdbfile\n"; 
	#print STDERR in its own seperate file and redirect time to another. 
	`(time $config::abymodRoot/abymod.pl -exclude=$exclusions -v=3 @ARGV $config::abseqlib/$seqfile > $tmpdir/$pdbfile 2> $timeDir/$stderrFile) 2> $timeDir/$seqfile.txt`;
	`rm -rf $timeDir/$stderrFile`;
	#print STDERR "@ARGV\n"; 
	 	
}

sub ProcessLine
{
    my($line) = @_;

    # Remove any return character at the end and all the commas
    chomp $line;
    $line =~ s/\,//g;

    # Split the line into an array of entries (split at spaces)
    my @entries = split(/\s+/, $line);

    # Deal with working out the sequence file name from the first entry
    my $seqfile = $entries[0];
    # Split into the parts before (PDB code) and after (instance number)
    # the underscore
    my @parts = split(/_/, $seqfile);
    $parts[1]--; # Decrement the instance number
    # Reassemble the parts without the underscore
    $seqfile = $parts[0] . $parts[1];
    my $pdbfile = "\L$seqfile" . "PRED" . ".pdb"; # make pdb name by using seqfile name and add .pdb
    $seqfile = "\L$seqfile" . ".seq"; # Change to lower case and add .seq
    
    # Now deal with getting the list of PDB files
    my %exclList = ();            # Create an empty hash
    foreach my $entry (@entries)  # Step through the entries
    {
        $entry =~ s/_.*//;        # Remove the underscore and anything after
        $entry = "\L$entry";      # Convert to lower case
        $exclList{$entry} = 1;    # Use PDB code as a key in the hash - this
                                  # will make it a unique list
    }

    my $exclusions = '';          # This is where we assemble the list
    foreach my $entry (keys %exclList) # For each key in the hash
    {
        $exclusions .= "$entry,"; # Add it to our list appending a comma
    }
    $exclusions =~ s/,$//;        # Remove the last comma

    return($seqfile, $exclusions, $pdbfile);
}


