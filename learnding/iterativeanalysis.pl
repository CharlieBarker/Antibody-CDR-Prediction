#!/usr/bin/perl

use strict;

my $var = `perl analyseabYmod.pl normal 2> results/abyModSTDERR/normal.txt`; 
my $var = `perl analyseabYmod.pl verbose -v=3 2> results/abyModSTDERR/verbose.txt`; 


