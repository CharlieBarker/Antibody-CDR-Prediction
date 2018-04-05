library(ggplot2)
library(splitstackshape)
fileName <- "mccs.txt"
df <- read.csv(fileName, header = TRUE, sep =" ")
df<-df[!(df$ARFF=="Indielearningset.arff"),]
df<-df[!(df$MCC=="?"),]
df[,2] <- substr(df[,2], 5, 20)
df[,2] = substr(df[,2],1,nchar(df[,2])-5)
df[,2] <- as.numeric(as.character(df[,2]))
df[,3] <- as.numeric(as.character(df[,3]))
df <- cSplit(df, "Classifier", ".")
colnames(df) <- c("cutoff","MCC", "Family", "Classifier")
dfList <- split(df, df$Family)
bayes <- data.frame(dfList[1])
functions <- data.frame(dfList[2])
lazy <- data.frame(dfList[3])
rules <- data.frame(dfList[4])
trees <- data.frame(dfList[5])
colnames(bayes) <- c("cutoff","MCC", "Family", "Classifier")
colnames(functions) <- c("cutoff","MCC", "Family", "Classifier")
colnames(lazy) <- c("cutoff","MCC", "Family", "Classifier")
colnames(rules) <- c("cutoff","MCC", "Family", "Classifier")
colnames(trees) <- c("cutoff","MCC", "Family", "Classifier")
ggplot(data=trees,
       aes(x=cutoff, y=MCC, colour=Classifier)) +
       geom_smooth(method="loess", se=F) + 
       ylim(-1, 1)


