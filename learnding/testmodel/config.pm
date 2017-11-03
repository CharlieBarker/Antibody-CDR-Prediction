package config;
use strict;

#*************************************************************************
#
#   Program:    analyseabYmod
#   File:       config.pm
#   Date:       03.10.17
#   Function:   Config file for analyseabYmod program
#   Author:     Charlie Barker
#               
#*************************************************************************

#Root directory for the analyseabYmod - YOU NEED TO CHANGE THIS TO WHERE 
$config::analyseabYmodRoot='/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding'; 

#Root directory for abYmod
$config::abymodRoot='/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/abymod_V1.19';

#analyseabYmod folders
$config::testmodel="$config::analyseabYmodRoot/testmodel"; #testmodel folder.
$config::makemodel="$config::analyseabYmodRoot/makemodel"; #makemodel folder.

#abYmod folders 
$config::dataDir="$config::abymodRoot/DATA";
$config::abpdblib="$config::dataDir/abpdblib";                 # numbered PDB files
$config::abseqlib="$config::dataDir/abseqlib";                 # sequence files
$config::abcanlib="$config::dataDir/abcanlib";                 # canonical files

# Temporary directory
$config::tmp     = "/var/tmp";  

#Files 
$config::redundancyFile="$config::testmodel/Redundant_LH_Combined_Chothia.txt"; #full redundancy file
$config::testRedundancyFile="$config::testmodel/TEST_Redundant_LH_Combined_Chothia.txt"; #shortened redundacny file (for tests)
$config::redundancyFile="$config::makemodel/Redundant_LH_Combined_Chothia.txt"; #sequences file
$config::pdbFile='/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/pdb_Models'; #pdb file folder TO CHANGE!!!!!!!!!!!
$config::chodat="$config::dataDir/canonical/chothia.dat.auto"; # Canonical definitions

