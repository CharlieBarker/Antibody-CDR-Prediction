#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    readcluster
#   File:       readcluster.pl
#   Date:       22.02.18
#   Function:   reads output from clustering analysis  
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#   Usage:	add directory and what the file name begins with
#               
#*************************************************************************
use strict; 
my $path = '/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/kinkdistance'; 
my $file = 'clusteranalysis.dat';
open(DATA, "<$file");  #open
if(!open(DATA, "<$file"))
{
    	print STDERR "Error: unable to open file $file\n";
    	exit 1;
}
my @proteins0;
my @proteins1;
while(my $line = <DATA>) #go through lines
{
	if($line =~ /cluster1(.+)/) #look for lines starting with real
       	{
		@proteins0 = split(/\s/, $line)
	}
	if($line =~ /cluster1(.+)/) #look for lines starting with real
       	{
		@proteins1 = split(/\s/, $line)
	}
}
foreach my $element (@proteins0){
	$element = ProcessLine($element);
	print "$element\n"
}
##########SUBROUTINES##########
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
    my $pdbfile = "\L$seqfile" . ".pdb"; # make pdb name by using seqfile name and add .pdb
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
