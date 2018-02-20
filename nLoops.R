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
#remove .seq and add pdb
veryShort <- gsub('.{3}$', '', veryShort)
veryShort <- paste(veryShort, "pdb", sep="")
short <- gsub('.{3}$', '', short)
short <- paste(short, "pdb", sep="")
medium <- gsub('.{3}$', '', medium)
medium <- paste(medium, "pdb", sep="")
long <- gsub('.{3}$', '', long)
long <- paste(long, "pdb", sep="")
all <- gsub('.{3}$', '', veryShort)
all <- paste(all, "pdb", sep="")
veryShort <- data.frame(veryShort)
names(veryShort) <- "pdb"
########PATH HERE#########
path <- "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding/results/spreadsheets/nloops1-3.20.12.17+"
library(ggplot2)
library(gtools)
#list files in directory path
fileList <- list.files(path, pattern=NULL, all.files=FALSE, full.names=TRUE)
fileList <- mixedsort(fileList)
#set working directory 
setwd(path)
n <- length(fileList)
n <- c(1:n)
#list of files with numbers
dfList <- data.frame(n, fileList, stringsAsFactors = FALSE)
#for every file in dfList...
for(i in dfList[,1]) {
	#extract filename
	fileName <- dfList[i,2]
	#read the file
	df <- read.csv(fileName, header = TRUE, sep ="\t")
	#if we're on the first iteraction, create the df we are going to add to each time
	if(i == 1){
		dfOriginal <- data.frame(df[ ,1], df[ ,5])
		names(dfOriginal) <- c("pdb", fileName)
	}
	#otherwise create a new dataframe and add it to the original one. 
	else{
		dfAdd <- data.frame(df[ ,1], df[ ,5])
		names(dfAdd) = c("pdb", fileName)
		dfOriginal <- merge(dfOriginal, dfAdd, by="pdb", all = T)
	}
}
#dfOriginal <- merge(dfOriginal, veryShort, by="pdb", all = T)
#do a loop to analyse them based on size 
setwd("/acrm/bsmhome/zcbtark/Documents/work")
#print result
dfOriginal <- na.omit(dfOriginal) #OMIT nas

dfOriginal <- dfOriginal[!duplicated(dfOriginal),] #get rid of duplicates 

meanOrig <- c()
sdOrig <- c()
for (fileName in fileList)
{
	colOriginal <- (dfOriginal[[fileName]])
	meanOrig <- c(meanOrig, mean(colOriginal))
	sdOrig <- sd(colOriginal)
}

names(dfOriginal) <- NULL


n <- length(fileList)
rawData <- (dfOriginal[5:n,])
nLoops <- c(1:n)
#meanOriginal and meanOrig depending on whether you want to discount NA or not. 
#Look in word directory for results
tableToBe <- data.frame(nLoops, meanOrig)
#tableToBe
pd <- position_dodge(0.1)

line <- ggplot(tableToBe, aes(x=nLoops, y=meanOrig)) + 
	#geom_errorbar(aes(ymin=meanOrig-0.1, ymax=meanOrig+0.1), colour="black", width=.1, position=pd) +
    geom_line(position=pd) +
    geom_point(position=pd)
line












