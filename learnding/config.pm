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
$config::analyseabYmodRoot='/home/charlie/Documents/abymod-masters-project/learnding'; 

#Root directory for abYmod
$config::abymodRoot='/home/charlie/Documents/abymod/';

#analyseabYmod folders
$config::rdFiles="$config::analyseabYmodRoot/rdfiles"; #redundancy file folder.
$config::pftScripts="$config::analyseabYmodRoot/profitscripts"; #profit script folder.

#abYmod folders 
$config::dataDir="$config::abymodRoot/DATA";
$config::abpdblib="$config::dataDir/abpdblib";                 # numbered PDB files
$config::abseqlib="$config::dataDir/abseqlib";                 # sequence files
$config::abcanlib="$config::dataDir/abcanlib";                 # canonical files

# Temporary directory


#Files 
$config::redundancyFile="$config::rdFiles/Redundant_LH_Combined_Chothia.txt"; #full redundancy file
$config::testRedundancyFile="$config::rdFiles/TEST_Redundant_LH_Combined_Chothia.txt"; #shortened redundacny file (for tests)
$config::chodat="$config::dataDir/canonical/chothia.dat.auto"; # Canonical definitions

