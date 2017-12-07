########PATH HERE#########
path <- "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding/results/spreadsheets/nloops 10-30"
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
		meanOriginal <- mean(df[ ,5])
		sdOriginal <- sd(df[ ,5])
		names(dfOriginal) <- c("pdb", fileName)
	}
	#otherwise create a new dataframe and add it to the original one. 
	else{
		dfAdd <- data.frame(df[ ,1], df[ ,5])
		meanAdd <- mean(df[ ,5])
		sdAdd <- sd(df[ ,5])
		names(dfAdd) = c("pdb", fileName)
		dfOriginal <- merge(dfOriginal, dfAdd, by="pdb", all = T)
		meanOriginal <- c(meanOriginal, meanAdd)
		sdOriginal <- c(sdOriginal, sdAdd)
	}
}

setwd("/acrm/bsmhome/zcbtark/Documents/work")
#print result

dfOriginal <- na.omit(dfOriginal) #OMIT nas
dfOriginal <- dfOriginal[!duplicated(dfOriginal),] #get rid of duplicates 
#print (dfOriginal)
meanOrig <- c()
for (fileName in fileList)
{
	name <- fileName 
	colOriginal <- (dfOriginal[[name]])
	meanOrig <- c(meanOrig, mean(colOriginal))
	sdOrig <- sd(colOriginal)
}
n <- length(fileList)
rawData <- (dfOriginal[,2:n])
print (rawData)
nLoops <- c(1:n)
sdOriginal <- sdOriginal
#meanOriginal and meanOrig depending on whether you want to discount NA or not. 
tableToBe <- data.frame(nLoops, meanOrig, sdOriginal)
print (tableToBe)
pd <- position_dodge(0.1)
ggplot(tableToBe, aes(x=nLoops, y=meanOrig)) + 
    geom_line(position=pd) +
    geom_point(position=pd)






