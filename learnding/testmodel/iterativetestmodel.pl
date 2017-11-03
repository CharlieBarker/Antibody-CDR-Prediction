#*************************************************************************
#
#   Program:    analyseabYmod
#   File:       
#   Date:       03.10.17
#   Function:   
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#               
#*************************************************************************

use strict;
open(DATA, "</home/charlie/Documents/learnding/testmodel/TEST_Redundant_LH_Combined_Chothia.txt") or die "Couldn't open file file.txt, $!";

while(my $line = <DATA>){
   	#print "$line\n";
	my ($MODELpdb, $ACTUALpdb) = ProcessLine($line); #use subroutine below to extract file
	                                                 #names of predicted and actual PDB structures to compare
	print("Actual PDB file: $ACTUALpdb\n");
	print("Model PDB file: $MODELpdb\n"); 

}

close(DATA) || die "Couldn't close file properly";

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
    my $MODELpdb = "\L$seqfile" . "PRED" . ".pdb"; # make pdb name by using seqfile name and add .pdb
    my $ACTUALpdb = "\L$seqfile" . ".pdb"; # Change to lower case and add .seq
    return($MODELpdb, $ACTUALpdb);
}







