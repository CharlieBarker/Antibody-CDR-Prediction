package util;
#*************************************************************************
#
#   Program:    machinelearningprep
#   File:       util.pm
#   
#   Version:    V1.20
#   Date:       05.02.2018
#   Function:   General perl utilities
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#               
#*************************************************************************

use strict;

#*************************************************************************
#> PdbToSeq($loop, $path)
#  ----------------------------------------------
#  Inputs:   \scalar  $loop	Scalar containing loop name in the form
#				of 1pdb-A1-A10-4.
#	     \scalar  $path	Scalar containing path to DATA file containing
#				PDB (either DATA/abpdblib or loopdb)
# 						
#
#  returns array of amino acid one letter sequence. 
#
#  05.02.2018 by C.G.B.

sub PdbToSeq
{
	my($loop, $path) = @_;
	#path to loopdb
	my $file = "$path/$loop";
	#open file or print error
	open(DATA, "<$file"); 
	if(!open(DATA, "<$file"))
	{
	    print STDERR "Error: unable to open file $file\n";
	    exit 1;
	}
	my @res;
	#step through lines in PDB loop file
	while(my $line = <DATA>){
		my @entries = split(/\s+/, $line);
		#add the residue name and the residue number
		if ($entries[2] eq "CA"){
			push @res, "$entries[3]" . " $entries[4]" . " $entries[5]";
		}
	}
	my @residues;
	#get rid of number 
	foreach my $ele (@res){
		my @entries = split(/\s+/, $ele);
		my $code = $entries[0];
		push @residues, $code; 
	}
	my @out;
	#translate from three letter amino code to one letter 
	foreach my $ele (@residues){
		my $translatedCode = $util::throneData{$ele};
		push @out, $translatedCode;
	}
	return @out;
}

#*************************************************************************
#> uniq(@array)
#  ----------------------------------------------
#  Inputs:   \array  @array	      Any array with repeated values
#                                     to be used. Keyed by chain (L or H)
#
#  returns array with all repeated values removed.
#
#  05.02.2018 taken from https://stackoverflow.com/questions/7651/how-do-i-remove-duplicate-items-from-an-array-in-perl

sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

#*************************************************************************
#> round($number)
#  ----------------------------------------------
#  Inputs:   \scalar  $number 		Number to be rounded.
#
#  returns scalar with number rounded

sub round 
{
    my($number) = shift;
    return int($number + 0.5);
}

#*************************************************************************
#> modulus($number)
#  ----------------------------------------------
#  Inputs:   \scalar  $number 		Number.
#
#  returns scalar with modulus of number inputted 

sub modulus
{
	my($number) = @_;
	if ($number < 0){
		#square number
		my $square = $number*$number;
		#square root number
		$number = sqrt($square);
		return ($number);	
	}
	else {
		return ($number);
	}
}

#*************************************************************************
#> %mdm = ReadMDM($file)
#  ---------------------
#  Input:   string     $file    MDM file
#  Return:  hash{}{}   %mdm     Hash containing MDM scores indexed by
#                               1-letter codes
#
#  Reads a mutation similarity matrix from a file. (e.g. BLOSUM or
#  Dayhoff matrix). Returns a hash indexed by the two amino acids
#
#  17.07.14  Original   By: ACRM

sub ReadMDM
{
    my($file) = @_;

    my %mdm = ();

    if(open(my $fp, $file))
    {
        my @columns = ();
        my $firstRow = 1;
        while(<$fp>)
        {
            chomp;
            s/\#.*//;           # Remove comments
            s/^\s+//;           # Remove leading whitespace
            s/\s+$//;           # Remove trailing whitespace
            if(length)          # If there is something left
            {
                if($firstRow)
                {
                    @columns = split;
                    $firstRow = 0;
                }
                else
                {
                    my @data = split;
                    my $rowRes = shift @data;
                    foreach my $colRes (@columns)
                    {
                        $mdm{$rowRes}{$colRes} = shift @data;
                    }
                }
            }
        }
        close $fp;
    }
    else
    {
        return(undef);
    }

    return(%mdm);
}

#*************************************************************************
# 3- to 1-letter conversion
%util::throneData = 
    ('ALA' => 'A',
     'CYS' => 'C',
     'ASP' => 'D',
     'GLU' => 'E',
     'PHE' => 'F',
     'GLY' => 'G',
     'HIS' => 'H',
     'ILE' => 'I',
     'LYS' => 'K',
     'LEU' => 'L',
     'MET' => 'M',
     'ASN' => 'N',
     'PRO' => 'P',
     'GLN' => 'Q',
     'ARG' => 'R',
     'SER' => 'S',
     'THR' => 'T',
     'VAL' => 'V',
     'TRP' => 'W',
     'TYR' => 'Y');

#*************************************************************************
# amino acid hydrophobicity scale 
#  Monera et al., J. Protein Sci. 1: 319-329 (1995). Hydrophobicity index at pH 7. 
%util::hydrophobicscale = 
	('A' => 41,
	 'C' => 49, 
	 'D' => -55, 
	 'E' => -31, 
	 'F' => 100, 
	 'G' => 0, 
	 'H' => 8, 
	 'I' => 99, 
	 'K' => -23, 
	 'L' => 97,
	 'M' => 74, 
	 'N' => -28, 
	 'P' => -46, #used pH -2. 
	 'Q' => -10, 
	 'R' => -14, 
	 'S' => -5, 
	 'T' => 13, 
	 'V' => 76, 
	 'W' => 97, 
	 'Y' => 63); 

#*************************************************************************
# amino acid charges 

%util::charge = 
	('A' => 0,
	 'C' => 0, 
	 'D' => -1, 
	 'E' => -1, 
	 'F' => 0, 
	 'G' => 0, 
	 'H' => 1, 
	 'I' => 0, 
	 'K' => 1, 
	 'L' => 0,
	 'M' => 0, 
	 'N' => 0, 
	 'P' => 0, 
	 'Q' => 0, 
	 'R' => 1, 
	 'S' => 0, 
	 'T' => 0, 
	 'V' => 0, 
	 'W' => 0, 
	 'Y' => 0); 


