#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    abYmod
#   File:       buildmodel.pl
#   
#   Version:    V1.20
#   Date:       11.12.17
#   Function:   Build an antibody model from a specified set of templates
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
#   -v[=x] Verbose
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   19.09.13  Original
#   V1.1   10.01.14  Properly truncates the structure based on the input
#                    sequence
#   V1.2   11.02.14  Added CheckTemplates() - exits if templates not
#                    correctly specified
#   V1.3   13.02.14  Skipped
#   V1.4   24.04.14  Added -cdr option. Default is to use the CDR
#                    conformations from the framework if they match the
#                    canonical. This option forces use of a CDR from the
#                    first template file.
#   V1.5   14.07.14  Fully commented. Fixed a bug in the selection of
#                    best candidate framework templates
#                    Skips comments in template file
#   V1.6   17.07.14  Scoring against specified mismatched residues in CDRs
#   V1.7   17.07.14  Ranks the CDR templates based on similarity score
#   V1.8   21.07.14  Added support for using MODELLER
#                    Added -modeller and -nomodeller options
#   V1.9   22.07.14  MODELLER used for all mismatched loop lengths
#                    instead of just CDR-H3. 
#   V1.10  13.08.15  Modified for splicepdb V2
#   V1.11  28.09.15  Added call to Tinker for optimizing the model
#   V1.12  01.10.15  Added loopdb support
#   V1.13  02.11.15  Completed loopdb supports
#   V1.14  04.10.16  Skipped
#   V1.18  15.12.16  Skipped
#   V1.19  23.03.17  Skipped
#   V1.20  11.12.17  Added constraints and restraints on loopdb selection
#                    Fixes bug in splicing CDR-H3 when this happens to be
#                    from Chain H and contains H94 or H103 messing up
#                    the renumbering
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

# Flags
$::v = (-1) if(defined($::q));
if(defined($::loophit))
{
    $::failOnError = 1;
}
else
{
    $::loophit = 1;
}

# CDRs to be taken from first template file instead of framework.
# -cdr on its own means all CDRs come from template file
# -cdr=L1,L2,L3 would take just the specified CDRs from the
# template file
my @forceTemplateCDRs = ();
if(defined($::cdr))
{
    if($::cdr eq '1')           # i.e. Just -cdr
    {
        @forceTemplateCDRs = (qw/L1 L2 L3 H1 H2 H3/);
    }
    else                        # i.e. -cdr=x,y,z
    {
        $::cdr = "\U$::cdr";
        @forceTemplateCDRs = split(/\,/, $::cdr);
    }
}

# Get template file and sequence file (if specified) from command line
my $tplFile = shift(@ARGV);
my $seqFile = ((scalar(@ARGV))?shift(@ARGV):"");

my %targetCanonicals = ();
my %lightCanonicals  = ();
my %heavyCanonicals  = ();
my @lightTemplates   = ();
my @heavyTemplates   = ();
my %CDRTemplates     = ();
my %constraints      = ();
my %restraints       = ();

my $tmpDir = util::CreateTempDir("abymod");
if(!defined($tmpDir))
{
    print STDERR "abYmod/buildmodel: Unable to create temporary directory\n";
    exit 1;
}

# Read all data from the template file
print STDERR "Reading template file..." if($::v >= 1);
ReadTemplateFile($tplFile, \%targetCanonicals, \%lightCanonicals, 
                 \%heavyCanonicals,
                 \@lightTemplates, \@heavyTemplates, \%CDRTemplates,
                 \%constraints, \%restraints);
print STDERR "done\n" if($::v >= 1);

# Check there are templates for everything
print STDERR "Checking template data..." if($::v >= 1);
if(CheckTemplates(\%targetCanonicals, 
                  \%lightCanonicals, \%heavyCanonicals,
                  \@lightTemplates, \@heavyTemplates, \%CDRTemplates))
{
    if(defined($::force))
    {
        print STDERR "\nabYmod/buildmodel continuing with errors...";
    }
    else
    {
        print STDERR "\nabYmod/buildmodel failed\n";
        exit 1;
    }
}
print STDERR "done\n" if($::v >= 1);


print STDERR "Getting best candidate templates..." if($::v >= 1);
# This is done by selecting the framework templates which contain the 
# largest number of the CDR templates
my %templateList = GetBestTemplateLists(\@lightTemplates, 
                                        \@heavyTemplates, 
                                        \%CDRTemplates);
print STDERR "done\n" if($::v >= 1);

print STDERR "Selecting best templates..." if($::v >= 1);
# If we can, we select a template that is the same for both heavy and 
# light chain. Otherwise just take the first one (which should have 
# the highest sequence ID)
my %bestTemplates = SelectBestTemplates(%templateList);
print STDERR "done\n" if($::v >= 1);

print STDERR "Selecting best CDRs..." if($::v >= 1);
# Creates a list of templates for CDRs that will be grafted in to 
# replace those from the framework
my %bestCDRs = SelectBestCDRs(\%bestTemplates, \%CDRTemplates, 
                              \@forceTemplateCDRs);
print STDERR "done\n" if($::v >= 1);

PrintResults(\%bestTemplates, \%bestCDRs) if($::v >= 1);

print STDERR "Fitting Light and Heavy templates..." if($::v >= 1);
# Fit the selected light and heavy chain templates together
my $mod1 = FitChains($tmpDir, \%bestTemplates, $seqFile);
print STDERR "done\n" if($::v >= 1);

print STDERR "Grafting CDRs..." if($::v >= 1);
# Now graft in any CDRs that need replacing
my $mod2 = GraftBestCDRs($tmpDir, $mod1, \%bestCDRs);
print STDERR "done\n" if($::v >= 1);

my $mod3;
my $mod4;
my $mod5;
my $mod6;

if($seqFile eq "")
{
    print STDERR "WARNING! No sequence file specified so not replacing sidechains\n";
    $mod6 = $mod2;
}
else
{
    $mod3 = $mod2;

    if(defined($::loopdb) &&
       !defined($::noloopdb))
    {
        print STDERR "Running LoopDB on CDR-H3..." if($::v >= 1);
        $mod3 = RunLoopdb($mod2, $::loophit, $targetCanonicals{'H3'},
                          \%constraints, \%restraints);
        print STDERR "done\n" if($::v >= 1);
    }

    if(defined($::modeller) && 
       !defined($::nomodeller) &&
       defined($::config::modeller))
    {
        # If we have forced use of loopdb with MODELLER, then use the
        # output from that
        if(defined($::loopdb) &&
           !defined($::noloopdb))
        {
            $mod2 = $mod3;
        }
        print STDERR "Running Modeller..." if($::v >= 1);
        $mod6 = RunModeller($mod2, $seqFile, $tmpDir);
        print STDERR "done\n" if($::v >= 1);
    }
    else
    {
        if(defined($::modeller) && !defined($::nomodeller))
        {
            print STDERR "WARNING! Modeller not available\n";
        }

        print STDERR "Replacing sidechains...\n" if($::v >= 1);
        $mod4 = abymod::ReplaceSidechains($mod3, $seqFile, 
                                          $config::scOrderFile, $tmpDir);
        print STDERR "...done\n" if($::v >= 1);

        print STDERR "Fixing any missing atoms...\n" if($::v >= 1);
        $mod4 = abymod::FixMissingAtoms($mod4, $tmpDir);
        print STDERR "...done\n" if($::v >= 1);

        print STDERR "Truncating structure..." if($::v >= 1);
        $mod5 = abymod::TruncateStructure($mod4, $seqFile, $tmpDir);
        print STDERR "done\n" if($::v >= 1);

        if(defined($::nooptimize) || defined($::noopt))
        {
            $mod6 = $mod5;
        }
        else
        {
            print STDERR "Optimizing model..." if($::v >= 1);
            $mod6 = abymod::OptimizeModel($mod5, $tmpDir);
            print STDERR "done\n" if($::v >= 1);
        }
    }
}


if($mod6 ne '')
{
    my $model = `cat $mod6`;
    print $model;
}

# Remove temporary directory
if(defined($::k))
{
    print STDERR "Temporary files are in $tmpDir\n";
}
else
{
    `\\rm -rf $tmpDir`;
}


#*************************************************************************
#> void PrintResults($hBestTemplates, $hBestCDRs)
#  ----------------------------------------------
#  Inputs:   \hash  $hBestTemplates   Reference to hash of f/w templates 
#                                     to be used. Keyed by chain (L or H)
#            \hash  $hBestCDRs        Reference to hash of CDR templates
#                                     to be used - where these will 
#                                     replace a CDR from the framework
#                                     template
#
#  Prints information about the selected templates for framework and CDRs
#
#  19.09.13  Original  By: ACRM
sub PrintResults
{
    my($hBestTemplates, $hBestCDRs) = @_;

    foreach my $chain (qw/L H/)
    {
        print STDERR "Framework template $chain: $$hBestTemplates{$chain}\n";
    }
    foreach my $cdr (keys %$hBestCDRs)
    {
        print STDERR "CDR template $cdr: $$hBestCDRs{$cdr}\n";
    }
}



#*************************************************************************
#> %bestCDRs = SelectBestCDRs($hBestTemplates, $hCDRTemplates, 
#                             $aForceTemplateCDRs)
#  -----------------------------------------------------------
#  Input:   \hash         $hBestTemplates     Reference to hash of the 
#                                             best f/w templates. The 
#                                             hash is keyed by the chain
#                                             (L or H) and simply 
#                                             contains the best template 
#                                             for each chain
#           \hashOfArrays $hCDRTemplates      Reference to hash of arrays
#                                             Hash is keyed by CDR label 
#                                             and array contains 
#                                             templates for that CDR
#           \string[]     $aForceTemplateCDRs Reference to array 
#                                             specifying CDRs that will 
#                                             always be taken from a CDR
#                                             template even if the 
#                                             framework already has the 
#                                             correct canonical
#  Returns: hash                              Keyed by CDR label, this 
#                                             specified replacement 
#                                             templates for CDRs
#
# Choose replacement CDRs to be grafted in
#
#  19.09.13  Original  By: ACRM
sub SelectBestCDRs
{
    my($hBestTemplates, $hCDRTemplates, $aForceTemplateCDRs) = @_;
    my %bestCDRs = ();

    foreach my $chain (qw/L H/)
    {
        # Set up CDR name array for the chain
        my @cdrs;
        if($chain eq "L")
        {
            @cdrs = qw/L1 L2 L3/;
        }
        else
        {
            @cdrs = qw/H1 H2 H3/;
        }

        foreach my $cdr (@cdrs)
        {
            # If it's in the list of CDRs that we will always take from 
            # the CDR template or this framework template does NOT appear
            # in anywhere in the list of templates for this CDR, then 
            # take the top CDR in the list
            if(util::inlist($cdr, @$aForceTemplateCDRs) || 
               !util::inlist($$hBestTemplates{$chain}, 
                             @{$$hCDRTemplates{$cdr}}))
            {
                $bestCDRs{$cdr} = $$hCDRTemplates{$cdr}[0];
            }
        }
    }
    return(%bestCDRs);
}


#*************************************************************************
#> %bestTemplates = SelectBestTemplates(%templateList)
#  ---------------------------------------------------
#  Input:   hashOfArrays   %templateList   A hash indexed by chain 
#                                          (L or H) and containing arrays
#                                          of candidate templates for 
#                                          the f/w
#  Returns: hash                           A hash indexed by chain 
#                                          (L or H) containing the 
#                                          selected 'best' template for
#                                          the frameworks
#
# If we can, we select a template that is the same for both heavy and 
# light chain. Otherwise just take the first one (which should have the 
# highest sequence ID)
#
#  19.09.13  Original  By: ACRM
sub SelectBestTemplates
{
    my (%templateList) = @_;
    my %templates;

    # Default to just choosing the first one
    $templates{'L'} = $templateList{'L'}[0];
    $templates{'H'} = $templateList{'H'}[0];

    # Now see if any of the templates are listed for both light and 
    # heavy. If so we use the first of those instead
    foreach my $template (@{$templateList{'L'}})
    {
        if(util::inlist($template, @{$templateList{'H'}}))
        {
            $templates{'L'} = $templates{'H'} = $template;
            last;
        }
    }

    return(%templates);
}



#*************************************************************************
#> %bestTemplates = GetBestTemplateLists($aLightTemplates, 
#                                        $aHeavyTemplates, $hCDRTemplates)
#  -----------------------------------------------------------------------
#  Input:   \string[]     $aLightTemplates  Reference to array listing the
#                                           light chain framework template
#                                           files
#           \string[]     $aHeavyTemplates  Reference to array listing the
#                                           heavy chain framework template
#                                           files
#           \hashOfArrays $hCDRTemplates    Reference to hash of arrays
#                                           Hash is keyed by CDR label and
#                                           array contains templates for
#                                           that CDR
#  Returns: hashOfArrays                    Hash of the best templates for
#                                           the frameworks based on having
#                                           the highest number of CDRs
#                                           from the template CDR lists
#                                           Keyed by the chain (L or H) 
#                                           and the array contains the
#                                           list
#
#  From the set of templates for the light and heavy chains, 
#
#  19.09.13  Original  By: ACRM
#  14.07.14 Fixed bugs in choosing the best templates
sub GetBestTemplateLists
{
    my ($aLightTemplates, $aHeavyTemplates, $hCDRTemplates) = @_;
    my $aTemplates = "";
    my @cdrs = ();
    my %bestTemplates = ();

    # Foreach chain, identify the templates having the most matches in
    # the lists of best CDR templates
    foreach my $chain(qw/L H/)
    {
        @{$bestTemplates{$chain}} = ();

        # Select the appropriate set of templates (light or heavy)
        # and the CDR labels depending on the chain
        if($chain eq 'L')
        {
            $aTemplates = $aLightTemplates;
            @cdrs = qw/L1 L2 L3/;
        }
        else
        {
            $aTemplates = $aHeavyTemplates;
            @cdrs = qw/H1 H2 H3/;
        }

        # Count how many of the CDR templates are present in each template
        my $bestMatches=0;
        foreach my $template (@$aTemplates)
        {
            # Step through the CDRs to see how many match in this
            # template
            my $nMatches = 0;
            foreach my $cdr (@cdrs)
            {
                if(util::inlist($template, @{$$hCDRTemplates{$cdr}}))
                {
                    $nMatches++;
                }
            }
            
            # Obtain an array of the best matching templates

            # If this template has the best number of matches then add it 
            # to the array of matches for this chain. If it has more than 
            # the current best number of matches, reset the best number,
            # clear the list and add this one to the cleared list.
            if($nMatches == $bestMatches)
            {
                push @{$bestTemplates{$chain}}, $template;
            }
            elsif($nMatches > $bestMatches)
            {
                $bestMatches = $nMatches;
                @{$bestTemplates{$chain}} = ();
                push @{$bestTemplates{$chain}}, $template;
            }
        }
    }
    return(%bestTemplates);
}




#*************************************************************************
#> void ReadTemplateFile($tplFile, $hTargetCanonicals, $hLightCanonicals, 
#                        $hHeavyCanonicals, $aLightTemplates, 
#                        $aHeavyTemplates, $hCDRTemplates,
#                        $hConstraints, $hRestraints)
#  ----------------------------------------------------------------------
#  Input:    string        $tplFile           Template filename
#  Output:   \hash         $hTargetCanonicals Reference to hash keyed by CDR
#                                             label specifying the canonical 
#                                             for each CDR
#            \hashHash     $hLightCanonicals  Reference to hash of hashes
#                                             keyed first on the light f/w
#                                             template and second on the CDR
#                                             containing the canonical for
#                                             each CDR
#            \hashHash     $hHeavyCanonicals  Reference to hash of hashes
#                                             keyed first on the heavy f/w
#                                             template and second on the CDR
#                                             containing the canonical for
#                                             each CDR
#            \string[]     $aLightTemplates   Reference to array of light
#                                             chain template files
#            \string[]     $aHeavyTemplates   Reference to array of heavy
#                                             chain template files
#            \hashOfArrays $hCDRTemplates     Reference to hash of arrays
#                                             specifying the template files
#                                             for each CDR. The key to the 
#                                             hash is the CDR label and the
#                                             referenced array contains all
#                                             the templates for that CDR.
#            \hash         $hConstraints      Reference to hash of constraints
#            \hash         $hRestraints       Reference to hash of restraints
#
# This reads the template file that is generated by choosetemplates.pl
#
#  19.09.13 Original  By: ACRM
#  15.07.14 Skips comments
#  11.12.17 Added constraints and restraints
sub ReadTemplateFile
{
    my ($tplFile, $hTargetCanonicals, $hLightCanonicals, 
        $hHeavyCanonicals, $aLightTemplates, $aHeavyTemplates,
        $hCDRTemplates, $hConstraints, $hRestraints) = @_;

    my $lt = ""; # Stores the light template - also is a state indicator
    my $ht = ""; # Stores the heavy template - also is a state indicator

    if(open(my $fh, $tplFile))
    {
        my $line = 0;
        while(<$fh>)
        {
            $line++;
            chomp;
            s/\#.*//; # 15.07.14 Skip comments

            if(/TARGETCANONICAL:\s+(.*)\s+(.*)/)
            {
                $lt = "";
                $ht = "";
                $$hTargetCanonicals{$1} = $2;
            }
            if(/LIGHTTEMPLATE:\s+(.*)/)
            {
                $lt = $1;
                $ht = "";
                push @$aLightTemplates, $lt;
            }
            if(/HEAVYTEMPLATE:\s+(.*)/)
            {
                $lt = "";
                $ht = $1;
                push @$aHeavyTemplates, $ht;
            }
            if(/TEMPLATECANONICAL:\s+(.*)\s+(.*)/)
            {
                if($lt ne "")
                {
                    $$hLightCanonicals{$lt}{$1} = $2;
                }
                elsif($ht ne "")
                {
                    $$hHeavyCanonicals{$ht}{$1} = $2;
                }
                else
                {
                    util::Die("TEMPLATECANONICAL specified without associated LIGHTTEMPLATE or HEAVYTEMPLATE at line $line");
                }
            }
            if(/CDRTEMPLATE:\s+(.*)\s+(.*)/)
            {
                my $cdr = $1;
                my $tpl = $2;

                $lt = "";       # 14.07.14 Added these
                $ht = "";

                push @{$$hCDRTemplates{$1}}, $tpl;
            }
            if(/USEMODELLER/)
            {
                $::modeller = 1;
            }
            if(/USELOOPDB/)
            {
                $::loopdb = 1;
            }
            if(/LOOPDBHITS:\s+(\d*)/)
            {
                $::config::nLoopHits = $1;
            }
            if(/CONSTRAINT:\s+([LH]\d+[A-Za-z]?)\s+([LH]\d+[A-Za-z]?)\s+(\d+\.?\d*)\s+(\d+\.?\d*)/)
            { #               res1                 res2                 mindist       maxdist
                $$hConstraints{"$1:$2"} = "$3-$4";
            }
            if(/RESTRAINT:\s+([LH]\d+[A-Za-z]?)\s+([LH]\d+[A-Za-z]?)\s+(\d+\.?\d*)\s+(\d+\.?\d*)/)
            { #              res1                 res2                 dist          weight
                $$hRestraints{"$1:$2"} = "$3:$4";
            }
        }
        close $fh;
    }
}


#*************************************************************************
#> $model = FitChains($tmpDir, $hBestTemplates, $seqFile)
#  ------------------------------------------------------
#  Inputs:   string   $tmpDir          Temporary working directory 
#                                      (already created)
#            \hash    $hBestTemplates  Reference to hash containing the
#                                      selected templates for the two 
#                                      chains. Keyed by chain (L or H)
#            string   $seqFile         The target sequence file
#  Returns:  string                    Full path to resulting model
#
#  Fits the light and heavy chains together using external program.
#  The algorithm used to choose the structure from which to choose the
#  packing angle is as follows:
#  Assume we have parents AL-AH and BL-BH and that we have taken AL and BH
#  We look at the AH-H sequence identity and the BL-L sequence identity
#  and select the packing angle from the higher of these.
#
#  19.09.13  Original  By: ACRM
#  15.12.16  If both chains come from the same file, now uses pdbgetchain
#            to copy just the L and H chains in case the template has
#            antigen etc.
#  15.12.16  [fixpackingangle] Previously always took the packing angle 
#            from the file providing the light chain. Now takes it from
#            light or heavy depending which other chain is a better match
sub FitChains
{
    my($tmpDir, $hBestTemplates, $seqFile) = @_;
    my $light = $$hBestTemplates{'L'};
    my $heavy = $$hBestTemplates{'H'};
    my $outfile = "$tmpDir/mod1.pdb";

    if($light eq $heavy)
    {
        my $exe = "$config::bindir/pdbgetchain L,H ";
        my $infile = "$config::abpdblib/$light" . $config::pdbExt;
        $exe .= " $infile $outfile";

        util::RunCommand($exe);
    }
    else
    {
        # Set so the default is to inherit from the template that contributes
        # the light chain
        my $lightSeqID = 0;
        my $heavySeqID = 1;

        if($seqFile ne '')
        {
            my $lightTemplate = "$config::abseqlib/$light" . $config::seqExt;
            my $heavyTemplate = "$config::abseqlib/$heavy" . $config::seqExt;

            # Note that we calculate against the opposite chain - i.e. the
            # one that we are NOT using for this chain
            $lightSeqID = abymod::CalcSeqID($heavyTemplate, $seqFile, 'L');
            $heavySeqID = abymod::CalcSeqID($lightTemplate, $seqFile, 'H');
        }

        my $exe = "$config::bindir/fitlhpdb -s";
        if($lightSeqID > $heavySeqID) 
        {
            # BL/BH has a better overall score so we take the angle from B
            # which contributes the heavy chain
            $exe .= " H:$config::abpdblib/$heavy" . $config::pdbExt;
            $exe .= " L:$config::abpdblib/$light" . $config::pdbExt;
        }
        else
        {
            # AL/AH has a better overall score so we take the angle from A
            # which contributes the light chain
            $exe .= " L:$config::abpdblib/$light" . $config::pdbExt;
            $exe .= " H:$config::abpdblib/$heavy" . $config::pdbExt;
        }
        $exe .= " $outfile";
        
        util::RunCommand($exe);
    }
    return($outfile);
}


#*************************************************************************
#> $model = GraftBestCDRs($tmpDir, $mod1, $hBestCDRs)
#  --------------------------------------------------
#  Inputs:   string   $tmpDir          Temporary working directory 
#                                      (already created)
#            string   $mod1            Current (framework) model
#            \hash    $hBestCDRs       Templates for CDRs to be grafted
#                                      in. Keyed by CDR label.
#  Returns:  string                    Full path to new model
#
#  Grafts in the replacement CDRs using an external program
#
#  19.09.13  Original  By: ACRM
#  13.08.15  Modified for splicepdb V2
sub GraftBestCDRs
{
    my($tmpDir, $mod1, $hBestCDRs) = @_;
    my $inFile  = $mod1;

    foreach my $cdr (keys %$hBestCDRs)
    {
        my $outFile = $inFile . "_$cdr";

        my $startres = $config::cdrDefs{$cdr}[0];
        my $stopres  = $config::cdrDefs{$cdr}[1];
        my $template = $$hBestCDRs{$cdr};
        my $loopfile = "$config::abpdblib/$template" . $config::pdbExt;

        my $exe = "$config::bindir/splicepdb";
#       splicepdb V1.x took the same residue range for framework and loop
#       $exe .= " $startres $stopres $loopfile $inFile $outFile";
#       splicepdb V2.x takes separate residue ranges for framework and loop
        $exe .= " $startres $stopres $loopfile $startres $stopres $inFile $outFile";

        if($::v >= 2)
        {
            print STDERR "\n...splicing $startres-$stopres from $loopfile into $inFile\n";
        }

        util::RunCommand($exe);

        $inFile = $outFile;
    }

    return($inFile);
}


#*************************************************************************
#> int CheckTemplates($hTargetCanonicals, 
#                     $hLightCanonicals, $hHeavyCanonicals,
#                     $hLightTemplates, $hHeavyTemplates, $hCDRTemplates)
#  -----------------------------------------------------------------------
#  Input:    \hash         $hTargetCanonicals Reference to hash keyed by CDR
#                                             label specifying the canonical 
#                                             for each CDR
#            \hashHash     $hLightCanonicals  Reference to hash of hashes
#                                             keyed first on the light f/w
#                                             template and second on the CDR
#                                             containing the canonical for
#                                             each CDR
#            \hashHash     $hHeavyCanonicals  Reference to hash of hashes
#                                             keyed first on the heavy f/w
#                                             template and second on the CDR
#                                             containing the canonical for
#                                             each CDR
#            \string[]     $aLightTemplates   Reference to array of light
#                                             chain template files
#            \string[]     $aHeavyTemplates   Reference to array of heavy
#                                             chain template files
#            \hashOfArrays $hCDRTemplates     Reference to hash of arrays
#                                             specifying the template files
#                                             for each CDR. The key to the 
#                                             hash is the CDR label and the
#                                             referenced array contains all
#                                             the templates for that CDR.
#
#  Returns:  int                              Error number
#                                             0   - OK
#                                             |1  - Missing target canonical
#                                             |2  - Missing template CDR
#                                             |4  - No light chain templates
#                                             |8  - No heavy chain templates
#
#  Checks that all data structures have been populated from the
#  template file Prints an error message for each error and returns a
#  integer value which results from ORing together the error flags.
#
#  19.09.13  Original  By: ACRM
sub CheckTemplates
{
    my($hTargetCanonicals, $hLightCanonicals, $hHeavyCanonicals,
       $aLightTemplates, $aHeavyTemplates, $hCDRTemplates) = @_;

    my $error = 0;
    my $errorString = "";

    foreach my $cdr (qw/L1 L2 L3 H1 H2 H3/)
    {
        if(!defined($$hTargetCanonicals{$cdr}))
        {
            $errorString .= "No target canonical defined for CDR $cdr\n";
            $error |= 1;
        }
    }
    foreach my $cdr (qw/L1 L2 L3 H1 H2 H3/)
    {
        if(!defined($$hCDRTemplates{$cdr}))
        {
            $errorString .= "No template CDR found for CDR $cdr\n";
            $error |= 2;
        }
    }
    if(@$aLightTemplates == 0)
    {
        $errorString .= "No light chain framework templates defined\n";
        $error |= 4;
    }
    if(@$aHeavyTemplates == 0)
    {
        $errorString .= "No heavy chain framework templates defined\n";
        $error |= 8;
    }

    if($error)
    {
        print STDERR "\n" if(defined($::v));
        print STDERR $errorString;
    }
    return($error);
}


#*************************************************************************
#> $file = RunModeller($templatePDB, $seqFile2, $tmpDir)
#  ----------------------------------------------------
#  Input:   $string    $templatePDB   Full path to template PDB file
#           $string    $seqFile       Full path to sequence file
#           $string    $tmpDir        Path to temporary directory
#  Returns: $string                   Final model
#
#  Build a model using MODELLER
#
#  21.07.14  Original   By: ACRM
sub RunModeller
{
    my($templatePDB, $seqFile, $tmpDir) = @_;
    my($alnFile, $hLTargetLookup, $hHTargetLookup) =
        WriteModellerAlignment($templatePDB, $seqFile, $tmpDir);

    my $topFile = WriteModellerControl($alnFile, $tmpDir);
    # Make a copy of the template PDB file 
    `cp $templatePDB $tmpDir/0tpl.pdb`;
    `(cd $tmpDir; $config::modeller $topFile)`;
    my $model = "$tmpDir/target.B99990001.pdb";
    my $finalPDB = RenumberModellerPDB($model, $hLTargetLookup,
                                       $hHTargetLookup, $tmpDir);
    return($finalPDB);
}

#*************************************************************************
#> @lookupArray = InvertLookup($hHash)
#  -----------------------------------
#  Input:   \hash   $hHash    Hash indexed by residue label with values
#                             being sequential positions in the sequence
#                             (1-based)
#  Return:  array             Array indexed by position in sequence 
#                             (1-based) and containing the residue labels
#
#  Starts with a hash indexed by residue IDs and pointing to the linear
#  position in the sequence and returns an array the other way round.
#
#  21.07.14  Original   By: ACRM
sub InvertLookup
{
    my($hHash) = @_;
    my @lookup = ();
    foreach my $id (keys %$hHash)
    {
        if($$hHash{$id} > (-1))
        {
            $lookup[$$hHash{$id}] = $id;
        }
    }
    return(@lookup);
}

#*************************************************************************
#> $file = RenumberModellerPDB($model, $hLTargetLookup, $hHTargetLookup, $tmpDir)
#  ------------------------------------------------------------------------------
#  Input:   string  $model     Full path to PDB file
#           \hash   $hLTargetLookup  Reference to hash indexed by residue
#                                    label and pointing to linear position
#                                    in the sequence for the Light chain
#           \hash   $hHTargetLookup  Reference to hash indexed by residue
#                                    label and pointing to linear position
#                                    in the sequence for the Heavy chain
#           string  $tmpDir          Path to temporary directory
#  Return:  string                   Renumbered PDB file
#
#  Renumbers a PDB file using the numbering that appears in the two lookup
#  hashes. This is used to renumber the model built by MODELLER. MODELLER
#  numbers all the residues sequentially, but with different chain labels
#  (A and B) for the light and heavy chain. This uses the numbering from
#  the original sequence file and applies that to the PDB file.
#
#  21.07.14  Original   By: ACRM
sub RenumberModellerPDB
{
    my($model, $hLTargetLookup, $hHTargetLookup, $tmpDir) = @_;

    my @hLookup = InvertLookup($hHTargetLookup);
    my @lLookup = InvertLookup($hLTargetLookup);
    my $results = "";
    my $lastLightResnum = (-1);

    if(open(my $fpIn, $model))
    {
        while(my $line=<$fpIn>)
        {
            if(($line =~ /^ATOM  /) || ($line =~ /^TER   /))
            {
                my $pt1   = substr($line, 0, 21);
                my $chain = substr($line, 21, 1);
                my $resnum= substr($line, 22, 4);
                my $pt2   = substr($line, 27);
                
                my $resid = substr($line, 21, 6);
                $resid    =~ s/\s//g;
                
                my $newResid = $resid;
                if($chain eq "A")
                {
                    $newResid = $lLookup[$resnum];
                    $lastLightResnum = $resnum;
                }
                elsif($chain eq "B")
                {
                    $newResid = $hLookup[$resnum - $lastLightResnum];
                }
                
                $newResid = util::PadResID($newResid);
                
                $results .= $pt1.$newResid.$pt2;
            }
            else
            {
                $results .= $line;
            }

        }
        close($fpIn);
    }
    
    # And write the resulting model
    my $outFile = "$tmpDir/model.pdb";
    if(open(my $fpOut, ">$outFile"))
    {
        print $fpOut $results;
        close($fpOut);
    }
    else
    {
        print STDERR "ERROR! Unable to write $outFile";
        exit 1;
    }

    return($outFile);
}

#*************************************************************************
#> $modFile = WriteModellerControl($alnFile, $tmpDir)
#  --------------------------------------------------
#  Input:   string   $alnFile    Full path to alignment file
#           string   $tmpDir     Path to temporary directory
#  Return:  string               Full path to the .top file used to
#                                control MODELLER
#
#  Creates a .top file for running MODELLER
#
#  21.07.14  Original   By: ACRM
sub WriteModellerControl
{
    my($alnFile, $tmpDir) = @_;
    my $controlFile = "$tmpDir/mod1.top";
    if(open(my $topFp, ">$controlFile"))
    {
        print $topFp <<__EOF;
INCLUDE

SET ATOM_FILES_DIRECTORY = '$tmpDir'
SET PDB_EXT = '.pdb'
SET STARTING_MODEL = 1
SET ENDING_MODEL = 1
SET DEVIATION = 0
SET KNOWNS = 'template'
SET HETATM_IO = off
SET WATER_IO = off
SET HYDROGEN_IO = off

SET ALIGNMENT_FORMAT = 'PIR'
SET SEQUENCE = 'target'
SET ALNFILE = 'mod1_aln.pir'
CALL ROUTINE = 'model'

__EOF
        close($topFp);
    }

    return($controlFile);
}


#*************************************************************************
#> $alnFile = BuildModellerAlignment($templatePDB, $seqFile, $tmpDir)
#  ------------------------------------------------------------------
#  Input:   string   $templatePDB     Full path to template PDB file
#           string   $seqFile         Full path to target sequence file
#           string   $tmpDir          Path to temporary directory
#  Return:                            Full path to MODELLER alignment file
#
#  Builds the PIR format sequence alignment file for MODELLER
#
#  21.07.14  Original   By: ACRM
sub WriteModellerAlignment
{
    my($templatePDB, $targetSequenceFile, $tmpDir) = @_;

    my %uniqueLabels = ();

    # Extract the sequence from the target sequence file and from the
    # template PDB file
    my %targetHash   = util::GetSequenceHash($targetSequenceFile, 0, '');
    my %templateHash = util::GetPDBSequenceHash($templatePDB, '');
    util::FindUniqueLabels(\%uniqueLabels, \%targetHash);
    util::FindUniqueLabels(\%uniqueLabels, \%templateHash);

    # Open the MODELLER PIR alignment file
    my $modFile = "$tmpDir/mod1_aln.pir";
    my $modFp;
    if(!open($modFp, ">$modFile"))
    {
        print STDERR "ERROR! Unable to write $modFile\n";
        exit 1;
    }

    # Generate the target sequence
    my $partSequence;
    my $hLTargetLookup;
    my $hHTargetLookup;
    my $hJunkHash;

    # Generate the 1-letter code sequence for the target sequence
    # Light then heavy chain
    ($partSequence, $hJunkHash, $hLTargetLookup) = 
        util::GenerateSequence(\%uniqueLabels, 'L', \%targetHash);
    my $targetSequence = $partSequence . "/";

    ($partSequence, $hJunkHash, $hHTargetLookup) = 
        util::GenerateSequence(\%uniqueLabels, 'H', \%targetHash);
    $targetSequence .= $partSequence;

    # Generate the 1-letter code sequence for the template sequence
    # Light then heavy chain
    my %lookup;
    ($partSequence, $hJunkHash, $hJunkHash) =
        util::GenerateSequence(\%uniqueLabels, 'L', \%templateHash);
    my $templateSequence .= $partSequence . "/";
    ($partSequence, $hJunkHash, $hJunkHash) = 
        util::GenerateSequence(\%uniqueLabels, 'H', \%templateHash);
    $templateSequence .= $partSequence;

    # Find the first and last residues in the template PDB file
    my ($firstRes, $firstChain, $lastRes, $lastChain) = 
        GetResidueRange($templatePDB);

    # Write the sequence alignment file
    print $modFp ">P1;target\n";
    print $modFp "sequence:::::::::\n";
    util::PrettyPrint($modFp, $targetSequence, 60, '*');
    print $modFp ">P1;template\n";
    print $modFp "structureX:0tpl:$firstRes:$firstChain:$lastRes:$lastChain:template::0.00:0.00\n";
    util::PrettyPrint($modFp, $templateSequence, 60, '*');

    close($modFp);
    return($modFile, $hLTargetLookup, $hHTargetLookup);
}


#*************************************************************************
#> ($firstRes, $firstChain, $lastRes, $lastChain) = 
#      GetResidueRange($pdbFile)
#  ------------------------------------------------
#  Input:   string    $pdbFile    Full path to PDB file
#  Returns: string    $firstRes   First residue label
#           string    $firstChain First chain label
#           string    $lastRes    Last residue label
#           string    $lastChain  Last chain label
#
#  Finds the first and last residue in a PDB file. This is needed for the
#  MODELLER alignment file.
#
#  21.07.14 Original   By: ACRM
sub GetResidueRange
{
    my($pdbFile) = @_;

    my $firstRes   = '';
    my $firstChain = '';
    my $lastRes    = '';
    my $lastChain  = '';

    if(open(my $fp, $pdbFile))
    {
        while(my $line = <$fp>)
        {
            my $atom = substr($line, 12, 4);
            if($atom eq ' CA ')
            {
                my $thisChain = substr($line, 21, 1);
                my $resnum = substr($line, 22, 4);
                my $insert = substr($line, 26, 1);
                my $resID = $resnum . $insert;
                $resID =~ s/\s//g;

                if(($firstRes eq '') && ($firstChain eq ''))
                {
                    $firstChain = $thisChain;
                    $firstRes   = $resID;
                }
                $lastChain = $thisChain;
                $lastRes   = $resID;
            }            
        }
        close($fp);
    }
    return($firstRes, $firstChain, $lastRes, $lastChain);
}


#*************************************************************************
# Passed the PDB file, the hit number we want to use and the loop length.
# If the hit number is zero, then we find the lowest clash energy loop.
sub RunLoopdb
{
    my ($inPDB, $loophit, $loopLength, $hConstraints, $hRestraints) = @_;
    my $nHits = $config::nLoopHits;
    # Get the best fitting hits from the database
    $nHits = $::nloophits if(defined($::nloophits));
    my $exe = "$config::bindir/scanloopdb -n $nHits -l $loopLength $config::loopData $inPDB";
    my $hitsOut = util::RunCommand($exe);
    my @hits    = split(/\n/, $hitsOut);

    # Build each and sort based on energy
    @hits = SortSplicedLoops($inPDB, 'H3', \@hits, $hConstraints, $hRestraints);

    # Obtain the specified loop
    my $loopID        = $hits[$loophit-1]; # Minus 1 because we count loop hits from 1
    my @theChosenLoop = split(/\-/, $loopID);

    if($::failOnError)
    {
        my $loopFile = "$config::loopDataPDB/$loopID";
        if(! -e $loopFile)
        {
            print STDERR "*** Error: The loop PDB file selected with -loophit does not exist: $loopID ***\n";
            exit 1;
        }
    }

    # Now we splice the chosen one into the model
    my $outPDB = SpliceLoop($inPDB, 'H3', \@theChosenLoop);

    return($outPDB);
}

#*************************************************************************
#> @hits = SortSplicedLoops($inPDB, 'H3', \@hits, \%constraints,
#                           \%restraints)
#  ------------------------------------------------------------
#  11.12.17 @hits is now a reference ($aHits) and added $hConstraints and
#           $hRestraints
#           $hConstraints is a reference to a hash of minimum and maximum
#           distances indexed by a pair of residue IDs. e.g.
#              $$hConstraints{"H80:H65"} = "10.0:12.0";
#           $hRestraints is a reference to a hash of distances and weights
#           indexed by a pair of residue IDs. e.g.
#              $$hRestraints{"H80:H65"} = "10.0:2.0";
#           Note that Constraints are absolute. Loops that do not satisfy
#           a constraint will be rejected, so you may end up with no
#           satisfactory loops.
#           If Restraints are used then the energy is a weighted average
#           of the clash energy and a deviation from the optimum distance
#           squared.
sub SortSplicedLoops
{
    my($inPDB, $cdr, $aHits, $hConstraints, $hRestraints) = @_;
    my @loopIDs    = ();
    my @energies   = ();

    foreach my $record (@$aHits)
    {
        my @fields = split(/\s+/, $record);
        my $loopID = "$fields[0]-$fields[1]-$fields[2]-$fields[3]";
        my $loopFile = "$config::loopDataPDB/$loopID";
        my $energy   = 1.0e100;
        if(! -e $loopFile)
        {
            $loopID .= " ! - loop database file missing";
        }
        else
        {
            my $splicedPDB = SpliceLoop($inPDB, 'H3', \@fields);
            my $ok = 1;
            if(scalar(keys %$hConstraints)) # If there are any constraints
            {
                $ok = CheckConstraints($splicedPDB, $hConstraints);
            }

            if($ok)
            {
                $energy        = CalcLoopEnergy($splicedPDB, 'H3');
                if(scalar(keys %$hRestraints)) # If there are any restraints
                {
                    $energy  = ApplyRestraintEnergy($splicedPDB, $energy, $hRestraints);
                }
            }
            else
            {
                $loopID .= " ! - constraints were not satisfied";
            }
        }

        push @loopIDs,  $loopID;
        push @energies, $energy;
    }

    # Index sort the energies array
    my @idx = sort { $energies[$a] <=> $energies[$b] } 0..$#energies;
    # Print and store the sorted results
    my @sortedHits = ();
    foreach my $pos (@idx)
    {
        print STDERR "$loopIDs[$pos] $energies[$pos]\n";
        push @sortedHits, $loopIDs[$pos];
    }

    return(@sortedHits);
}

#*************************************************************************
#> $energy     = CalcLoopEnergy($splicedPDB, 'H3')
#  -----------------------------------------------
#  11.04.16 Added -p eparams.dat to the clashcalc options
sub CalcLoopEnergy
{
    my($pdbFile, $cdr) = @_;
    my $startRes = $config::cdrDefs{$cdr}[0];
    my $stopRes  = $config::cdrDefs{$cdr}[1];
    my $exe      = "$config::bindir/clashcalc -p $config::mmDataDir/eparams.dat $startRes $stopRes $pdbFile";
    my $result   = util::RunCommand($exe);
    my ($junk, $energy) = split(/\s+/, $result);
    return($energy);
}

#*************************************************************************
#> $outPDB = SpliceLoop($inPDB, $cdr, \@theChosenLoop)
#  ---------------------------------------------------
sub SpliceLoop
{
    my($inPDB, $cdr, $aTheChosenLoop) = @_;
    my $outPDB       = $inPDB . "_${cdr}-" . $$aTheChosenLoop[0];
    my $outPDBtmp    = $inPDB . "_${cdr}-" . $$aTheChosenLoop[0] . "-tmp";
    my $startResFW   = $config::cdrDefs{$cdr}[0];
    my $stopResFW    = $config::cdrDefs{$cdr}[1];
    my $startResLoop = $$aTheChosenLoop[1];
    my $stopResLoop  = $$aTheChosenLoop[2];
    my $loopFile     = $config::loopDataPDB . "/" . 
                       join('-', @$aTheChosenLoop[0..3]);

    if(! -e $loopFile)
    {
        print STDERR "*** Loop file is missing from database: $loopFile ***\n";
        print STDERR "*** CDR-H3 will be modelled using closest available length ***\n";
        return($inPDB);
    }

    # splicepdb V2.x 
    my $exe = "$config::bindir/splicepdb -l -c X";
    $exe   .= " $startResLoop $stopResLoop $loopFile";
    $exe   .= " $startResFW $stopResFW $inPDB $outPDBtmp";
    if($::v >= 2)
    {
        print STDERR "\n...splicing $startResLoop-$stopResLoop from $loopFile into CDR $cdr of $inPDB\n";
    }
    util::RunCommand($exe);

    # Renumber with standard loop numbering
    $exe  = "$config::bindir/renumabloop -c $cdr $outPDBtmp $outPDB";

    if($::v >= 2)
    {
        print STDERR "\n...renumbering the new loop\n";
    }
    util::RunCommand($exe);

    return($outPDB);
}


#*************************************************************************
#> BOOL CheckConstraints($splicedPDB, $hConstraints)
#  -------------------------------------------------
sub CheckConstraints
{
    my($splicedPDB, $hConstraints) = @_;

    my $program = "$config::bindir/calcpdbdistance ";
    foreach my $key (keys %$hConstraints)
    {
        if($::v >= 2)
        {
            print STDERR "Applying constraint: $key Range: $$hConstraints{$key}\n";
        }

        # Extract the range
        my($minDist, $maxDist) = split(/\-/, $$hConstraints{$key});

        # Calculate the observed distance
        my $respair = $key;
        $respair    =~ s/:/ /;
        my $exe = "$program $respair $splicedPDB";
        my $obsDistance = util::RunCommand($exe);
        chomp $obsDistance;

        if($obsDistance ne "")
        {
            if(($obsDistance < $minDist) || ($obsDistance > $maxDist))
            {
                return(0);
            }
        }
    }

    return(1);
}

#*************************************************************************
#> REAL ApplyRestraintEnergy($splicedPDB, $energy, $hRestraints)
#  -------------------------------------------------------------
#  This calculates a total energy by calculating a weighted average of the
#  input energy and the restraint 'energies'
#  This is calculated as
#     E_{tot} = E + \sum{w_i \times (d_i-D_i)^2}
#               --------------------------------
#                          W_{tot}
#  where:
#  E is the clash energy
#  d_i is the observed distance for restraint i
#  D_i is the optimum distance for restraint i
#  W_{tot} is the total of the weights (the input energy always has a 
#     weight of 1.0):
#     W_{tot} = \sum w_i + 1.0
#  w_i is the weight of restraint i
#
sub ApplyRestraintEnergy
{
    my($splicedPDB, $energy, $hRestraints) = @_;

    my $program = "$config::bindir/calcpdbdistance ";
    my $eTotal = $energy;
    my $wTotal = 1;
    foreach my $key (keys %$hRestraints)
    {
        # Calculate the observed distance
        my $respair = $key;
        $respair    =~ s/:/ /;
        my $exe = "$program $respair $splicedPDB";
        my $obsDistance = util::RunCommand($exe);
        chomp $obsDistance;

        if($obsDistance eq "")
        {
            $obsDistance = 1e100;
        }

        my($optDistance, $weight)  = split(/:/, $$hRestraints{$key});
        my $deltaDist = ($obsDistance-$optDistance);
        $eTotal += $weight * $deltaDist * $deltaDist;
        $wTotal += $weight;
    }

    return($eTotal / $wTotal);
}

#*************************************************************************
#> void UsageDie()
#  ---------------
#  Prints a usage message and exits
#
#  19.09.13  Original  By: ACRM
#  11.12.17  V1.20
sub UsageDie
{
    print <<__EOF;

abYmod V1.20 buildmodel (c) 2013-2017, Dr. Andrew C.R. Martin, UCL

Usage: ./buildmodel.pl [-k] [-v[=x]] [-force] [-cdr[=xx[,xx[...]]]] 
                       [-modeller] [-nomodeller] 
                       [-loopdb] [-noloopdb] [-loophit=nn] [-nloophits=nn]
                       [-nooptimize|-noopt] file.tpl [file.seq] > file.pdb
       -v[=x]      Verbose
       -k          Keep intermediate files directory
       -force      Continue even though there are errors in the 
                   template file
       -cdr        take CDRs from the first CDR template file even if the 
                   framework has the correct (and high scoring) 
                   canonical. 
                   -cdr       alone takes all CDRs from the first CDR 
                              template file
                   -cdr=L1,L2 would take just L1 and L2 from the first 
                              template file
       -modeller   Use MODELLER to build the final model
       -nomodeller Don't use MODELLER to build the final model even if
                   specified in the template file (overrides -modeller)
       -loopdb     Use loopdb to rebuild CDR-H3
       -noloopdb   Don't use loopdb to build CDR-H3 even if specified
                   in the template file (overrides -loopdb)
       -loophit    Specify the rank of the loop database hit we wish to use [1]
       -nloophits  Specify number of hits from loop database [$config::nLoopHits]
       -nooptimize Don't run the Tinker energy minimization (only applies
                   when MODELLER is not used)


buildmodel reads a template file created by choosetemplates to create a 
PDB file. The sequence file must also be specified if the sidehchains
are to be replaced.

If USEMODELLER appears in the template file, or the -modeller option is
given (and the 'modeller' variable is defined in the config file), then
MODELLER will be used to build the final model. This is useful when there
are CDRs of lengths not seen in the PDB. The -nomodeller option prevents
MODELLER from being run even if it is specified in the template file.

The template file may also contains CONSTRAINT and RESTRAINT records
(currently not supported through the abymod.pl wrapper program). These
are used as:
   CONSTRAINT res1 res2 mindist maxdist
   RESTRAINT  res1 res2 dist weight
Multiple records may be used to apply multiple constraints and restraints.

__EOF

   exit 0;
}
