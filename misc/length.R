#*************************************************************************
#
#   File:       length.R
#   
#   Version:    V0.01
#   Date:       10/01/2018
#   Function:   Seperate proteins from database (in the format of .seq)
#		into groups depending on the size of their CDR-H3:
#			Very Short = < 6 residues 
#			Short = 7 - 9 residues 
#			medium = 10 - 11 residues 
#			Long = 12 - 14 residues 
#			Very Long = > 17 resiudes 
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
path <- "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/abymod/DATA/abseqlib"
#list files in path
fileList <- list.files(path, pattern=NULL, all.files=FALSE, full.names=FALSE)
#set working directory
setwd(path)
#create different length groups 
veryShort <- c() 
short <- c()
medium <- c()
long <- c() 
veryLong <- c()
all <- c() 
for (file in fileList) {
	seqFile <- read.table(file)
	residueNo <- seqFile[,1]
	#bool is 0 before cdrh3, 1 during and 2 after 
	bool <- 0 
	#set counted to count cdrh3 residues 
	count <- 0
	for (line in residueNo)
	{
		#if line is H95 set bool to 1 and start counting
		if (line == "H95")
		{
			count <- count + 1 
			bool <- 1 
		}
		#continue counting so long as bool is 1 until you hit H102 and then count and also set bool to 1
		else if (bool == 1)
		{
			count <- count + 1
			if (line == "H102")
			{
				bool <- 2
			}
		}
	}
	if (count <= 6)
	{
		veryShort <- c(veryShort, file)	
	}
	if (count >= 7 & count <= 9)
	{
		short <- c(short, file)	
	}
	if (count >= 10 & count <= 11)
	{
		medium <- c(medium, file)	
	}
	if (count >= 12 & count <= 14)
	{
		long <- c(long, file)	
	}
	if (count >= 15)
	{
		veryLong <- c(veryLong, file)	
	}
	all <- c(all, file)
	out <- paste(file, count) 	
	#print (out)
}
#get the lengths of all these different vectors. 
nVeryShort <- length(veryShort)
nShort <- length(short)
nMedium <- length(medium)
nLong <- length(long)
nVeryLong <- length(veryLong)
nAll <- length(all)




