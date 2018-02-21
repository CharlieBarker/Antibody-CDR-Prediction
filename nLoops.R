#R script for creating simple plots with error bars for nLoops. So far one can set whether the graph contains short, medium long or all loops according to these definitions

#very short = below 6 
#short = between 7 and 9 
#medium = beteen 11 and 13
#long = between 12 and 14
#very long is over 15 

# you need to set the variable for one of these in two laces ; one at the data.frame merging of dfOriginal at the end of the loop that creates it and the other at the calculation of SEM. 
########################################FUNCTIONS########################################
#	INPUTS /df	df 		data.frame containing redundant pdb files and all the 
#					relevant readings from the 5th column of all 11 files (
#					called dfOriginal in this script)
#		
#		/df	classdf		data.frame all pdbs of the length or class that you want
#					to study (e.g. a certain length, kinked or extended.)	
#
#	OUTPUTS /df	df		data.frame that is now only contains data according to the 
#					the classdf data.frame inputed 


classselect <- function(df, classdf)	{
	#limit the data.frame of results according to those proteins in classdf
	df <- merge(df, classdf, by="pdb", all = T, all.x = FALSE)
	#set working directory in work directory - this is where graphs go. 
	setwd("/acrm/bsmhome/zcbtark/Documents/work")
	df <- na.omit(df) #OMIT nas
	df <- df[!duplicated(df),] #get rid of duplicates

	return(df)
}


#	INPUTS /df	df 		data.frame containing redundant pdb files and all the 
#					relevant readings from the 5th column of all 11 files (
#					called dfOriginal in this script)
#		
#		/df	classdf		data.frame all pdbs of the length or class that you want
#					to study (e.g. a certain length, kinked or extended.)	
#		/vector	fileList	Vector containing all the xls files data is being taken from.	

extractmean <- function(df, fileList)	{

	#get the length of the now non redundant length 
	nonredundantLength <- length(df[,1])
	#create necessary vectors before loop. mean is for the mean and sem is for the standard error of the mean.
	meanVector <- c()
	#for every nloop experiment (usually 1-100) calculate the total mean and standard error of the means and 
	#put those in the right vectors 
	for (fileName in fileList)
	{	
		colOriginal <- (df[[fileName]])
		mean <- mean(colOriginal)
		meanVector <- c(meanVector, mean)
	}
	#remove names?
	
	
	return(meanVector)
}



#	INPUTS /df	df 		data.frame containing redundant pdb files and all the 
#					relevant readings from the 5th column of all 11 files (
#					called dfOriginal in this script)
#		
#		/df	classdf		data.frame all pdbs of the length or class that you want
#					to study (e.g. a certain length, kinked or extended.)	
#		/vector	fileList	Vector containing all the xls files data is being taken from.	

extractsem <- function(df, fileList)	{

	#get the length of the now non redundant length 
	nonredundantLength <- length(df[,1])
	#create necessary vectors before loop. mean is for the mean and sem is for the standard error of the mean.
	SEM <- c()
	#for every nloop experiment (usually 1-100) calculate the total mean and standard error of the means and 
	#put those in the right vectors 
	for (fileName in fileList)
	{	
		colOriginal <- (df[[fileName]])
		sem <- (sd(colOriginal)/sqrt(nonredundantLength))
		SEM <- c(SEM, sem)
	}
	#remove names?
	
	
	return(SEM)

}






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

veryLong <- gsub('.{3}$', '', veryLong)
veryLong <- paste(veryLong, "pdb", sep="")

all <- gsub('.{3}$', '', all)
all <- paste(all, "pdb", sep="")

#DEFINE LENGTH DATA FRAMES  
veryShort <- data.frame(veryShort)
names(veryShort) <- "pdb"

short <- data.frame(short)
names(short) <- "pdb"

medium <- data.frame(medium)
names(medium) <- "pdb"

long <- data.frame(long)
names(long) <- "pdb"

veryLong <- data.frame(veryLong)
names(veryLong) <- "pdb"

all <- data.frame(all)
names(all) <- "pdb"

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
#get number of nloops experiments. 
n <- length(fileList)
names(df) <- NULL
rawData <- (df[5:n,])
nLoops <- c(1:n)
#subroutin narrowing down the df from all loops to only those set by the class
df <- classselect(dfOriginal, veryShort)
#extract means from df
mean <- extractmean(df, fileList)
#extract sem from df
SEM <- extractsem(df, fileList)
#put together data.frame to be modelled 
tableToBe <- data.frame(nLoops, mean, SEM)
pd <- position_dodge(0.1)

line <- ggplot(tableToBe, aes(x=nLoops, y=mean)) + 
	geom_errorbar(aes(ymin=mean-SEM, ymax=mean+SEM), colour="black", width=.1, position=pd) +
    geom_line(position=pd) +
    geom_point(position=pd)

line










