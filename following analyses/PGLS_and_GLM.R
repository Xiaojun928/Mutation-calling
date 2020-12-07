##Using caper to correct the phylogenetic signal
##other packages like "nlme" can also do this
#refs:
#using caper to do PGLS
#https://wiki.duke.edu/pages/viewpage.action?pageId=131172383
#https://www.wiki.duke.edu/download/attachments/131173232/Randi_PGLStutorial.docx?version=1&modificationDate=1518578568000&api=v2

##anitlog
#https://r.789695.n4.nabble.com/Searching-for-antilog-function-td4721348.html


setwd("D:/Thermococcus_A501_MA/MA_collection/Ne_mut_regression")
library(ape)
library(nlme)
library(phytools)
library(picante)
library(car)
library(MuMIn)
library(ggplot2)
library(scales)
library(caper)



df <-read.table("gnm_feature_GC_wo_hotspots21.txt",sep="\t",header=T,stringsAsFactors = F)
tree <- read.nexus("16S_tree.nex")
write.nexus(tree,file="16S_caper.nex",translate = T)  ## to get the translated nexus
tree <- read.nexus("16S_caper.nex")
tree$node.label <- NULL ##otherwise error was printed
cmp <- comparative.data(phy = tree,data = df,names.col = "Species", warn.dropped=TRUE)



## Mut vs Ne
pgls.mut.ne<-pgls(log10(Mutation.rate)~ log10(Ne_median), data = cmp, lambda='ML')
a <- summary(pgls.mut.ne)  
intercept <- a$coefficients[1,1]
slope <- a$coefficients[2,1]

##check outliers
res <- residuals(pgls.mut.ne,phylo = T)
rownames(res) <- rownames(pgls.mut.ne$residuals)
res<- res/sqrt(var(res))[1] #standardises residuals by sqrt of their variance
rownames(res)[(abs(res)>3)]#gives the names of the outliers
##You can then remove these species from the data and tree and redo the analysis.
##Note that you may need to continue removing species until there are no more outliers.


df.A501 <- df[which(df[,1]=="Thermococcus_eurythermalis_A501"),c(2,5)]
p <- ggplot(data = df, aes(x = Ne_median, y = Mutation.rate)) + 
  geom_point(color='blue', size =2.5) + geom_text(aes(label=id),size=6,hjust=0, vjust=0, nudge_x = 0.01, nudge_y = 0.02) +
  geom_abline(color='blue',intercept = intercept, slope = slope, size =1) + ##regression line
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) + 
  theme_classic() + geom_smooth(method='lm',formula=y~x,se=FALSE,colour="grey",linetype=2, size =1.2) +
  geom_point(data = df.A501, col = 'red', size =1.5) +
  labs(x="Effective population size (Ne)",y="Base-substitution mutation rate \n per nucleotide site per generation (u)") +
  annotation_logticks() +# Show log tick marks 
  theme(axis.text=element_text(size=15),axis.title=element_text(size=14),
        axis.line = element_line(colour = 'black', size = 1),
        axis.ticks = element_line(colour = "black", size = 1))
pdf(file = "Mut_Ne_wo_hotspots.pdf",width = 9.5,height = 6)
p
dev.off()



##  Size vs Ne
pgls.size.ne<-pgls(log10(Genome.size)~ log10(Ne_median), data = cmp, lambda ='ML')
#summary(pgls.size.ne)
a <- summary(pgls.size.ne)  
intercept <- a$coefficients[1,1]
slope <- a$coefficients[2,1]

##check outliers
res <- residuals(pgls.size.ne,phylo = T)
rownames(res) <- rownames(pgls.size.ne$residuals)
res<- res/sqrt(var(res))[1] #standardises residuals by sqrt of their variance
rownames(res)[(abs(res)>3)]#gives the names of the outliers

df.A501 <- df[which(df[,1]=="Thermococcus_eurythermalis_A501"),c(3,5)]
p <- ggplot(data = df, aes(x = Ne_median, y = Genome.size)) + 
  geom_point(color='blue', size =2.5) + geom_text(aes(label=id),size=6,hjust=0, vjust=0, nudge_x = 0.01, nudge_y = 0.02) +
  geom_abline(color='blue',intercept = intercept, slope = slope, size =1) + ##regression line
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) + 
  theme_classic() + geom_smooth(method='glm',formula=y~x,se=FALSE,colour="grey",linetype=2, size =1.2) +
  geom_point(data = df.A501, col = 'red') +
  labs(x="Effective population size (Ne)",y="Genome size (Mbp)") +
  annotation_logticks() +# Show log tick marks 
  theme(axis.text=element_text(size=15),axis.title=element_text(size=14),
        axis.line = element_line(colour = 'black', size = 1),
        axis.ticks = element_line(colour = "black", size = 1))
pdf(file = "Size_Ne_wo_hotspots.pdf",width = 9.5,height = 6)
p
dev.off()




###Mut vs Size
df <-read.table("gnm_feature_GC_wo_hotspots30.txt",sep="\t",header=T,stringsAsFactors = F)
tree <- read.nexus("16S_tree_30.nex")
write.nexus(tree,file="16S_caper_30.nex",translate = T)  ## to get the translate nexus
tree <- read.nexus("16S_caper_30.nex")
tree$node.label <- NULL ##otherwise error was printed

cmp <- comparative.data(phy = tree,data = df,names.col = "Species", warn.dropped=TRUE)
pgls.mut.size<-pgls(log10(Mutation.rate)~ log10(Genome.size), data = cmp, lambda ='ML')
#summary(pgls.mut.size)
a <- summary(pgls.mut.size)  
intercept <- a$coefficients[1,1]
slope <- a$coefficients[2,1]


##check outliers
res <- residuals(pgls.mut.size,phylo = T)
rownames(res) <- rownames(pgls.mut.size$residuals)
res<- res/sqrt(var(res))[1] #standardises residuals by sqrt of their variance
rownames(res)[(abs(res)>3)]

df.A501 <- df[which(df[,1]=="Thermococcus_eurythermalis_A501"),c(2,3)]
p <- ggplot(data = df, aes(x = Genome.size, y = Mutation.rate)) + 
  geom_point(color='blue', size =2.5) + geom_text(aes(label=id),size=6,hjust=0, vjust=0, nudge_x = 0.01, nudge_y = 0.02) +
  geom_abline(color='blue',intercept = intercept, slope = slope, size =1) + ##regression line
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) + 
  theme_classic() + geom_smooth(method='glm',formula=y~x,se=FALSE,colour="grey",linetype=2, size =1.2) +
  geom_point(data = df.A501, col = 'red') +
  labs(x="Genome size (Mbp)",y="Base-substitution mutation rate \n per nucleotide site per generation (u)") +
  annotation_logticks() +# Show log tick marks 
  theme(axis.text=element_text(size=15),axis.title=element_text(size=14),
        axis.line = element_line(colour = 'black', size = 1),
        axis.ticks = element_line(colour = "black", size = 1))

pdf(file = "GenomeSize_Mut_wo_hotspots.pdf",width = 9.5,height = 6)
p
dev.off()



###GLM regression and R-square calculation

A <- glm(log10(Mutation.rate)~ log10(Ne_median), data = df)
rsq::rsq(A)
B <- glm(log10(Mutation.rate)~ log10(Genome.size), data = df)
rsq::rsq(B)
C <- glm(log10(Genome.size)~ log10(Ne_median), data = df)
rsq::rsq(C)
