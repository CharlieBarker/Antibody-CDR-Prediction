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
