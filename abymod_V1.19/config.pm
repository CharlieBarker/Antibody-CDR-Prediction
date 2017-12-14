package config;
use strict;
#*************************************************************************
#                                                                        *
#        Root directory for abYmod - you need to change this             *
#        to wherever you wish to install abymod                          *
#    *** NOTE TO DEVELOPERS *** THIS MUST NOT BE CHANGED IN GIT ***      *
$config::abymodRoot='/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/abymod_V1.19';
#this is for loopdb, which I am taking from a different location
$config::otherabymodRoot='/acrm/bsmhome/abymod_V1.20';
$config::analysisRoot='/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding';
#
#        If you have modeller installed, specify the full path to        *
#        run modeller here                                               *
# $config::modeller="/usr/bin/mod";
#                                                                        *
#*************************************************************************
#                                                                        *
#          You only need to change these if you need to rebuild          *
#          the loop database                                             *
#                                                                        *
#*************************************************************************
$config::pdbDir="/acrm/data/pdb";                         # Location of the protein databank
$config::pdbPrep="pdb";                                   # Characters prepended to PDB filenames
$config::entExt=".ent";                                   # PDB entry extension
$config::webdir="/acrm/www/html/abymoddata";              # Web directory for loopdb
$config::loopdbURL="http://www.bioinf.org.uk/abymoddata"; # URL to access this directory
#*************************************************************************
#                                                                        *
#          You shouldn't need to change anything below here              *
#                                                                        *
#*************************************************************************
#
#   Program:    abYmod
#   File:       config.pm
#   
#   Version:    V1.13
#   Date:       02.11.15
#   Function:   Config file for the abYmod program
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2013-2015
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
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.6   17.07.14  Scoring against specified mismatched residues in CDRs 
#   V1.7   17.07.14  Ranks the CDR templates based on similarity score
#   V1.8   21.07.14  Added support for using MODELLER
#   V1.9   22.07.14  MODELLER used for all mismatched loop lengths
#                    instead of just CDR-H3. 
#   V1.10  15.09.15  Skipped
#   V1.11  28.09.15  Added config for Tinker
#          01.10.15  Added config for loopdb
#   V1.12  01.10.15  Skipped
#   V1.13  02.11.15  Skipped
#
#*************************************************************************
chomp $config::abymodRoot;

# Location of data and binary files
$config::dataDir="$config::abymodRoot/DATA";
$config::otherdataDir="$config::otherabymodRoot/DATA";
$config::abpdblib="$config::dataDir/abpdblib";                 # numbered PDB files
$config::abseqlib="$config::dataDir/abseqlib";                 # sequence files
$config::abcanlib="$config::dataDir/abcanlib";                 # canonical files
$config::chodat="$config::dataDir/canonical/chothia.dat.auto"; # Canonical definitions
$config::scOrderFile="$config::dataDir/sc/scorder.dat";        # Order in which sidechains are replaced
$config::mdmFile="$config::dataDir/mdm/BLOSUM62.dat";          # BLOSUM matrix
$config::mmDataDir="$config::dataDir/mutmodel";                # Data for mutmodel
$config::abnumDataDir="$config::dataDir/abnum";                # Data for abnum
$config::bindir="$config::abymodRoot/bin";                     # binary files

# LoopDB
$config::loopDataDir="$config::otherdataDir/loopdb";                # Data directory for loopdb program
$config::loopData="$config::loopDataDir/loops.db";             # Data for loopdb program
$config::nLoopHits=20;                                         # Default number of hits
$config::loopDataPDB="$config::loopDataDir/PDB";               # PDB files for loops
$config::loopMaxLen=50;                                        # Maximum loop length
$config::loopdbtar="loopdb.tjz";                               # Loopdb bzipped tar file

# Tinker energy minimization
$config::tinkerParamDir="$config::dataDir/tinkerParams";       # Tinker parameter sets
$config::tinkerParams="amber99";                               # We will use amber99
$config::tinkerParamFile="$config::tinkerParamDir/$config::tinkerParams";

$config::pdbExt  = ".pdb";
$config::seqExt  = ".seq";
$config::canExt  = ".can";

# The mutation similarity matrix
$config::MDMFile = "$config::dataDir/mdm/BLOSUM62.dat";

# Chothia software
$config::chothia = "$config::bindir/chothia";

# Temporary directory
$config::tmp     = "/var/tmp";  

#Results for analyseabymod
$config::analysisResults="$config::analysisRoot/results";

#*************************************************************************
# CDR boundaries
# --------------
%config::cdrDefs = ('L1' => ['L24', 'L34'],
                    'L2' => ['L50', 'L56'],
                    'L3' => ['L89', 'L97'],
                    'H1' => ['H26', 'H35B'],
                    'H2' => ['H50', 'H65'],
                    'H3' => ['H95', 'H102']);
#*************************************************************************
# Penalized mismatches
# --------------------
# This is a set of rules specified as 
#    $config::penalizeMismatches{region} = aminoacids;
# where:
# aminoacids is a list of 1-letter codes for amino acids that must not be
#            mismatched (e.g. 'DP' would penalize mismatches for Asp and 
#            Pro)
# region     is a region or position as follows.
#            any    - at any position in any CDR
#            CDR-XX - at any position in CDR-XX (L1, L2, L3, H1, H2, H3)
#            cnni   - at a specific position (e.g. 'H52A')
#
# YOU CAN HAVE AS MANY RULES AS YOU NEED
#
#For example
# $config::penalizeMismatches{'any'}    = 'PG'; # Penalize a mismatched
#                                               # proline or glycine in
#                                               # any CDR
# $config::penalizeMismatches{'CDR-H2'} = 'D';  # Penalize a mismatched
#                                               # aspartate in CDR-H2
# $config::penalizeMismatches{'H52A'}   = 'H';  # Penalize a mismatched
#                                               # histidine at H52A
#$config::penalizeMismatches{'any'} = 'P'; # Penalized mismatched 
#                                          # proline in any CDR
$config::penalizeMismatches{'CDR-L1'} = 'ADGIQS';
$config::penalizeMismatches{'CDR-L2'} = 'ARSTY';
$config::penalizeMismatches{'CDR-L3'} = 'HPQR';
$config::penalizeMismatches{'CDR-H1'} = 'CDFHKNY';
$config::penalizeMismatches{'CDR-H2'} = 'FIKPQVW';
