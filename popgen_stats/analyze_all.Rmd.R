setwd("./popgen_stats")

# Load Libraries
library(stringr)
library(strataG)
library(pegas)
library(raster)
library(vegan)

# Some useful functions
stratastat<-function(x,pop=pop,fun=nuc.div){
  #this function will calculate stats for a DNAbin object (x), stratified across populations given in pop. 
  # Some functions this will work with: nuc.div(), theta.s(), tajima.test() from pegas, FusFs(), exptdHet() from strataG,
  stats<-NULL
  for(p in unique(pop)){
    stat<-fun(spdat[grep(p,names(spdat))])
    stats<-c(stats,stat)
  }
  names(stats)<-unique(pop)?
    return(stats)
}

se <- function(x){
  sd(x)/sqrt(length(x))
}


species<-c("a_japonicus","c_auriga","c_lunulatus","c_striatus","c_vrolikii","d_aruanus","l_kasmira","n_plicata","p_coelestis")
#sp <- "c_striatus"

for(sp in species){
  
  spdat<-read.FASTA(paste0("../data/",sp,".fasta"))
  spdat<-spdat[order(names(spdat))]
  image.DNAbin(spdat)
  #extract the pop names
  pop<-str_match(names(spdat),pattern = "population:(\\w+)")[,2]

 # d <- dist.dna(spdat)
  h <- pegas::haplotype(spdat)
  h <- sort(h, what = "label")
  i<-utils::stack(setNames(attr(h, "index"), rownames(h)))
  i<-i[order(i$values),]
  ind.hap<-table(hap=i$ind, pop=pop)


  #convert to strataG

  spdat_g<-sequence2gtypes(spdat,strata=pop)
  spdat_g<-labelHaplotypes(spdat_g)
  
  n <- getNumInd(spdat_g, by.strata=T)[which(getStrataNames(spdat_g)=="Dongsha"),2]
  haps <- sum(ind.hap)
  
  spdat_priv
  
  #write an arlequin file for FusFS analysis
  write.arlequin(spdat_g,file=paste0("../data/",sp,".arp"))

  # make another dnabin objects labeled by pop only

  spdat_p <- as.matrix(spdat)

  rownames(spdat_p) <- pop



  #measure pi and hd, and test if the Dongsha value is an outlier (larger or smaller)
  pi <- stratastat(spdat_p,pop=pop,fun=nuc.div)
  pi_dongsha <- pi[which(names(pi)=="Dongsha")]
  pi_mean <- mean(pi)
  pi_p <- t.test(pi, mu=pi_dongsha, alternative="two.sided")$p.value
  
  hd <- stratastat(spdat_p,pop=pop,fun=hap.div)
  hd_dongsha <- hd[which(names(hd)=="Dongsha")]
  hd_mean <- mean(hd)
  hd_p <- t.test(hd, mu=hd_dongsha, alternative="two.sided")$p.value


  t.test(pi, mu=0.025, alternative="less")
  
  
  #pairwise stats
  pairwise_phi<-pairwiseTest(spdat_g,stats="phist",nrep=0,quietly=T,model="raw")

  #NMDS
  NMDS_phi<-metaMDSiter(dist = as.dist(pairwise_phi$pair.mat$PHIst), k=2, try = 20, trymax = 100, zerodist="add")
  plot(NMDS_phi)



