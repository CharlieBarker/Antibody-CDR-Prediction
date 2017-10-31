#!/usr/bin/perl

use strict;
my $count = 0;
open(DATA, "</acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding/testmodel/TEST_Redundant_LH_Combined_Chothia.txt") or die "Couldn't open file file.txt, $!";
while(my $line = <DATA>) #cycle through lines of redundancy file

{
	
	my ($seqfile, $exclusions, $pdbfile) = ProcessLine($line); #use subroutine below
	print("Seqfile: $seqfile\n");
	print("Exclusions: $exclusions\n");
	print("PDBfile: $pdbfile\n"); 
	#@ARGV is adding arguments specfied in the command line. 
	my $someVariable = `/acrm/bsmhome/abymod/abymod.pl -exclude=$exclusions -v=3 -noopt @ARGV /acrm/bsmhome/abymod/DATA/abseqlib/$seqfile > /acrm/bsmhome/zcbtark/Documents/abymod-masters-project/pdb_Models/$pdbfile`;
	#system("/home/charlie/Documents/abymod/abymod.pl -exclude=$exclusions -v=3 -noopt /home/charlie/Documents/abymod/DATA/abseqlib/$seqfile > /home/charlie/Documents/pdb/$pdbfile"); #external command to run abymod in a loop
	#my $count++;     #counter to keep track of progress
	#print("$count\n");
	print @ARGV; 
	 
	
	
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







