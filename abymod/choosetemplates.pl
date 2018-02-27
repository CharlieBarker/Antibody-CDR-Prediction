#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    abYmod
#   File:       choosetemplates.pl
#   
#   Version:    V1.20
#   Date:       11.12.17
#   Function:   Selects templates for building a model
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
#   ./choosetemplates.pl [-v[=n]] [-n=numtemplates] 
#       [-exclude=xxxx[,xxxx[...]]] [-autoexclude] file.seq >file.tpl
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   19.09.13  Original
#   V1.1   10.01.14  Added -exclude option
#   V1.2   11.02.14  Allows the sequence file to be 3-letter code as well
#                    as 1-letter code
#                    Now prints the best 5 templates or all templates
#                    with an equally high score. The number of templates
#                    can also be specified on the command line with -n
#                    When generating the best canonical list, strips all
#                    ?s in canonical name comparison rather than just
#                    the first one.
#   V1.3   13.02.14  Skipped
#   V1.4   24.04.14  Skipped
#   V1.5   14.04.14  Fully commented
#                    Changed residue comparisons to use ResidueMatch() to
#                    avoid problems with 1- and 3-letter code.
#                    Added /g qualifier when stripping question marks in
#                    MatchCanonicals()
#                    Added call to CheckBadMismates() to penalize specific
#                    residue mismatches
#   V1.6   17.07.14  Scoring against specified mismatched residues in CDRs
#   V1.7   17.07.14  Ranks the CDR templates based on similarity score
#                    Added -nopenalize and -norank
#   V1.8   21.07.14  Added support for using MODELLER
#   V1.9   22.07.14  MODELLER used for all mismatched loop lengths
#                    instead of just CDR-H3. 
#                    Code rewritten in scoring CDRs fixing some bugs
#   V1.10  15.09.15  Skipped
#   V1.11  01.10.15  If no loop of correct length for CDR-H3 and MODELLER
#                    not available, activate LOOPDB mode
#   V1.12  01.10.15  Skipped
#   V1.13  02.11.15  Skipped
#   V1.14  04.10.16  Added code to FindBestCDRTemplateList() to deal with
#                    canonicals that are missing from the library
#   V1.15 - V1.17    Skipped
#   V1.18  15.12.16  Auto-exclude templates with score of 1.0 if -exclude 
#                    specified
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

# Check command line. $numTemplates is the minimum number of 
# framework templates to be identified
UsageDie() if(defined($::h));
$::v = (-1) if(defined($::q));
my $numTemplates = (defined($::n)?($::n):5);

# Obtain exclusion list if specified. @exclList is a list of
# PDB codes for antibodies to be excluded from the template
# set. This is used for assessing model building quality.
my @exclList = ();
@exclList = split(/\,/, $::exclude) if(defined($::exclude));

# Obtain the mutation similarity data (BLOSUM) scores
my %mdm = util::ReadMDM($config::MDMFile);
if(!defined($mdm{'A'}{'A'}))
{
    print STDERR "Error: (choosetemplates) Cannot read mutation matrix file\n   $config::MDMFile\n";
    exit 1;
}

# Obtain sequence file - this contains residue number labels and 
# the amino acid at each numbered position. Note that the file
# must be Chothia numbered.
my $seqFile = shift(@ARGV);

### Given a numbered sequence file, assign and print the canonicals
print STDERR "Finding canonicals for your sequence..." if($::v >= 1);
# Read the file into an array - one line of the file per entry
# and then convert it to 1-letter code
my @seqFileContents = util::ReadFileAsArray($seqFile);
util::ThroneSeqFileContents(\@seqFileContents);

# Assign the canonical classes using the 'chothia' program. The
# returned array contains lines of the form
#    L1 3/11A
#
my @canonicals = abymod::GetCanonicals($seqFile, @seqFileContents);
print STDERR "done\n" if($::v >= 1);
# Print the canonical data
foreach my $canonical (@canonicals)
{
    print "TARGETCANONICAL: $canonical\n";
}
print "\n";

print STDERR "Finding canonical matches in the library..." if($::v >= 1);
# Get the list of all canonical files. This routine looks in the
# specified directory ($config::abcanlib) for all files with the
# specified extension ($config::canExt). The returned list has the
# full path to each file (that's the ", 1" at the end of the call) The
# canonical files simply contain the canonical assignments for each of
# the template PDB files
my @canFiles = util::GetFileList($config::abcanlib, $config::canExt, 1);
print STDERR "done\n" if($::v >= 1);

# 10.01.14 Remove excluded PDB files By: ACRM
if(length(@exclList) && ($exclList[0] ne ''))
{
    print STDERR "Removing excluded files..." if($::v >= 1);
    @canFiles = util::RemoveExcludedFiles(\@canFiles, \@exclList);
    print STDERR "done\n" if($::v >= 1);
}

### We start by finding templates for the whole chain that have the same 
### canonical assignments (or as close as we can find)
# Given our list of canonicals, find canonical files having the same
# assignments The lists returned will contain all (non-excluded)
# canonical files, but with those that match 3 canonicals first, then
# 2, then 1, and finally 0 $aLTemplates and $aHTemplates are
# references to arrays containing the filenames of the canonical files
# for the proposed templates
#
# 10.01.14 Added exclList parameter  By: ACRM

print STDERR "Finding templates..." if($::v >= 1);
my ($aLTemplates, $aHTemplates) = FindTemplates(\@canonicals, 
                                                \@canFiles, 
                                                \@exclList, 
                                                $numTemplates);
print STDERR "done\n" if($::v >= 1);

# 15.12.16 If we have defined -autoexclude then we also automatically
# exclude files that have either light or heavy chain identical to the
# target sequence
if(defined($::autoexclude))
{
    print STDERR "Auto-excluding templates with 100% sequence identity..." if($::v >= 1);
    @exclList = AutoExcludeTemplates($aLTemplates, $aHTemplates, $seqFile);
    @canFiles = util::RemoveExcludedFiles(\@canFiles, \@exclList);
    print STDERR "done\n" if($::v >= 1);
}

# Rank the templates
print STDERR "Ranking templates..." if($::v >= 1);
print STDERR "\n" if($::v >= 2);
my ($aLSeqIDs, $aHSeqIDs);

# The results are the arrays of template canonical files ranked by
# sequence ID and the sorted sequence IDs
($aLTemplates, $aLSeqIDs) = RankTemplates($aLTemplates, $seqFile, "L");
($aHTemplates, $aHSeqIDs) = RankTemplates($aHTemplates, $seqFile, "H");
print STDERR "done\n" if($::v >= 1);

# and print the matches for the light chain
my $count = 0;
# $lfile is stepping through each light template canonical file
foreach my $lfile (@$aLTemplates)
{
    # Jump out if we've got enough templates. We also check that the
    # current template has a worse sequence ID that the best
    # template. In other words, if the top N templates (where N >
    # required number of templates) all have the same sequence ID,
    # then we keep all of them
    last if (($count >= $numTemplates) && 
             ($$aLSeqIDs[$count] < $$aLSeqIDs[0]));
    $count++;
    # BuildFileName() returns the full path and the filestem which is
    # what we are interested in here
    my ($junk, $pdb) = util::BuildFileName($lfile, "", "");
    print "LIGHTTEMPLATE: $pdb\n";
    # Print the canonical assignments for this file
    PrintCanonicalData($lfile, "L");
}
print "\n";

# Same thing for the heavy chain
$count = 0;
foreach my $hfile (@$aHTemplates)
{
    last if (($count >= $numTemplates) && 
             ($$aHSeqIDs[$count] < $$aHSeqIDs[0]));
    $count++;
    my ($junk, $pdb) = util::BuildFileName($hfile, "", "");
    print "HEAVYTEMPLATE: $pdb\n";
    PrintCanonicalData($hfile, "H");
}
print "\n";

# Now select the best individual CDR templates We pass this routine
# the sequence file contents, the array of canonical data (in the form
# 'L1 3/11A') and the array of all the canonical file names. It
# generates a hash of arrays containing the best CDR templates for
# each CDR. The hash is indexed by the CDR label and each array
# contains the canonical filenames
my ($useModeller, $rebuildH3, %bestCDRTemplates) =
    FindBestCDRTemplates(\@seqFileContents, \@canonicals, 
                         \@canFiles, \%mdm);

if($useModeller)
{
    print STDERR "*** No length matches for one or more CDRs";
    if(defined($config::modeller))
    {
        print STDERR " - MODELLER mode activated";
        print "USEMODELLER\n\n";
    }
    elsif($rebuildH3)
    {
        print STDERR " - LOOPDB mode activated for CDR-H3";
        print "USELOOPDB\n\n";
    }
    print STDERR " ***\n";
}

# and print them
foreach my $cdr (qw(L1 L2 L3 H1 H2 H3))
{
    foreach my $template (@{$bestCDRTemplates{$cdr}})
    {
        # This call to BuildFileName() results in us getting just the
        # filestem
        my ($junk, $pdb) = util::BuildFileName($template, "", "");
        print "CDRTEMPLATE: $cdr $pdb\n";
    }
    print "\n";
}


#*************************************************************************
#> %bestCDRTemplates = FindBestCDRTemplates(\@seqFileContents, 
#                                           \@canonicals, \@canFiles,
#                                           \%mdm)
#  ------------------------------------------------------------------
# Input:   \string[]     \@seqFileContents - the sequence data for target
#          \string[]     \@canonicals      - the canonical assignments in
#                                            the form
#                                            'L1 3/11A'
#          \string[]     \@canFiles        - the list of canonical PDB 
#                                            files
#          \hash{}{}     $hMDM               Reference to hash with 
#                                            similarity scores
# Returns: HashOfArrays                    - the list of best templates
#                                            for each CDR
#
# This routine finds the best templates for individual CDRs
#
# We pass this routine the sequence file contents, the array of
# canonical data (in the form 'L1 3/11A') and the array of all the
# canonical file names. It generates a hash of arrays containing the
# best CDR templates for each CDR. The hash is keyed by the CDR label
# and each array contains the canonical filenames
#
#  19.09.13  Original  By: ACRM
#  15.07.14  Changed %bestCDRTemplate to %bestCDRTemplates
#  17.07.14  Added $hMDM
#  22.07.14  Added $hMDM to FindBestLengthCDRTemplate()
#  01.10.15  Added check on H3 and returns $rebuildH3
sub FindBestCDRTemplates
{
    my($aSeqFileContents, $aCanonicals, $aCanFiles, $hMDM) = @_;

    # This converts an array (of the form 'L1 3/11A' in each row) into
    # a hash where the first column is the key and the second is the
    # value
    my %targetCanonicalHash = util::BuildTwoColumnHash(@$aCanonicals);

    my %bestCDRTemplates = ();
    foreach my $cdr (qw(L1 L2 L3 H1 H2 H3))
    {
        print STDERR "Finding best templates for CDR-$cdr..." if($::v >= 1);
        my @data = FindBestCDRTemplateList($cdr, 
                                           $targetCanonicalHash{$cdr}, 
                                           $aSeqFileContents, 
                                           $aCanFiles, $hMDM);

        # Store a reference to this array in a hash indexed by CDR name
        $bestCDRTemplates{$cdr} = \@data;

        print STDERR "done\n" if($::v >= 1);
    }

    # If we didn't find any length matches for any of the CDRs, then
    # we find the nearest length and activate MODELLER mode
    my $useModeller = 0;
    my $rebuildH3   = 0;
    foreach my $cdr (qw(L1 L2 L3 H1 H2 H3))
    {
        if(scalar(@{$bestCDRTemplates{$cdr}}) == 0)
        {
            print STDERR "No length matches found for CDR-$cdr. Finding nearest alternatives..." if($::v >= 1);
            my $cdrLength = $targetCanonicalHash{$cdr};
            $cdrLength =~ s/X//g;

            my @data = 
                FindBestLengthCDRTemplate($cdr, 
                                          $cdrLength,
                                          $aSeqFileContents, $aCanFiles,
                                          $hMDM);
            $bestCDRTemplates{$cdr} = \@data;
            print STDERR "done\n" if($::v >= 1);
            $useModeller = 1;
            $rebuildH3   = 1 if($cdr eq "H3");
        }
    }

    return($useModeller, $rebuildH3, %bestCDRTemplates);
}


#*************************************************************************
#> @canFiles = FindBestLengthCDRTemplate($cdr, $cdrLen, $aSeqFileContents,
#                                        $aCanFiles, $hMDM)
#------------------------------------------------------------------
# Input:    string    $cdr               The CDR of interest
#           string    $cdrLen            The CDR length (nearest we have
#                                        to a canonical class)
#           \string[] $aSeqFileContents  Reference to array of sequence
#                                        data in the form 'L1 SER' etc
#           \string[] $aCanFiles         Reference to array of canonical
#                                        filenames (with full paths)
#           \hash{}{}  $hMDM             Reference to hash with 
#                                        similarity scores
# Returns:  string[]  @canFiles          Array of canonical filenames for
#                                        best matches
#
# Selects the best CDR 'canonical' based purely on length in the
# instances where there is no exact length match. We simply find the
# closest available length prefering the template CDR to be longer
# than the target rather than shorter.
#
#  19.09.13  Original  By: ACRM
#  22.07.14  Generalized for all CDRs from FindBestH3Template()
#            Added sorting and $hMDM parameter
sub FindBestLengthCDRTemplate
{
    my ($cdr, $cdrLen, $aSeqFileContents, $aCanFiles, $hMDM) = @_;

    my @bestTemplates = ();
    my @similarityScores = ();

    # The score is calculated as the difference in lengths, so we want
    # as small a score as possible. Initialize to 1000 as we are never
    # going to get anything greater than 30
    my $bestScore     = 1000;

    # Go through the canonical files to find matches
    foreach my $canFile (@$aCanFiles)
    {
        my %libCanonicals = GetCanonicalsFromFile($canFile);

        my $libLen  = $libCanonicals{$cdr};
        $libLen =~ s/.*\///;        # Remove up to a /
        $libLen =~ s/[a-zA-Z\?]+//; # Remove trailing letters or ?

        # We prefer the template to be longer than the target so
        # deduct 0.5 from the score if this is the case.
        my $score = abs($cdrLen - $libLen);
        if ($libLen > $cdrLen)
        {
            $score -= 0.5;
        }

        # Keep only the best matches
        if($score == $bestScore)
        {
            push @bestTemplates, $canFile;

            if(!defined($::norank))
            {
                my($idScore,$similarityScore) = 
                    CalcMismatchedCDRScore($cdr,$aSeqFileContents,
                                           $canFile, $hMDM);
                push @similarityScores, $similarityScore;
            }
        }
        elsif($score < $bestScore)
        {
            $bestScore = $score;
            @bestTemplates = ();
            push @bestTemplates, $canFile;

            if(!defined($::norank))
            {
                my($idScore,$similarityScore) = 
                    CalcMismatchedCDRScore($cdr,$aSeqFileContents,
                                           $canFile, $hMDM);
                @similarityScores = ();
                push @similarityScores, $similarityScore;
            }
        }
    }

    if(!defined($::norank))
    {
        # Sort the @bestTemplates based on @similarityScores
        @bestTemplates = 
            util::sortArrayByArray(\@bestTemplates, 
                                   \@similarityScores);
    }

    return(@bestTemplates);
}


#*************************************************************************
#> @canFiles = FindBestH3Template($cdrLen, $aSeqFileContents, $aCanFiles)
#------------------------------------------------------------------------
# Input:    string    $cdrLen            The CDR-H3 length (nearest we 
#                                        have to a canonical class)
#           \string[] $aSeqFileContents  Reference to array of sequence
#                                        data in the form 'L1 SER' etc
#           \string[] $aCanFiles         Reference to array of canonical
#                                        filenames (with full paths)
# Returns:  string[]  @canFiles          Array of canonical filenames 
#                                        for best matches
#
# Selects the best CDR-H3 'canonical' based purely on length in the
# instances where there is no exact length match. We simply find the
# closest available length prefering the template CDR to be longer
# than the target rather than shorter.
#
#  19.09.13  Original  By: ACRM
sub OLDFindBestH3Template
{
    my ($cdrLen, $aSeqFileContents, $aCanFiles) = @_;

    my @bestTemplates = ();

    # The score is calculated as the difference in lengths, so we want
    # as small a score as possible. Initialize to 1000 as we are never
    # going to get anything greater than 30
    my $bestScore     = 1000;

    # Go through the canonical files to find matches
    foreach my $canFile (@$aCanFiles)
    {
        my %libCanonicals = GetCanonicalsFromFile($canFile);

        my $libLen  = $libCanonicals{'H3'};
        $libLen =~ s/.*\///;        # Remove up to a /
        $libLen =~ s/[a-zA-Z\?]+//; # Remove trailing letters or ?

        # We prefer the template to be longer than the target so
        # deduct 0.5 from the score if this is the case.
        my $score = abs($cdrLen - $libLen);
        if ($libLen > $cdrLen)
        {
            $score -= 0.5;
        }

        # Keep only the best matches
        if($score == $bestScore)
        {
            push @bestTemplates, $canFile;
        }
        elsif($score < $bestScore)
        {
            $bestScore = $score;
            @bestTemplates = ();
            push @bestTemplates, $canFile;
        }
    }

    return(@bestTemplates);
}


#*************************************************************************
#> @canFiles = FindBestCDRTemplateList($cdr, $canonical, 
#                                      $aSeqFileContents, 
#                                      $aCanFiles, $hMDM)
#  ------------------------------------------------------
# Input:    string    $cdr               The CDR we are looking at
#           string    $canonical         The canonical assignment for 
#                                        this CDR
#           \string[] $aSeqFileContents  Reference to array of sequence
#                                        data in the form 'L1 SER' etc
#           \string[] $aCanFiles         Reference to array of canonical
#                                        filenames (with full paths)
#           \hash{}{}  $hMDM             Reference to hash with 
#                                        similarity scores
# Returns:  string[]  @canFiles          Array of canonical filenames 
#                                        for best matches
#
# Works through the canonicals with the correct assignment and chooses
# the 'best' match for our particular sequence. First we try exact
# matches for the canonical class, then we try ignoring any question
# marks in the canonical assignments.
#
#  19.09.13 Original  By: ACRM
#  11.02.14 Added /g qualifier in stripping ?s from canonical names
#  17.07.14 Added $hMDM and similarity ranking
#  04.10.16 Added code to deal with canonicals that are missing from 
#           the library (See $gotAMatch)
sub FindBestCDRTemplateList
{
    my($cdr, $canonical, $aSeqFileContents, $aCanFiles, $hMDM) = @_;

    # $bestTemplate/Score is for an exact match
    # $bestQueryTemplate/Score is for a 'similar to' match
    my @bestTemplates         = ();
    my @similarityScores      = ();
    my @similarityQueryScores = ();
    my $bestScore             = (-1);
    my @bestQueryTemplates    = ();
    my $bestQueryScore        = (-1);

    # Go through the canonical files to find matches
    my $count     = 0;
    my $gotAMatch = 0;

    foreach my $canFile (@$aCanFiles)
    {
        print STDERR "." if(($::v >= 1) && (!($count++ % 50)));
        my %libCanonicals = GetCanonicalsFromFile($canFile);

        my $libCanonical  = $libCanonicals{$cdr};
        my $canonicalCopy = $canonical;

        if($libCanonical eq $canonicalCopy)
        {
            # If they match exactly (both having or not having
            # question marks)
            my($score, $similarityScore) =
                CalcMismatchedCDRScore($cdr, $aSeqFileContents,
                                       $canFile, $hMDM);

            # Keep only those that match the best score
            if($score == $bestScore)
            {
                push @bestTemplates, $canFile;
                push @similarityScores, $similarityScore;
            }
            elsif($score > $bestScore)
            {
                $bestScore = $score;
                @bestTemplates = ();
                @similarityScores = ();
                push @bestTemplates, $canFile;
                push @similarityScores, $similarityScore;
            }

            $gotAMatch = 1;
        }
        else
        {
            # Remove question marks from the canonical names
            # 11.02.14 Added /g qualifier
            $libCanonical =~ s/\?//g;
            $canonicalCopy =~ s/\?//g;

            # 22.07.14 Remove Xs from the target canonical copy as well
            # X is used for CDRs where there is no canonical match so
            # this shouldn't help, but is done for consistency
            $canonicalCopy =~ s/X//g;

            if($libCanonical eq $canonicalCopy)
            {
                # If one has a question mark and the other doesn't
                my($score,$similarityScore) = 
                    CalcMismatchedCDRScore($cdr,$aSeqFileContents,
                                           $canFile, $hMDM);

                # Keep only those that match the best score
                if($score == $bestQueryScore)
                {
                    push @bestQueryTemplates, $canFile;
                    push @similarityQueryScores, $similarityScore;
                }
                elsif($score > $bestQueryScore)
                {
                    $bestQueryScore = $score;
                    @bestQueryTemplates = ();
                    @similarityQueryScores = ();
                    push @bestQueryTemplates, $canFile;
                    push @similarityQueryScores, $similarityScore;
                }

                $gotAMatch = 1;
            }
        }
    }

    # 04.10.16 Added check of no match against any canonical. If
    # this happens we now check for a length only match. i.e. for
    # some reason a canonical is defined but not present in the
    # canonical library. Currently this is the case for L3-?/10D
    # Thus we will accept the best L3-x/10x instead.
    if(!$gotAMatch)
    {
        if($::v >= 1)
        {
            print STDERR "No match\n";
            print STDERR "   No match found in canonical library for $canonical.\n";
            print STDERR "Finding best length match for CDR-$cdr...";
        }
        $count = 0;

        foreach my $canFile (@$aCanFiles)
        {
            print STDERR "." if(($::v >= 1) && (!($count++ % 50)));
            my %libCanonicals = GetCanonicalsFromFile($canFile);
            
            my $libCanonical  = $libCanonicals{$cdr};
            my $canonicalCopy = $canonical;
            
            # Remove question marks from the canonical names
            $libCanonical  =~ s/\?//g;
            $canonicalCopy =~ s/\?//g;

            # Remove Xs from the target canonical copy as well
            # X is used for CDRs where there is no canonical defined
            $libCanonical  =~ s/X//g;
            $canonicalCopy =~ s/X//g;

            # Remove everything leading up to and including a /
            $libCanonical  =~ s/^.*\///;
            $canonicalCopy =~ s/^.*\///;

            # Remove trailing letter from the name - we know there is
            # no match when this is present. Consequently we are now
            # just matching on length
            $libCanonical  =~ s/[A-Za-z]$//;
            $canonicalCopy =~ s/[A-Za-z]$//;

            if($libCanonical eq $canonicalCopy)
            {
                # We know we had no proper matches, so this is our
                # best chance of a match
                my($score, $similarityScore) =
                    CalcMismatchedCDRScore($cdr, $aSeqFileContents,
                                           $canFile, $hMDM);
                
                # Keep only those that match the best score
                if($score == $bestScore)
                {
                    push @bestTemplates, $canFile;
                    push @similarityScores, $similarityScore;
                }
                elsif($score > $bestScore)
                {
                    $bestScore = $score;
                    @bestTemplates = ();
                    @similarityScores = ();
                    push @bestTemplates, $canFile;
                    push @similarityScores, $similarityScore;
                }
            }
        }
    }

    # Rank the hits
    if(!defined($::norank))
    {
        # Sort the @bestTemplates based on @similarityScores
        @bestTemplates = 
            util::sortArrayByArray(\@bestTemplates, 
                                   \@similarityScores);

        # Sort the @bestQueryTemplates based on @similarityQueryScores
        @bestQueryTemplates = 
            util::sortArrayByArray(\@bestQueryTemplates, 
                                   \@similarityQueryScores);
    }

    # We now have lists of the best exact match and query-match
    # templates If our canonical has a ? in its name, return both
    # lists
    if($canonical =~ /\?/)
    {
        return((@bestTemplates, @bestQueryTemplates));
    }

    # We didn't have a ? in the name of our canonical, so return the
    # perfect matches if there are any
    if(scalar(@bestTemplates))
    {
        return(@bestTemplates);
    }

    # No perfect matches so return the query-matches
    return(@bestQueryTemplates);
}


#*************************************************************************
#> BOOL inRange($id, $start, $stop)
#  --------------------------------
#  Input:   string   $id     Residue identifier (unpadded)
#           string   $start  Padded residue identifier
#           string   $stop   Padded residue identifier
#  Returns: BOOL             Is residue $id between $start and $stop?
#
#  Expects PadResID() to have been called on $start and $stop.  Calls
#  PadResID() on $id and then compares it with $start and $stop to see
#  if it is in this range.
#
#  This should be modified to use util::resLE() and util::resGT()
#
#  19.09.13  Original  By: ACRM
sub inRange
{
    my($id, $start, $stop) = @_;
    $id = util::PadResID($id);
    if((substr($id,0,1) eq substr($start,0,1)) && 
       ($id ge $start) && 
       ($id le $stop))
    {
        return(1);
    }
    return(0);
}


#*************************************************************************
#> ($score, $similarityScore) = CalcMismatchedCDRScore($cdr, $aSeqFileContents, 
#                                            $canFile, $hMDM)
#  ------------------------------------------------------------------
# Inputs:   string     $cdr               The CDR of interest (L1, L2, etc)
#           \string[]  $sSeqFileContents  Reference to array containing the
#                                         sequence data in the form 'L1 SER', etc
#           string     $canFile           A canonical file
#           \hash{}{}  $hMDM              Reference to hash with 
#                                         similarity scores
# Returns:  REAL       $score             Indentity score
#           REAL       $similarityScore   Similarity score
#
# Calculates the sequence identity over the CDR. Input is the CDR
# label, the sequence file contents and the canonical file against
# which we are comparing The routine extracts the sequence data
# associated with that canonical file and works through the residues
# within the specified CDR (CDR definitions are in the config.pm file)
#
# Any mismatches are checked in CheckBadMismatches() which uses rules
# specified in %config::penalizeMismatches. Any mismatch which matches
# one of these rules is then penalized
#
# Calculates a similarity score as a fraction of the score obtained by
# scoring the target sequence against itself
#
#  19.09.13 Original  By: ACRM
#  14.07.14 Changed to use ResidueMatch()
#  17.07.14 Added call to CheckBadMismatches()
#           Added calculation of similarity score
#           Added check on $::nopenalize
#  22.07.14 Rewritten to handle everything in hashes and calculate the
#           similarity here instead of separate subroutine. This now
#           allows missing residues in the comparison
sub CalcMismatchedCDRScore
{
    my($cdr, $aSeqFileContents, $canFile, $hMDM) = @_;

    # Convert the sequence file contents into a hash and throne() it
    my %targetSeq = util::BuildTwoColumnHash(@$aSeqFileContents);
    util::ThroneSequenceHash(\%targetSeq);

    # Build the filename for the sequence file equivalent to this
    # canonical file
    my ($templateFile) = util::BuildFileName($canFile, $config::abseqlib,
                                             $config::seqExt);
    # Read the sequence file into an array
    my @tplSeqFileContents = util::ReadFileAsArray($templateFile);
    # And convert to a hash keyed by residue label
    my %tplSeqHash = util::BuildTwoColumnHash(@tplSeqFileContents);
    util::ThroneSequenceHash(\%tplSeqHash);

    # Calculate the number of matches
    my $matches   = 0;
    my $cdrLength = 0;

    # Extract the residue range for this CDR
    my $start = $config::cdrDefs{$cdr}[0];
    my $stop  = $config::cdrDefs{$cdr}[1];

    # Initialize scores
    my $targetTargetScore   = 0.0;
    my $targetTemplateScore = 0.0;

    # Run through the target sequence data
    foreach my $resID (keys %targetSeq)
    {
        # If the residue is within the CDR
        if(util::resGE($resID, $start) &&
           util::resLE($resID, $stop))
        {
            my $res = $targetSeq{$resID};

            # Bump the CDR length and increment the number of matches
            # if this one does match.
            $cdrLength++;

            if(defined($tplSeqHash{$resID}))
            {
                my $tplRes = $tplSeqHash{$resID};

                # Calculate identity score
                if($res eq $tplRes)
                {
                    $matches++;
                }
                else
                {
                    # 17.07.14 Generalized checking for mismataches. A
                    #          mismatch which is listed in
                    #          config::$penalizeMismatches() will
                    #          penalize the score
                    if(abymod::CheckBadMismatches($resID, $res, 
                                                  $tplRes))
                    {
                        $matches--  if(!defined($::nopenalize));
                    }
                }

                # Calculate similarity score
                $targetTargetScore   += $$hMDM{$res}{$res};
                $targetTemplateScore += $$hMDM{$res}{$tplRes};
            }
        }
    }

    return(0.0, 0.0)  if($cdrLength == 0);

    my $score      = ($matches/$cdrLength);
    my $similarity = ($targetTemplateScore/$targetTargetScore);

    return($score, $similarity);
}


#*************************************************************************
#> BOOL ResidueMatch($res1, $res2)
#  -------------------------------
#  Input:   string  $res1   First residue
#           string  $res2   Second residue
#  Returns: BOOL            Do the residues match
#
#  Tests whether two amino acids match, but allows for both 1- and
#  3-letter codes in one or both residues
#
#  14.07.14  Original   By: ACRM
sub ResidueMatch
{
    my($res1, $res2) = @_;
    # Upcase the residues
    $res1 = "\U$res1";
    $res2 = "\U$res2";
    return(1) if($res1 eq $res2);

    # 1-letter code the residues
    $res1 = util::throne($res1);
    $res2 = util::throne($res2);
    return(1) if($res1 eq $res2);

    # Still no match
    return(0);
}


#*************************************************************************
#> void PrintCanonicalData($file, $chain)
#  --------------------------------------
# Input:   string  $file     Canonical Filename
#          string  $chain    Chain label (L or H)
#
# Extracts the canonical data from a canonical file for a given chain 
# and prints it
#
#  19.09.13  Original  By: ACRM
sub PrintCanonicalData
{
    my($lfile, $chain) = @_;

    # Extract all the canonicals into a hash keyed by CDR label
    my %canonicals = GetCanonicalsFromFile($lfile);
    foreach my $cdr (sort keys %canonicals)
    {
        # Check it's the chain we are interested in
        if(substr($cdr, 0, 1) eq $chain)
        {
            print "   TEMPLATECANONICAL: $cdr $canonicals{$cdr}\n";
        }
    }
}


#*************************************************************************
#> ($aLTemplates, $aLSeqIDs) = RankTemplates($aLTemplates, $seqFile, "L")
#  ----------------------------------------------------------------------
# Input:   \string[]  $aTemplates    Reference to array of filenames
#                                    for canonical files of templates
#          string     $seqFile       Filename of sequence file
#          string     $chain         Chain name (L or H)
# Returns: \string[]  $aTemplates    Reference to array of sorted filenames
#          \number[]  $aSeqIDs       Reference to array of percentage sequence IDs
#
# Takes the set of template files and sorts them based on overall
# sequence identity to the target sequence. CDRs are included in the
# scoring.  The routine returns both the sorted templates and the
# sequence IDs
#
#  19.09.13  Original  By: ACRM
#  15.12.16  Auto-exclude templates with score of 1.0 if -exclude specified
sub RankTemplates
{
    my($aTemplates, $seqFile, $chain) = @_;
    my @seqIDs = ();

    # Run through the template canonical files
    foreach my $template (@$aTemplates)
    {
        # Build the filenane for the equivalent sequence file
        my ($templateFile) = util::BuildFileName($template, 
                                                 $config::abseqlib,
                                                 $config::seqExt);

        # Calculate the sequence ID for this template with the target
        # sequence This is calculated over the whole thing - CDRs and
        # frameworks
        my $seqID = abymod::CalcSeqID($templateFile, $seqFile, $chain);

        # Store the result
        push @seqIDs, $seqID;
        printf STDERR "$templateFile %.3f\n", $seqID if($::v >= 2);
    }

    # Create a reverse sort index and place the canonical filenames
    # into the @ranked array
    my @idx = reverse sort { $seqIDs[$a] cmp $seqIDs[$b] } 0 .. $#seqIDs;
    my @ranked = ();
    foreach my $pos (@idx)
    {
        push @ranked, $$aTemplates[$pos];
    }
    # Also reverse sort the actual sequence identities
    @seqIDs = reverse sort @seqIDs;

    # And return the results
    return(\@ranked, \@seqIDs);
}


#*************************************************************************
#> ($aLTemplates, $aHTemplates) = FindTemplates(\@canonicals, \@canFiles, 
#                                               \@exclList, $numTemplates)
#  -----------------------------------------------------------------------
# Input:   \string[] $aCanonicals  Reference to array of canonical 
#                                  assignments of the form
#                                     L1 3/11A
#          \string[] $aCanFiles    Reference to array of canonical
#                                  filenames
#          \string[] $aExclList    Reference to array of PDB codes to
#                                  exclude
#          int       $numTemplates Minimum number of templates needed
# Returns: \string[] $aLTemplates  Reference to array of light chain
#                                  template
#          \string[] $aHTemplates  Reference to array of heavy chain
#                                  template canonical files
#
# The returned lists are arrays of (full path to) canonical files
#
# Calls code to build the list of template files for the light and
# heavy chain FRAMEWORKS. See comments on FindChainTemplates() for
# details on how this is done. Basically we try to find frameworks
# which have the correct canonicals for the CDRs. First we find those
# with 3 matches, then 2, then 1 and finally 0 matches. Consequently
# the full list will contain all available templates.  Once the list
# of candidate templates is built for both light and heavy chain,
# those entries that match any of the excluded PDB codes are removed.
#
# Note that the return from this is the canonical file names, not the
# actual PDB files that could be used as templates
#
#  19.09.13  Original  By: ACRM
#  09.07.14 $numTemplates added
sub FindTemplates
{
    my ($aCanonicals, $aCanFiles, $aExclList, $numTemplates) = @_;

    # Convert our canonical data (in an array) into a hash keyed by the
    # loop name
    my %targetCanonicalHash = util::BuildTwoColumnHash(@$aCanonicals);

    my @LTemplates = ();
    my @HTemplates = ();

    @LTemplates = FindChainTemplates($aCanFiles, \%targetCanonicalHash, 
                                     "L", $numTemplates);
    @HTemplates = FindChainTemplates($aCanFiles, \%targetCanonicalHash,
                                     "H", $numTemplates);

    # 10.01.14 By: ACRM
    @LTemplates = util::RemoveExcludedFiles(\@LTemplates, $aExclList);
    @HTemplates = util::RemoveExcludedFiles(\@HTemplates, $aExclList);

    return(\@LTemplates, \@HTemplates);
}


#*************************************************************************
#> %canonicals = GetCanonicalsFromFile($canFile)
#  ---------------------------------------------
#  Input:   string  $canFile    Canonical filename
#  Returns: hash                Canonical assignments keyed by CDR label
#
#  Obtains the canonical assignment from a canonical file.
#
#  19.09.13  Original  By: ACRM
sub GetCanonicalsFromFile
{
    my($infile) = @_;

    # Build the filename for the canonical library data
    my ($file, $stem) = util::BuildFileName($infile, $config::abcanlib,
                                            $config::canExt);

    # Read into an array and then convert to a hash
    # 14.07.14 Switched to using ReadFileAsArray()
#    my @libCanonicals = ReadCanonicalFile($file);
    my @libCanonicals = util::ReadFileAsArray($file);
    my %libCanonicalHash = util::BuildTwoColumnHash(@libCanonicals);

    return(%libCanonicalHash);
}


#*************************************************************************
#> @LTemplates = FindChainTemplates($aCanFiles, \%targetCanonicalHash, "L")
#  ------------------------------------------------------------------------
# Input:   \string[]  $aCanFiles            Reference to array of canonical files
#          \hash      $hTargetCanonicalHash The target canonical class for each CDR
#                                           The hash key is the CDR label (L1...H3)
#          string     $chain                The chain of interest (L or H)
# Returns: string[]                         Array of canonical filenames
#
# Builds an array containing filenames of the canonical files that
# could be used as framework templates.
#
# Note that the output is the filenames of the canonical files not the
# actual PDB files.
#
# The code works by finding all files that match all 3 canonicals with
# the target sequence and then files those that match 2, 1 and 0. So
# it provides a ranked list ranking just on the number of canonicals
# matched.
#
#  19.09.13 Original  By: ACRM
#  08.07.14 This now aborts after enough templates have been
#           found. $numTemplates is now passed as a parameter. Once we
#           have found >= $numTemplates templates, we stop looking for
#           matches with fewer canonicals
sub FindChainTemplates
{
    my($aCanFiles, $hTargetCanonicalHash, $chain, $numTemplates) = @_;
    my @templates = ();

    # Start with looking for 3 matches and work down
    my $nmatch = 3;
    while(($nmatch >= 0) && (scalar(@templates) == 0))
    {
        foreach my $file (@$aCanFiles)
        {
            my %libCanonicalHash = GetCanonicalsFromFile($file);
            
            # 
            if(MatchCanonicals(\%libCanonicalHash, 
                               $hTargetCanonicalHash, $chain, $nmatch))
            {
                push @templates, $file;
            }
        }
        
        if(($::v >= 1) && (scalar(@templates) == 0))
        {
            print STDERR "\n   (No $chain chain templates found with $nmatch matching canonicals)...";
        }

        # 09.07.14 Exit if we have enough templates
        last if(scalar(@templates) >= $numTemplates);

        $nmatch--;
    }

    return(@templates);
}


#*************************************************************************
#> BOOL MatchCanonicals($hLibCanonicalHash, $hTargetCanonicalHash, 
#                       $chain, $nmatch)
#  ---------------------------------------------------------------
#  Input:   \hash  $hLibCanonicalHash     A reference to a hash containing
#                                         canonical assigments. The hash is
#                                         keyed by the CDR label and the
#                                         value is simply the canonical label
#           \hash  $hTargetCanonicalHash  A reference to a hash containing
#                                         canonical assigments. The hash is
#                                         keyed by the CDR label and the
#                                         value is simply the canonical label
#           string $chain                 The chain being considered
#           int    $requiredMatch         The number of CDRs required to match
#  Returns: BOOL                          Do we have the required number of
#                                         CDRs with the correct canonicals?
#
#  Tests whether a framework templates has >= $requiredMatch
#  canonicals that match the canonicals for the target. Question marks
#  in the canonical assignments are ignored
#
#  19.09.13  Original  By: ACRM
#  14.07.14 Added /g qualifier when stripping question marks.
sub MatchCanonicals
{
    my ($hLibCanonicals, $hTargetCanonicals, $chain, $requiredMatch) = @_;
    my $nmatch = 0;

    foreach my $key (keys %$hTargetCanonicals)
    {
        if(substr($key,0,1) eq $chain)
        {
            my $libCan    = $$hLibCanonicals{$key};
            my $targetCan = $$hTargetCanonicals{$key};

            # Remove the ? for approximate assigments
            # 14.07.14 Added the /g qualifier
            $libCan    =~ s/\?//g;
            $targetCan =~ s/\?//g;

            if($libCan eq $targetCan)
            {
                $nmatch++;
            }
        }
    }

    return(($nmatch>=$requiredMatch)?1:0);
}


#*************************************************************************
#> @excludes = AutoExcludeTemplates($aLTemplates, $aHTemplates, $seqFile)
#  ----------------------------------------------------------------------
# Input:   \string[]  $aLTemplates   Reference to array of filenames
#                                    for canonical files of light templates
#          \string[]  $aHTemplates   Reference to array of filenames
#                                    for canonical files of heavy templates
#          string     $seqFile       Filename of sequence file
# Returns: string[]                  Array of IDs excluded
#
# Takes the set of light and heavy template files and removes those that
# have 100% sequence identity to the sequence file of the target sequence.
# CDRs are included in the scoring. The routine only acts on the framework
# templates, so it returns the IDs of the excluded entries so that the
# CDR canonical lists can then be handled.
#
#  15.12.16  Original   By: ACRM
sub AutoExcludeTemplates
{
    my($aLTemplates, $aHTemplates, $seqFile) = @_;

    my @exclusions = ();
    my $printed    = 0;

    foreach my $chain (qw/L H/)
    {
        my $aTemplates = ($chain eq 'L')?$aLTemplates:$aHTemplates;

        # Run through the template canonical files
        foreach my $template (@$aTemplates)
        {
            if($::v >= 4)
            {
                printf STDERR "Checking $template (Chain $chain)\n";
            }

            # Build the filenane for the equivalent sequence file
            my ($templateFile) = util::BuildFileName($template, 
                                                     $config::abseqlib,
                                                     $config::seqExt);
            
            # Calculate the sequence ID for this template with the target
            # sequence This is calculated over the whole thing - CDRs and
            # frameworks
            my $seqID = abymod::CalcSeqID($templateFile, $seqFile, $chain);
            
            if($seqID == 1.0)
            {
                my $code = $template;
                $code =~ s/.*\///;
                $code =~ s/\.can//;
                if($::v >= 1)
                {
                    if(!$printed)
                    {
                        printf STDERR "\n";
                        $printed = 1;
                    }
                    printf STDERR "   $code (Chain $chain) AUTO-EXCLUDED\n";
                }
                push @exclusions, $code;
            }
        }
    }

    my @temp;
    @temp = util::RemoveExcludedFiles($aLTemplates, \@exclusions);
    @$aLTemplates = @temp;
    @temp = util::RemoveExcludedFiles($aHTemplates, \@exclusions);
    @$aHTemplates = @temp;

    return(@exclusions);
}




#*************************************************************************
#> UsageDie()
#  ----------
#  Prints a usage message and exits
#
#  19.09.13  Original  By: ACRM
#  17.07.14  Added new options
#  15.12.16  V1.18
#  23.03.17  V1.19
#  11.12.17  V1.20

sub UsageDie
{
    print <<__EOF;

abYmod V1.20 choosetemplates (c) 2013-2017, Dr. Andrew C.R. Martin, UCL

Usage: ./choosetemplates.pl [-v[=x]] [-n=numtemplates] 
          [-exclude=xxxx[,xxxx[...]]] [-autoexclude] [-nopenalize]
          [-norank] file.seq > file.tpl

       -v[=x]           Verbose
       -n=numtemplates  Specify minimum number of framework templates [5]
       -exclude         Exclude template files with specified PDB codes
       -autoexclude     Automatically exclude templates files that match
                        at least one chain with 100% identity
       -nopenalize      Don't apply the residue mismatch penalization
                        rules when scoring CDR templates
       -norank          Do not rank the CDR templates on sequence 
                        similarity

choosetemplates selects templates for the framework and CDRs and writes
a template file that can then be used to build a model.

The sequence file is in the format
   resnum resnam
   resnum resnam
   ...
e.g.
   L1 SER                  L1 S    
   L2 VAL    --or--        L2 V    
   ...                     ...       
(i.e. 1-letter or 3-letter code are allowed - and lower or upper case)

NOTE that the file must be Chothia numbered

__EOF

   exit 0;
}
