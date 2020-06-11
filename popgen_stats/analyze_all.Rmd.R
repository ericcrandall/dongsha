setwd("./popgen_stats")

# Load Libraries
library(stringr)
library(strataG)
library(pegas)
library(hierfstat)
library(raster)
library(vegan)
library(ggplot2)
library(gridExtra)

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

#initialize a data frame for the stats 
statdf<-data.frame(N=integer(),
                   N_haplotypes=integer(),
                   Private_Haplotypes=integer(),
                   Percent_Private=numeric(),
                   Haplotype_Diversity=numeric(),
                   Regional_Mean_Haplotype_Diversity=numeric(),
                   Regional_Hd_2SD=numeric(),
                   Hd_p=numeric(),
                   Nucleotide_Diversity = numeric(),
                   Regional_Mean_Nucleotide_Diversity=numeric(),
                   Regional_Pi_2SD=numeric(),
                   Pi_p=numeric(),
                   Fus_Fs=numeric(),
                   Regional_Mean_Fus_Fs=numeric(),
                   Regional_FusFs_2SD=numeric(),
                   Regional_Fs_p=numeric(),
                   Beta_i = numeric())

#initialize a PDF for the NMDS or F-stat plots
pdf(file="allspecies_PhiST_NMDS.pdf") 
par(mfrow = c(3,3), mar = c(0, 0, 0, 0))

#initialize gridextra lists of plots for Fst and Phist
F_plotlist<-list()
Phi_plotlist<-list()

#list of species
species<-c("a_japonicus","c_auriga","c_lunulatus","c_striatus","c_vrolikii","d_aruanus","l_kasmira","n_plicata","p_coelestis")
#sp <- "c_vrolikii"

# loop through each species calculating population and pairwise statistics and plotting them
for(sp in species){
  
  print(sp)
  
  #read in the data
  spdat<-read.FASTA(paste0("../data/",sp,".fasta"))
  spdat<-spdat[order(names(spdat))]
  #image.DNAbin(spdat)
  
  #extract the pop names
  pop<-str_match(names(spdat),pattern = "population:(\\w+)")[,2]
  
  #make all names unique
  names(spdat)<-paste(pop,1:length(pop),sep="_")
  
  #get the index of the Dongsha sample
  dongdex <- which(unique(pop)=="Dongsha")

  h <- pegas::haplotype(spdat)
  h <- sort(h, what = "label")
  
  #convert to strataG
  spdat_g<-sequence2gtypes(spdat,strata=pop)
  spdat_g<-labelHaplotypes(spdat_g)
  
  # make another dnabin objects labeled by pop only
  spdat_p <- as.matrix(spdat)
  rownames(spdat_p) <- pop
  
  #get the number of individuals
  n <- getNumInd(spdat_g, by.strata=T)[dongdex,2]
  #sheesh its complicated to get a haplotype count
  haps <- length(getSequences(spdat_g[,,dongdex,drop=T])$gene.1)
  #number of private alleles
  priv <- privateAlleles(spdat_g)[dongdex]
  
  #write an arlequin file for FusFS analysis (just for the p-values)
  arlequinWrite(spdat_g,file=paste0("../data/",sp,".arp"))

  #local Fst (Beta of Weir and Hill 2002 - equation 8 NOT of Foll and Gaggiotti 2006)
  spdat_wh<-cbind(spdat_g@data$stratum,spdat_g@data)
  beta_i <- betas(dat=spdat_wh, diploid=F)$betaiovl[dongdex]
  
  #measure pi and hd and Fus Fs, and test if the Dongsha value is an outlier (larger or smaller)
  pi <- stratastat(spdat_p,pop=pop,fun=nuc.div)
  pi_dongsha <- pi[dongdex]
  pi_mean <- mean(pi[-dongdex])
  pi_sd <- sd(pi[-dongdex])
  pi_p <- t.test(pi[-dongdex], mu=pi_dongsha, alternative="two.sided")$p.value
  
  hd <- stratastat(spdat_p,pop=pop,fun=hap.div)
  hd_dongsha <- hd[dongdex]
  hd_mean <- mean(hd[-dongdex])
  hd_sd <- sd(hd[-dongdex])
  hd_p <- t.test(hd[-dongdex], mu=hd_dongsha, alternative="two.sided")$p.value
  
  Fs <- stratastat(spdat_p, pop=pop, fun=fusFs)
  Fs <- unlist(Fs)
  Fs_dongsha <- Fs[dongdex]
  Fs_mean <- mean(Fs[-dongdex])
  Fs_sd <- sd(Fs[-dongdex])
  Fs_p <- t.test(Fs[-dongdex], mu=Fs_dongsha, alternative="greater")$p.value
  
  # put the stats into a vector   
  stats <- c(n, haps, priv, priv/n*100, hd_dongsha, hd_mean, 2*hd_sd, hd_p, pi_dongsha, pi_mean, 2*pi_sd, pi_p, Fs_dongsha, Fs_mean, 2*Fs_sd, Fs_p, beta_i)
  statdf[sp,] <- stats
  
  #pairwise stats
  pairwiseF<-pairwiseTest(spdat_g,stats=c("all"),nrep=1000,quietly=T,model="raw")
  
  
  pairwise_phi <- as.dist(pairwiseF$pair.mat$PHIst)
  pairwise_phi[which(pairwise_phi<0)] <- 0
  
  pairwise_F <- as.dist(pairwiseF$pair.mat$Fst)
  pairwise_F[which(pairwise_F<0)] <- 0
  
  pairwiseF$result$strata.1 <- factor(pairwiseF$result$strata.1)
  pairwiseF$result$strata.2 <- factor(pairwiseF$result$strata.2)
  
  pairwiseF$result$PHIst[which(pairwiseF$result$PHIst < 0)] <- 0
  pairwiseF$result$Fst[which(pairwiseF$result$Fst < 0)] <- 0
  
  phiplot <- ggplot(data=pairwiseF$result, aes(x=strata.1, y=strata.2,fill=PHIst)) + 
              geom_raster() + 
              annotate(geom = "text", 
                       x = pairwiseF$result$strata.1, 
                       y = pairwiseF$result$strata.2, 
                       label = round(pairwiseF$result$PHIst,3)) +
             annotate(geom = "text", 
                       x = pairwiseF$result$strata.1, 
                       y = pairwiseF$result$strata.2, 
                      label = round(pairwiseF$result$PHIst.p.val,3), size = 1) +
             scale_fill_stepsn(colours = c('white','#fcbba1','#fc9272','#fb6a4a',
                                              '#de2d26','#a50f15'), 
                      breaks = c(0,0.001,0.005, 0.01,0.05,0.1)) + 
            theme(title = element_blank(), axis.title = element_blank(), 
                  axis.text=element_text(size=3), legend.position="none", 
                  panel.grid=element_blank()) +
             scale_y_discrete(limits=rev(levels(pairwiseF$result$strata.2)))
        
  ggsave(filename=paste0(sp,"_PHIst.pdf"), plot=phiplot)
  Phi_plotlist[[sp]] <- phiplot
  
  
  Fplot <- ggplot(data=pairwiseF$result, aes(x=strata.1, y=strata.2,fill=Fst)) + 
            geom_raster() + 
            annotate(geom = "text", 
                     x = pairwiseF$result$strata.1, 
                     y = pairwiseF$result$strata.2, 
                     label = round(pairwiseF$result$Fst,3)) +
            annotate(geom = "text", 
                     x = pairwiseF$result$strata.1, 
                     y = pairwiseF$result$strata.2, 
                     label = round(pairwiseF$result$Fst.p.val,3), size = 1) +
            scale_fill_stepsn(colours = c('white','#fcbba1','#fc9272','#fb6a4a',
                                          '#de2d26','#a50f15'),  #colors selected from "Reds" in colorbrewer
                              breaks = c(0,0.001,0.005, 0.01,0.05,0.1)) + 
            theme(title = element_blank(), axis.title = element_blank(), 
                  axis.text=element_text(size=3), legend.position="none", 
                  panel.grid=element_blank()) + 
            scale_y_discrete(limits=rev(levels(pairwiseF$result$strata.2))) #put the y-axis in the correct alphabetical order
  
  ggsave(filename=paste0(sp,"_Fst.pdf"), plot=Fplot)
  F_plotlist[[sp]] <- Fplot
  
  
  #NMDS

  NMDS_phi<-metaMDSiter(dist = pairwise_phi, k=2, try = 20, trymax = 100, 
                        pc=T, zerodist="add", autotransform = F, maxit = 200, 
                        model = "hybrid", threshold = 0.1)
  plot(NMDS_phi)
  
}

write.csv(statdf,file="Dongsha_stats.csv")

PhiPlots <- grid.arrange(grobs = Phi_plotlist,ncol=3)
ggsave("PHIst_Plots.pdf",PhiPlots)

FPlots <- grid.arrange(grobs = F_plotlist,ncol=3)
ggsave("Fst_Plots.pdf",FPlots)

dev.off()



