#Sequence variation
library(stringr)
library(strataG)
library(pegas,dependencies=TRUE)
library(raster)
getwd()
setwd("C:/Users/jacog/Desktop/Dongsha/data/p_coelestis")
list.files("C:/Users/jacog/Desktop/Dongsha/data/p_coelestis")
cstr<-read.FASTA("p_coelestis.fasta")
cstr<-cstr[order(names(cstr))]
image.DNAbin(cstr)
pop<-gsub(names(cstr),pattern = "_\\d+",replacement="")

d <- dist.dna(cstr)
h <- pegas::haplotype(cstr)
h <- sort(h, what = "label")

net <- pegas::haploNet(h)
i<-utils::stack(setNames(attr(h, "index"), rownames(h)))
i<-i[order(i$values),]
ind.hap<-table(hap=i$ind, pop=pop)
#play with scale.ratio to get appropriate branch lengths
plot(net,size=attr(net, "freq"), scale.ratio=1, pie=ind.hap,legend=F, labels=F,threshold=0, show.mutation=2)

legend("topleft", colnames(ind.hap), col=rainbow(ncol(ind.hap)), pch=19, ncol=2)

#Haplotypes and Haplotype diversity
cstr_spectrum<-site.spectrum(cstr)
plot(cstr_spectrum)
cstr_g<-sequence2gtypes(cstr,strata=pop)
cstr_g<-labelHaplotypes(cstr_g)

#nucleotide diversity
library(pegas)

stratastat<-function(x,pop=pop,fun=nuc.div){
  #this function will calculate stats for a DNAbin object (x), stratified across populations given in pop. 
  # Some functions this will work with: nuc.div(), theta.s(), tajima.test() from pegas, FusFs(), exptdHet() from strataG,
  stats<-NULL
  for(p in unique(pop)){
    stat<-fun(cstr[grep(p,names(cstr))])
    stats<-c(stats,stat)
  }
  names(stats)<-unique(pop)
  return(stats)
}
stratastat(cstr,pop=pop,fun=nuc.div)
stratastat(cstr,pop=pop,fun=hap.div)
stratastat(cstr,pop=pop,fun=tajima.test)
stratastat(cstr,pop=pop,fun=fusFs)


#STX in mtDNA
library(strataG)
library(gdistance)
library(ggplot2)
library(vegan)
library(knitr)

getwd()
setwd("C:/Users/jacog/Desktop/Dongsha/data/p_coelestis")
list.files("C:/Users/jacog/Desktop/Dongsha/data/p_coelestis")
cstr<-read.FASTA("p_coelestis.fasta")

#put them in alphabetical order
cstr<-cstr[order(names(cstr))]

image.DNAbin(cstr)
pop<-gsub(names(cstr),pattern = "_\\d+",replacement="") #create a vector of population assignments by stripping off the individual identifiers
cstr<-as.matrix(cstr)
cstr_g<-sequence2gtypes(cstr,strata=pop)

cstr_g2<-labelHaplotypes(cstr_g)
cstr_g2

#pairwise stats
pairwise_phi<-pairwiseTest(cstr_g,stats="phist",nrep=1000,quietly=T,model="raw")
pairwise_phi

pairwise_F<-pairwiseTest(cstr_g,stats="Fst",nrep=1000,quietly=T)
pairwise_F
setwd("C:/Users/jacog/Desktop/Dongsha/data/p_coelestis")
list.files("C:/Users/jacog/Desktop/Dongsha/data/p_coelestis")
cstr_m<-read.csv("map_cords.csv")
cstr_unique<-unique(cstr_m[,c("locality","decimalLatitude","decimalLongitude")]) #pull out just locality and lat/longs, and get unique values
cstr_unique
cstr_unique<-cstr_unique[order(cstr_unique$locality),] #put them in alphabetical order

cstr_unique
gdist<-pointDistance(p1=cstr_unique[,c(3,2)], lonlat=T,allpairs=T) #measure great circle distance between points in meters
gdist<-gdist/1000 # convert to km
gdist<-as.dist(gdist) #convert to distance object
pair_phi<-as.dist(pairwise_phi$pair.mat$PHIst) #convert phi_st to distance object
pair_phi<-pair_phi/(1-pair_phi) #linearize PhiST

phi_mantel<-mantel.randtest(pair_phi,gdist)

phi_mantel
plot(gdist,pair_phi)
#identify(gdist,pair_phi) # use this if you want to identify outliers

phi_plot<-ggplot(as.data.frame(cbind(gdist,pair_phi)),aes(x=gdist,y=pair_phi)) + geom_point() + geom_smooth(method=lm) + xlab("Great Circle Distance (km)") + ylab(expression(Phi["ST"]/1-Phi["ST"]))

phi_plot
dongsha<-as.data.frame(cbind(as.matrix(pair_phi)[,5],as.matrix(gdist)[,5]))

phi_plot_dongsha<-phi_plot+geom_point(data=dongsha,aes(x=V2,y=V1),color="red")

#NMDS
NMDS_phi<-metaMDSiter(dist = pair_phi, k=2, try = 20, trymax = 100)
plot(NMDS_phi)

#AMOVA 
write.csv(pop,"amova_hypotheses.csv",row.names = F)
#Open this file up in a spreadsheet program and fill out your hypotheses for higher level hierarchies, with the name of your hypothesis in the header, and pop as the name of the population column

#read them back into R
amovahyps<-read.csv("amova_hypotheses1.csv")
continent<-amovahyps$Continent
ocean<-amovahyps$Ocean
nmds1<-as.factor(amovahyps$NMDS)
pop1<-as.factor(pop)
#Calculate the p-distance among all sequences
dists<-dist.dna(cstr,model="raw")
amova_out<-pegas::amova(formula=dists~continent/pop1,nperm=1)


FCT<-amova_out$varcomp[1,1]/sum(amova_out$varcomp[,1])
FCTp<-amova_out$varcomp[1,2]

FSC<-amova_out$varcomp[2,1]/(amova_out$varcomp[2,1]+amova_out$varcomp[3,1])
FSCp<-amova_out$varcomp[2,2]

FST<-(amova_out$varcomp[1,1]+amova_out$varcomp[2,1])/sum(amova_out$varcomp[,1])
FSTp<-NA

continent_result<-c(FCT,FSC,FST)
amova_out<-pegas::amova(formula=dists~ocean/pop1,nperm=1)


FCT<-amova_out$varcomp[1,1]/sum(amova_out$varcomp[,1])
FCTp<-amova_out$varcomp[1,2]

FSC<-amova_out$varcomp[2,1]/(amova_out$varcomp[2,1]+amova_out$varcomp[3,1])
FSCp<-amova_out$varcomp[2,2]

FST<-(amova_out$varcomp[1,1]+amova_out$varcomp[2,1])/sum(amova_out$varcomp[,1])
FSTp<-NA

ocean_result<-c(FCT,FSC,FST)
amova_out<-pegas::amova(formula=dists~nmds1/pop1,nperm=1)


FCT<-amova_out$varcomp[1,1]/sum(amova_out$varcomp[,1])
FCTp<-amova_out$varcomp[1,2]

FSC<-amova_out$varcomp[2,1]/(amova_out$varcomp[2,1]+amova_out$varcomp[3,1])
FSCp<-amova_out$varcomp[2,2]

FST<-(amova_out$varcomp[1,1]+amova_out$varcomp[2,1])/sum(amova_out$varcomp[,1])
FSTp<-NA

nmds_result<-c(FCT,FSC,FST)
AMOVA_result<-cbind(c("Among Regions","Among Populations within Regions", "Among Populations"),continent_result,ocean_result,nmds_result)

kable(AMOVA_result)

# PhiST in lower triangle, p-value in upper triangle
kable(head(pairwise_phi$pair.mat$PHIst))
