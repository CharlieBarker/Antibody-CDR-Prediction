#!/usr/bin/perl
use strict;

my $dist = "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/kinkdistance/distances.txt";
my $rdFile = "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding/rdfiles/Redundant_LH_Combined_Chothia.txt";
open(DATA, "<$rdFile"); 
if(!open(DATA, "<$rdFile"))
{
    print STDERR "Error: unable to open file $rdFile\n";
    exit 1;
}
my @finished;
while(my $line = <DATA>) #cycle through lines of redundancy file

{	
	open(DIST, "<$dist"); 
	if(!open(DIST, "<$dist"))
	{
	    print STDERR "Error: unable to open file $dist\n";
	    exit 1;
	}
	my @entries = split(/\s+/, $line);

	while(my $distance = <DIST>) #cycle through lines of DISTANCE FILE

	{
		my @element = split(/\s+/, $distance);
		my $redun = "$entries[0]";
		chomp $redun;
    		$redun =~ s/\,//g;
		my $rmsd = "$element[0]";
		$redun = "" . $redun;
		$rmsd = "" . $rmsd;
		if ($redun eq $rmsd){
			push @finished, $element[1];
		}
	}
}
foreach my $dista (@finished){
	print "$dista\n";
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
