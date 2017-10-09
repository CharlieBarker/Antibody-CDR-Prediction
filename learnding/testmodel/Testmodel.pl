#!/usr/bin/perl
use strict;
use Carp::Assert;

open(DATA, "</home/charlie/Documents/learnding/testmodel/Redundant_LH_Combined_Chothia.txt") or die "Couldn't open file file.txt, $!";

while(my $line = <DATA>){
	my ($ACTUALpdb, $MODELpdb) = ProcessLine($line); #use subroutine below to extract file
	                                                 #names of predicted and actual PDB structures to compare
	my $ACTUALpath= "/home/charlie/Documents/abymod/DATA/abpdblib"; #specify path for the actual pdb structure 
	my $MODELpath= "/home/charlie/Documents/pdb"; #specify path for the model pdb structure 
	#LIGHT CHAIN RMSD

	my($l1cal, $l2cal, $l3cal, $l1cag, $l2cag, $l3cag) = 
		TestModel('L_ca.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb"); #testmodel subroutine calculates RSMD of ca local
	#lines 8-9 pulls the scalars specified in return (lines 48-49) 

	print "$ACTUALpdb\n\n";
	print "L1(CA)(local)  = $l1cal\n";
	print "L2(CA)(local)  = $l2cal\n";
	print "L3(CA)(local)  = $l3cal\n";
	print "L1(CA)(global) = $l1cag\n";
	print "L2(CA)(global) = $l2cag\n";
	print "L3(CA)(global) = $l3cag\n";
	#print on console with discription
	my($l1cal, $l2cal, $l3cal, $l1cag, $l2cag, $l3cag) = 
		TestModel('L_all.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	#calculate RMSD for all atoms

	print "L1(all)(local) = $l1cal\n";
	print "L2(all)(local) = $l2cal\n";
	print "L3(all)(local) = $l3cal\n";
	print "L1(all)(global)= $l1cag\n";
	print "L2(all)(global)= $l2cag\n";
	print "L3(all)(global)= $l3cag\n";
	#print onto console with description 

	#HEAVY CHAIN RMSD 

	my($H1cal, $H2cal, $H3cal, $H1cag, $H2cag, $H3cag) = 
		TestModel('H_ca.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");  
	print "H1(CA)(local)  = $H1cal\n";
	print "H2(CA)(local)  = $H2cal\n";
	print "H3(CA)(local)  = $H3cal\n";
	print "H1(CA)(global) = $H1cag\n";
	print "H2(CA)(global) = $H2cag\n";
	print "H3(CA)(global) = $H3cag\n";
	my($H1cal, $H2cal, $H3cal, $H1cag, $H2cag, $H3cag) = 
		TestModel('H_all.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	#calculate RMSD for all atoms

	print "H1(all)(local) = $H1cal\n";
	print "H2(all)(local) = $H2cal\n";
	print "H3(all)(local) = $H3cal\n";
	print "H1(all)(global)= $H1cag\n";
	print "H2(all)(global)= $H2cag\n";
	print "H3(all)(global)= $H3cag\n";
	print "\n\n"; 
	#print onto console with description 

	#print("Actual PDB file: $ACTUALpdb\n");
	#print("Model PDB file: $MODELpdb\n"); 

}


sub TestModel
{
    my($pftfile, $actual, $model) = @_; #pass the inputed scalars into a default array

    my $result = `profit -f $pftfile $actual $model`; #call external code and store output in scalar $results

 #   print $result;

    my @values = (); #create array @values 
    my @lines = split(/\n/, $result); #split on returns to produce lines 
    for my $line (@lines) #for every line in the array @lines
    {
        if($line =~ /RMS:\s+(.+)/) #search for lines that start with RMS (these are the things we are interested in). 
        {
            push @values, $1;
            #print "$1\n";
            #print "@values\n";
        }
        elsif ($line =~ /Unable to open file\s+(.+)/) 
        {
			push @values, $1;
			print "$line";
		}
		elsif ($line =~ /Error==> Failed to open: '$pftfile'\s+(.+)/) 
        {	
			push @values, $1;
			print "Error==> Unable to open the ProFit instruction file ($pftfile)";
		}
    }
    my $valueCount = @values; 
    assert($valueCount == 9, "Incorrect ProFit output. Number of RMSD values does not equal 9.");
    
    return($values[0], $values[1], $values[2],
           $values[4], $values[6], $values[8]);
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
    my $MODELpdb = "\L$seqfile" . "PRED" . ".pdb"; # make pdb name by using seqfile name and add .pdb
    my $ACTUALpdb = "\L$seqfile" . ".pdb"; # Change to lower case and add .seq
    # Now deal with getting the list of PDB files
    return($ACTUALpdb, $MODELpdb);
}

