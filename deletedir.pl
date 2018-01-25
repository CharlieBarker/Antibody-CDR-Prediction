#!/usr/bin/perl -s
use strict; 

#SPECIFY THE DIRECTORY YOU ARE LOOKING INTO 
my $directory = '/tmp';
#SPECIFY THE KEYWORD YOU ARE LOOKING FOR
my $lookFor = "analyse";




my $directory = '/tmp';
my $count = 0;
opendir (DIR, $directory) or die $!;
while (my $file = readdir(DIR)) {
	#print "$file\n";
	if($file =~ /analyse/) #search for lines that start 
        {
		`rm -rf $directory/$file`;
		$count++;
		
        }
}
if($count == 0)
{
	print STDERR "no files to delete\n";
}
else
{
	print STDERR "deleting $count files\n";
}



