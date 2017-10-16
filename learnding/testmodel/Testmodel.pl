#!/usr/bin/perl
use strict;
use Carp::Assert;
use List::MoreUtils;

open(DATA, "</home/charlie/Documents/learnding/testmodel/TEST_Redundant_LH_Combined_Chothia.txt") or die "Couldn't open file file.txt, $!";
#start counting succesful rmsd calculations for means and stats
my $successCount = 0;
my $totalCount = 0; 
while(my $line = <DATA>){
	my ($ACTUALpdb, $MODELpdb) = ProcessLine($line); #use subroutine below to extract file
	                                                 #names of predicted and actual PDB structures to compare
	my $ACTUALpath= "/home/charlie/Documents/abymod/DATA/abpdblib"; #specify path for the actual pdb structure 
	my $MODELpath= "/home/charlie/Documents/pdb"; #specify path for the model pdb structure 
	#LIGHT CHAIN RMSD

	my($l1cal, $l2cal, $l3cal, $l1cag, $l2cag, $l3cag, $valueCount, @preambleErrors) = 
		TestModel('L_ca.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb"); #testmodel subroutine calculates RSMD of ca local
	#create count to incrememnt every time RMSD is correctly calculated for every profit instruction file
	#if this count is the correct number (4) we can increment successcount.
	#this makes the success count only count proteins where every file has worked rather than just one.
	my $count = 0;
	print "$ACTUALpdb\n\n";
	#if the RMSD value count is not 9 then we've encountered an error
	#so print the error messages found in the preamble of the profit readout. 
	if($valueCount != 9)
	{
		print "ERROR\n";
		foreach (@preambleErrors) 
		{
			print "$_\n";
		}
	}
		#if value count does equal 9 increment count

	else
	{
		$count++;
	}
	print "\n";
	print "L1(CA)(local)  = $l1cal\n";
	print "L2(CA)(local)  = $l2cal\n";
	print "L3(CA)(local)  = $l3cal\n";
	print "L1(CA)(global) = $l1cag\n";
	print "L2(CA)(global) = $l2cag\n";
	print "L3(CA)(global) = $l3cag\n";
	#print on console with discription
	my($l1cal, $l2cal, $l3cal, $l1cag, $l2cag, $l3cag, $valueCount, @preambleErrors) = 
		TestModel('L_all.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	#calculate RMSD for all atoms
	if($valueCount != 9)
	{
		print "ERROR\n";
		foreach (@preambleErrors) 
		{
			print "$_\n";
		}
	}
		#if value count does equal 9 increment count

	else
	{
		$count++;
	}
	print "\n";

	print "L1(all)(local) = $l1cal\n";
	print "L2(all)(local) = $l2cal\n";
	print "L3(all)(local) = $l3cal\n";
	print "L1(all)(global)= $l1cag\n";
	print "L2(all)(global)= $l2cag\n";
	print "L3(all)(global)= $l3cag\n";
	#print onto console with description 

	#HEAVY CHAIN RMSD 

	my($H1cal, $H2cal, $H3cal, $H1cag, $H2cag, $H3cag, $valueCount, @preambleErrors) = 
		TestModel('H_ca.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	if($valueCount != 9)
	{
		print "ERROR\n";
		foreach (@preambleErrors) 
		{
			print "$_\n";
		}
	}
		#if value count does equal 9 increment count

	else
	{
		$count++;
	}
	print "\n";
	print "H1(CA)(local)  = $H1cal\n";
	print "H2(CA)(local)  = $H2cal\n";
	print "H3(CA)(local)  = $H3cal\n";
	print "H1(CA)(global) = $H1cag\n";
	print "H2(CA)(global) = $H2cag\n";
	print "H3(CA)(global) = $H3cag\n";
	my($H1cal, $H2cal, $H3cal, $H1cag, $H2cag, $H3cag, $valueCount, @preambleErrors) = 
		TestModel('H_all.pft',"$ACTUALpath/$ACTUALpdb", "$MODELpath/$MODELpdb");
	if($valueCount != 9)
	{
		print "ERROR\n";
		foreach (@preambleErrors) 
		{
			print "$_\n";
		}
	}
	#if value count does equal 9 increment count
    else
	{
		$count++;
	}
	print $count; 
	#always increment the total count on ever cycle. 
	$totalCount++;
	#if all the individual files have worked (or count = 4), increment success count
	if($count == 4)
	{
		$successCount++;
	}
	print "\n";
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
#print counts
print "RMSDs were calculated for $successCount out of a total of $totalCount proteins";

sub TestModel
{
    my($pftfile, $actual, $model) = @_; #pass the inputed scalars into a default array

    my $result = `profit -f $pftfile $actual $model`; #call external code and store output in scalar $results

 #   print $result;

    my @values = (); #create array @values 
    my @errors = (); #create array @errors (for errors in main body of readout)
    my @preambleErrors = (); #create array @preambleErrors (for errors in preamble)
    my @lines = split(/\n/, $result); #split on returns to produce lines.
    #defines scope of variable $index.
    my $index; 
    #find the index of the line starting with "Starting script:".. its the bit 
    #following this that is the interesting bit.
    #BEWARE this is going to remove the bit that says unable to read file.
    #this needs to be sorted out later. 
    for my $line1 (@lines) 
    {
		if($line1 =~ /Starting\s+(.+)/)
		{
			my $search = $line1;
			$index = List::MoreUtils::first_index {$_ eq $search} @lines;
			
		}		
	}
	#count the number of lines in profit readout
	my $lineCount = @lines; 
	#splice out the mostly irrelvant part of the profit readout to leave relevant readings
	#(@relevantOutput)
	my @relevantOutput = splice(@lines, $index, $lineCount);
	#splice out the profit preamble (entirely useless) so we have the part of the preamble
	#that contains all the initial error messages that we may want to record. 
	
	my @UselessPreamble = splice(@lines, 0, 15);
	for my $line (@lines)
	{
		#if Profit is unable to find relevant file, exit subroutine and print relevant missing file.
		if($line =~ /Unable to open file\s+(.+)/)
		{
			push @preambleErrors, $1;
		}
		elsif($line =~ /Error==>\s+(.+)/) #search for lines that start with error. 
        {
            push @preambleErrors, $1; #store in error array
        }
    }


    #next bit finds RMSDs and errors of the profit readout. 
    
    for my $line (@relevantOutput) #for every line in the array @lines
    {
        if($line =~ /RMS:\s+(.+)/) #search for lines that start with RMS (these are the things we are interested in). 
        {
            push @values, $1;
            #print "$1\n";
            #print "@values\n";
        }
        elsif($line =~ /Error==>\s+(.+)/) #search for lines that start with error. 
        {
            push @errors, $1; #store in error array
        }
               
    }
   
    #count number of RMSD values
    #this is a test to see if the RSMD calculations have gone well
    #if this is equal to 9 then they have gone flawlessly (correct assumption?)
    #if not then the @error and @preambleError arrays are returned rather than 
    #the rmsds
    my $valueCount = @values; 

	
		
    #assert($valueCount == 9, "Incorrect ProFit output. Number of RMSD values does not equal 9.");
    if($valueCount == 9)
    {
		return($values[0], $values[1], $values[2],
               $values[4], $values[6], $values[8],
               $valueCount);
    }
    else
    {
		return($errors[0], $errors[1], $errors[2],
               $errors[3], $errors[4], $errors[5],
               $valueCount, @preambleErrors);
	}
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
