package config;
#*************************************************************************
#
#   Program:    machinelearningprep
#   File:       config.pm
#   
#   Version:    V1.20
#   Date:       05.02.2018
#   Function:   General perl configurations 
#   Author:     Charlie Barker
#   EMail:      zcbtark@ucl.ac.uk
#               
#*************************************************************************

use strict;

#route directory - change this depending on what computer you're on
$config::route='/home/charlie';

#Root directory for machinelearningprep
$config::mlpRoute="$config::route/Documents/abymod-masters-project/machineLearning"; 
$config::templateName="toptemplates.txt";
$config::templateFile="$config::mlpRoute/$config::templateName"; 
$config::dataSource="loopdb"; #CHANGE THIS IF YOU WANT TO USE DATA FROM ANOTHER SOURCE (DEFAULT IS DEFAULT)
$config::arrfresults="$config::mlpRoute/ARFFDATA";
$config::MLalgorithms="$config::mlpRoute/MLalgorithms"; 
#weka directory 
$config::wekaRoute='/home/charlie/weka-3-8-2';

#Root directory for the analyseabYmod - YOU NEED TO CHANGE THIS TO WHERE 
$config::analyseabYmodRoot='/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding'; 

#Root directory for abYmod CHANGE AS NEW UPDATES COME OUT
$config::abymodRoot='/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/abymod';
$config::abymodBsmhomeRoot= '/acrm/bsmhome/abymod_V1.20';

#analyseabYmod folders
$config::rdFiles="$config::analyseabYmodRoot/rdfiles"; #redundancy file folder.
$config::pftScripts="$config::analyseabYmodRoot/profitscripts"; #profit script folder.

#abYmod folders 
$config::dataDir="$config::abymodRoot/DATA";
$config::abpdblib="$config::dataDir/abpdblib";                 # numbered PDB files
$config::abseqlib="$config::dataDir/abseqlib";                 # sequence files
$config::abcanlib="$config::dataDir/abcanlib";                 # canonical files
$config::loopdb="$config::dataDir/loopdb/PDB";			#loopdb

#bsmhome abYmod folders 

$config::dataDirBSM="$config::abymodBsmhomeRoot/DATA";
$config::abpdblibBSM="$config::dataDirBSM/abpdblib";


# results
$config::results="$config::analyseabYmodRoot/results";
$config::abYmodSTDERR="$config::results/abyModSTDERR";
$config::spreadsheets="$config::results/spreadsheets";
$config::nloops="$config::spreadsheets/nloops1-3.20.12.17+";


#Files 
#CHANGE THIS FOR TEST
$config::redundancyFile="$config::rdFiles/0.98Redundant_LH_Combined_Chothia.txt"; #full redundancy file
$config::chodat="$config::dataDir/canonical/chothia.dat.auto"; # Canonical definitions

#Default program values 
$config::threshold = 2; #default threshold value (in angstroms)
$config::mdmFolder ="$config::mlpRoute/MDM";
$config::matrix ="$config::mdmFolder/BLOSUM62.dat"; #CHANGE THIS IF YOU WANT TO EXPERIMENT WITH MATRICES   



