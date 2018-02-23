#list files in directory path
library(ggplot2)

path <- "/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/learnding/results/spreadsheets/boxplot"
fileList <- list.files(path, pattern=NULL, all.files=FALSE, full.names=FALSE)
#set working directory 
setwd(path)
#list of files with numbers
fileList <- fileList[fileList != "rscript.R"]
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
  #if we're on the first iteration, create the df we are going to add to each time
  if(i == 1){
    dfOriginal <- data.frame(df[ ,1], df[ ,5])
    names(dfOriginal) = c("pdb", fileName)
  }
  #otherwise create a new dataframe and add it to the original one. 
  else{
    dfAdd <- data.frame(df[ ,1], df[ ,5])
    names(dfAdd) = c("pdb", fileName)
    dfOriginal <- merge(dfOriginal, dfAdd, by="pdb", all = T)
  }
}
setwd("/acrm/bsmhome/zcbtark/Documents/abymod-masters-project/graphs")
#print result

dfOriginal <- na.omit(dfOriginal)
#print (dfOriginal)
colnames <- colnames(dfOriginal)
df <- data.frame()
for (col in colnames) {
	df1 <- data.frame(col, dfOriginal[,col])
	df <- rbind(df1, df)
	 
}
df <- subset(df, df$col!="pdb")
df
numbers <- as.numeric(df[,2])
p <- ggplot(df, aes(x=col, y=numbers)) + 
  geom_boxplot()
p
