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
		if (line == "H95")
		{
			count <- count + 1 
			bool <- 1 
		}
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
	print (out)
}
nVeryShort <- length(veryShort)
nShort <- length(short)
nMedium <- length(medium)
nLong <- length(long)
nVeryLong <- length(veryLong)
nAll <- length(all)

print (nVeryShort)
print (nShort)
print (nMedium)
print (nLong)
print (nVeryLong)
print (nAll)



