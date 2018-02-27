#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    abYmod
#   File:       abymod.pl
#   
#   Version:    V1.20
#   Date:       11.12.17
#   Function:   Wrapper for the abYmod program
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2013-2017
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Institute of Structural and Molecular Biology
#               Division of Biosciences
#               University College
#               Gower Street
#               London
#               WC1E 6BT
#   EMail:      andrew@bioinf.org.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#   -v[=x]                     Verbose
#   -exclude=xxxx[,xxxx[...]]  Exclude specified PDB code(s)
#   -autoexclude               Exclude where seqid = 100%
#   -k[=2]                     Keep intermediate template file
#   -cdr[=xx[,xx[...]]]        Take CDRs from template
#   -noopt | -nooptimize       Do not do EM optimization
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   19.09.13  Original
#   V1.1   10.01.14  Added -exclude and -k options
#   V1.2   11.02.14  Updated usage message as 3-letter code now allowed
#   V1.3   13.02.14  Skipped
#   V1.4   24.04.14  Added -cdr option
#   V1.4.1 25.04.14  Bug fix in passing -cdr to buildmodel.pl
#                    Also checks the sequence file has been supplied
#   V1.5   15.07.14  Bug fixes in choosetemplates.pl and buildmodel.pl
#                    Fully commented throughout
#   V1.6   17.07.14  Scoring against specified mismatched residues in 
#                    CDRs 
#   V1.7   17.07.14  Ranks the CDR templates based on similarity score
#                    Added -norank and -nopenalize options
#   V1.8   21.07.14  Added support for using MODELLER
#                    Added -modeller and -nomodeller
#   V1.9   22.07.14  MODELLER used for all mismatched loop lengths
#                    instead of just CDR-H3. 
#   V1.10  15.09.15  Skipped
#   V1.11  28.09.15  Skipped
#   V1.12  01.10.15  Added loopdb stuff
#   V1.13  02.11.15  Completed loopdb stuff
#   V1.14  04.10.16  Skipped
#   V1.18  15.12.16  Added -autoexclude
#   V1.19  23.03.17  Skipped
#   V1.20  11.12.17  Skipped
#
#*************************************************************************
use strict;

# Add the path of the executable to the library path
use FindBin;
use lib $FindBin::Bin;
# Or if we have a bin directory and a lib directory
#use Cwd qw(abs_path);
#use FindBin;
#use lib abs_path("$FindBin::Bin/../lib");
use config;
use util;
use abymod;

UsageDie() if(defined($::h));

my $seqFile = shift(@ARGV);
my $pdbFile = shift(@ARGV);

UsageDie() if($seqFile eq '');

my $binDir  = $FindBin::Bin;
$binDir =~ s/ /\\ /g;

my $tmpDir = util::CreateTempDir("abymodWrapper");
my $tplFile = "$tmpDir/ab.tpl";
my $vString = "";
$vString = "-v=$::v" if($::v > 0);
$vString .= " -q" if(defined($::q));
my $kString = (($::k >= 2)?' -k ':'');

my $xString = "";
$xString = "-exclude=$::exclude" if(defined($::exclude));

my $axString = "";
$axString = "-autoexclude" if(defined($::autoexclude));

my $noRankString = "";
$noRankString = "-norank" if(defined($::norank));

my $noPenalizeString = "";
$noPenalizeString = "-nopenalize" if(defined($::nopenalize));

my $modellerString = "";
$modellerString = "-modeller"   if(defined($::modeller));
$modellerString = "-nomodeller" if(defined($::nomodeller));

my $loopdbString = "";
$loopdbString  = "-loopdb" if(defined($::loopdb));
$loopdbString  = "-noloopdb" if(defined($::noloopdb));
$loopdbString .= " -nloophits=$::nloophits" if(defined($::nloophits));
$loopdbString .= " -loophit=$::loophit" if(defined($::loophit));

my $optString = "";
$optString = "-noopt" if(defined($::noopt) || defined($::nooptimize));

my $cdrString = "";
if(defined($::cdr))
{
    if($::cdr eq "1")
    {
        $cdrString = "-cdr";
    }
    else
    {
        $cdrString = "-cdr=$::cdr";
    }
}

# Check everything is in place
abymod::CheckFilesOrDie();

# Run choosetemplates.pl
print STDERR "SELECTING TEMPLATES...\n" if($::v >= 1);
my $exe = "$binDir/choosetemplates.pl $vString $xString $axString $noRankString $noPenalizeString $seqFile > $tplFile";
print STDERR "Running: $exe\n" if($::v >= 5);
system($exe);

# Run buildmodel.pl
print STDERR "BUILDING MODEL...\n" if($::v >= 1);
$exe = "$binDir/buildmodelrestraint.pl $optString $kString $vString $modellerString $loopdbString $cdrString $tplFile $seqFile";
$exe .= " >$pdbFile" if($pdbFile ne "");
print STDERR "Running: $exe\n" if($::v >= 5);
system($exe);

# If we are keeping the template file, make a copy
if(defined($::k))
{
    $exe = "\\cp $tplFile $seqFile.tpl";
    system($exe);
}

# Clean up
if(!defined($::k) || ($::k < 2))
{
    `\\rm -rf $tmpDir`;
}
else
{
    print "*** Intermediate files are in $tmpDir ***\n";
}


#*************************************************************************
#> UsageDie()
#  ----------
#  Print a usage message and exit
#
#  19.09.13  Original  By: ACRM
#  17.07.14  Added new options
#  28.09.15  Added -k=2
#  11.12.17  V1.10
sub UsageDie
{
    print <<__EOF;

abymod V1.20 (c) 2013-2017, Dr. Andrew C.R. Martin, UCL

Usage: abymod.pl [-v[=n]] [-exclude=xxxx[,xxxx[...]]] [-autoexclude]
                 [-k] [-cdr[=xx[,xx[...]]]] [-nopenalize] [-norank] 
                 [-modeller] [-nomodeller] [-noopt|-nooptimize]
                 [-loopdb] [-noloopdb] [-nloophits=n] [-loophit=n]
                 file.seq [file.pdb]

       -v           Verbose mode (-v=2, -v=3 for more information)
       -exclude     Exclude templates files with specified PDB code
       -autoexclude Automatically exclude templates files that match
                    at least one chain with 100% identity
       -k[=2]       Keep the intermediate template file
                    (name will be file.seq with .tpl appended)
                    If k>=2, all intermediate files will be kept
       -cdr         take CDRs from the first template file even if the 
                    framework has the correct (and suitably good) 
                    canonical.
                    -cdr       alone takes all CDRs from the first 
                               template file
                    -cdr=L1,L2 would take just L1 and L2 from the first 
                               template file
       -nopenalize  Do not apply the residue mismatch penalization
                    rules when scoring CDR templates
       -norank      Do not rank the CDR templates on sequence 
                    similarity

MODELLER and OPTIMIZATION
       -modeller    Use MODELLER to build the final model
       -nomodeller  Do not use MODELLER to build the final model even if
                    there are CDRs for which there is no template of the
                    correct length. Overrides -modeller
       -noopt       Do not run EM minimzation when not using MODELLER

LOOPDB for CDR-H3 (when not using MODELLER)
       -loopdb      Use loopdb to rebuild CDR-H3
       -noloopdb    Do not use loopdb to build CDR-H3 even if specified
                    in the template file (overrides -loopdb)
       -nloophits   Specify number of hits to extract from loop database [$config::nLoopHits]
       -loophit     Specify the loop number to use (loops are ranked
                    on energy). Default is to use the lowest energy [1].

abYmod is an antibody modelling program that makes extensive use of 
canonical information.

If any of the CDRs are of lengths not seen in the template database
and the 'modeller' variable has been set in the config file, then by
default, MODELLER will be used to build the final model. This can be
forced using -modeller or prevented using -nomodeller.

The input file contains residue numbers with one-letter or three-letter 
code amino acid names. i.e.:

L1 D                  L1 ASP
L2 I                  L2 ILE
L3 Q      --or--      L3 GLN
L4 M                  L4 MET
L5 T                  L5 THR 
L6 Q                  L6 GLN
...                   ...  

NOTE that the file must be Chothia numbered

If an output file is not specified, output will be to standard out.

__EOF

   exit 0;
}
