#R script for creating simple plots with error bars for nLoops. So far one can set whether the graph contains short, medium long or all loops according to these definitions

#very short = below 6 
#short = between 7 and 9 
#medium = beteen 11 and 13
#long = between 12 and 14
#very long is over 15 

# you need to set the variable for one of these in two laces ; one at the data.frame merging of dfOriginal at the end of the loop that creates it and the other at the calculation of SEM. 

########################################FUNCTIONS########################################


#****************************************************************************************
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
	#set working directory in work directory - this is where graphs 
	df <- na.omit(df) #OMIT nas
	df <- df[!duplicated(df),] #get rid of duplicates

	return(df)
}

#****************************************************************************************
#	INPUTS /df	df 		data.frame containing redundant pdb files and all the 
#					relevant readings from the 5th column of all 11 files (
#					called dfOriginal in this script)
#		
#		/df	classdf		data.frame all pdbs of the length or class that you want
#					to study (e.g. a certain length, kinked or extended.)	
#		/vector	fileList	Vector containing all the xls files data is being taken from.	
#
#	OUTPUTS /df 	meanVector 	vector containg all the mean readings for all 100 nloops tests

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


#****************************************************************************************
#	INPUTS /df	df 		data.frame containing redundant pdb files and all the 
#					relevant readings from the 5th column of all 11 files (
#					called dfOriginal in this script)
#		
#		/df	classdf		data.frame all pdbs of the length or class that you want
#					to study (e.g. a certain length, kinked or extended.)	
#		/vector	fileList	Vector containing all the xls files data is being taken from.
#
#	OUTPUTS /df 	SEM 		vector containg all the standard error of the mean for all 100 
#					nloops tests	

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
print (nVeryLong)
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

#for kinked extended

extended <- read.table("/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/kinkdistance/cluster0.txt")
extended <- data.frame(extended)
names(extended) <- "pdb"

kinked <- read.table("/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/kinkdistance/cluster1.txt")
kinked <- data.frame(kinked)
names(kinked) <- "pdb"

#custom

custom <- rbind(all) 


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
setwd("/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/graphs")
#veryshort

#subroutin narrowing down the df from all loops to only those set by the class
dfvShort <- classselect(dfOriginal, veryShort)
#extract means from df
meanVeryShort <- extractmean(dfvShort, fileList)
#extract sem from df
SEMVeryShort <- extractsem(dfvShort, fileList)
tableVeryShort <- data.frame(nLoops, meanVeryShort, SEMVeryShort, "Very Short")
colnames(tableVeryShort) <- c("nLoops","Mean", "SEM", "Class")

#short

dfshort <- classselect(dfOriginal, short)
#extract means from df
meanShort <- extractmean(dfshort, fileList)
#extract sem from df
SEMShort <- extractsem(dfshort, fileList)
tableShort <- data.frame(nLoops, meanShort, SEMShort, "Short")
colnames(tableShort) <- c("nLoops","Mean", "SEM", "Class")

#medium 

dfmedium <- classselect(dfOriginal, medium)
#extract means from df
meanMedium <- extractmean(dfmedium, fileList)
#extract sem from df
SEMMedium <- extractsem(dfmedium, fileList)
tableMedium <- data.frame(nLoops, meanMedium, SEMMedium, "Medium")
colnames(tableMedium) <- c("nLoops","Mean", "SEM", "Class")

#long 

dflong <- classselect(dfOriginal, long)
#extract means from df
meanLong <- extractmean(dflong, fileList)
#extract sem from df
SEMLong <- extractsem(dflong, fileList)
tableLong <- data.frame(nLoops, meanLong, SEMLong, "Long")
colnames(tableLong) <- c("nLoops","Mean", "SEM", "Class")

#very long

dfveryLong <- classselect(dfOriginal, veryLong)
#extract means from df
meanVeryLong <- extractmean(dfveryLong, fileList)
#extract sem from df
SEMVeryLong <- extractsem(dfveryLong, fileList)
tableVeryLong <- data.frame(nLoops, meanVeryLong, SEMVeryLong, "Very Long")
colnames(tableVeryLong) <- c("nLoops","Mean", "SEM", "Class")

#all

dfall <- classselect(dfOriginal, all)
#extract means from df
meanAll <- extractmean(dfall, fileList)
#extract sem from df
SEMAll <- extractsem(dfall, fileList)
tableAll <- data.frame(nLoops, meanAll, SEMAll, "All")
colnames(tableAll) <- c("nLoops","Mean", "SEM", "Class")

#kinked
#05/03/2018 revision adds a custom additional class limiting the length to below 11 residues. This is to compare kinked and extended accounting to the scewed distrubutions of the two. 

dfKinked <- classselect(dfOriginal, kinked)
dfKinked <- classselect(dfKinked, custom)
#extract means from df
meanKinked <- extractmean(dfKinked, fileList)
#extract sem from df
SEMKinked <- extractsem(dfKinked, fileList)
tableKinked <- data.frame(nLoops, meanKinked, SEMKinked, "Kinked")
colnames(tableKinked) <- c("nLoops","Mean", "SEM", "Class")

#extended

dfExtended <- classselect(dfOriginal, extended)
dfExtended <- classselect(dfExtended, custom)
#extract means from df
meanExtended <- extractmean(dfExtended, fileList)
#extract sem from df
SEMExtended <- extractsem(dfExtended, fileList)
tableExtended <- data.frame(nLoops, meanExtended, SEMExtended, "Extended")
colnames(tableExtended) <- c("nLoops","Mean", "SEM", "Class")


#put together data.frame to be modelled from all the above data frames 
#THIS IS WHERE YOU DECIDED WHICH CLASSES GO IN THE GRAPH
tableToBe <- rbind(tableVeryLong, tableLong, tableMedium, tableShort, tableVeryShort)
tableToBe


#set up graphs 
limits <- aes(ymax = Mean + SEM, ymin = Mean - SEM)
ggplot(tableToBe, aes(x = nLoops, y = Mean, colour = Class)) + geom_line(aes(group = Class)) + 
    geom_point() + geom_errorbar(limits, width = 0.25) + 
	labs(x = "Number of loops retained between rankings", y = "RMSD (Angstroms)") +
  xlim(0,20) #change the ration here 
#pd <- position_dodge(0.1)
#
#line <- ggplot(tableAll, aes(x=nLoops, y=Mean)) + 
#	geom_errorbar(aes(ymin=Mean-SEM, ymax=Mean+SEM), colour="black", width=.1, position=pd) +
#    geom_line(position=pd) +
#    geom_point(position=pd)
#tableAll
#line










