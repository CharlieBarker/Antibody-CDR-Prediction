#!/usr/bin/perl

#####FILE FOR CREATING TAB SEPERATED DATA TABLE#####
use strict;
#create empty arrays for all the columns of data
my @caLocal = (); 
my @caGlobal = ();
my @allLocal = ();
my @allGlobal = (); 
my @pdbName = ();
print STDERR "WRITING .XLS FILE\n";
#extract the relevant data from the output of extractRmsd.pl
while(my $line = <>) #cycle through lines of redundancy file

{
	#if line starts with H3(CA)(loca)
	if($line =~ /H3\(CA\)\(local\)\s+(.+)/)
	{
		#split on spaces
		my @elements = split(/\s+/, $line);
		#push 3rd element (RMSD value) to empty array
		push @caLocal, $elements[2]; 
		#push 4th element (pdb file name) into empty array. This
		#only needs to be done once because its the same for each one. 
		push @pdbName, $elements[3];
	}
	elsif($line =~ /H3\(CA\)\(global\)\s+(.+)/)	
	{
		my @elements = split(/\s+/, $line);
		push @caGlobal, $elements[2];
	}
	elsif($line =~ /H3\(all\)\(local\)\s+(.+)/)
	{
		my @elements = split(/\s+/, $line);
		push @allLocal, $elements[2];
	}
	elsif($line =~ /H3\(all\)\(global\)\s+(.+)/)
	{
		my @elements = split(/\s+/, $line);
		push @allGlobal, $elements[2]; 
	}
}

#create array that will become table 
my @dataTable = ('Name of PDB file', 'CDR-H3(CA) Local fit', 'CDR-H3(CA) Global fit',
		'CDR-H3(all) Local fit', 'CDR-H3(all) Global fit');
#NOTE: the largest index in an array is shown by $#name_of_Array
for my $i (0 .. $#pdbName) 
{
	push @dataTable, $pdbName[$i]; 
	push @dataTable, $caLocal[$i]; 
	push @dataTable, $caGlobal[$i]; 
	push @dataTable, $allLocal[$i]; 
	push @dataTable, $allGlobal[$i]; 
	
}
#print headings
print "@dataTable[0]\t@dataTable[1]\t@dataTable[2]\t@dataTable[3]\t@dataTable[4]\n";
#print figures 
foreach my $ele(@dataTable)
{
if ($ele =~ /.pdb/)
{

#find index of entries of array containing .pdb (the pdb files)
my( $index )= grep { $dataTable[$_] eq $ele } 0..$#dataTable;

print "$ele\t$dataTable[$index+1]\t$dataTable[$index+2]\t$dataTable[$index+3]\t$dataTable[$index+4]\n";

}
}
print STDERR "fin\n";

