library(ggplot2)
library(gtools)
fileName <- "skew.txt"
df <- read.csv(fileName, header = TRUE, sep ="\t")
colnames(df) <- c("Threshold", "skew")
ggplot(data=df, aes(x=Threshold, y=skew, group=1)) +
  geom_line()+
  geom_point() +
    geom_point() +
    geom_smooth(se = FALSE, method = "gam", formula = y ~ s(log(x))) + labs(x = "Threshold under which a model is defined 'GOOD'", y = "Proportion of 'GOOD' models")
