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
		push @res, "$entries[3]" . " $entries[5]";
	}
	#remove last value (terminator)
	my $bin = pop @res;
	#remove repeated values 
	@res = uniq(@res);
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
