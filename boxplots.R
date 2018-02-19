#list files in directory path
library(ggplot2)
path <- getwd()
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
  #if we're on the first iteraction, create the df we are going to add to each time
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
#print result

loopdb <- dfOriginal[,2]
noLoopdb <- dfOriginal[,3]
length <- length(noLoopdb)
length <- c(1:length)
for(i in length) {
  if(i == 1){
    dataBase <- "noLoopdb"
  }
  else{
    dataBase <- c(dataBase, "noLoopdb")
  }
}
length <- length(loopdb)
length <- c(1:length)
for(i in length) {
    dataBase <- c(dataBase, "loopdb")
}
numbers <- c(noLoopdb, loopdb)
boxplot <- data.frame(dataBase, numbers)
box <- ggplot(boxplot, aes(x=dataBase, y=numbers)) + 
  geom_boxplot(fill="slateblue", alpha=0.2) + 
  xlab("Data base")
box
