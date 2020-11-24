
library("igraph")
library("network")
library("sna")
library("ndtv")

nodes<-read.csv("./dongsha_vertices.csv", stringsAsFactors = F)

colrs<-c("black","gray50")

species<-c("ajaponicus","cauriga","clunulatus","cstriatus","cvrolikii","daruanus","lkasmira","nplicata","pcoelestis")

pdf(file="allspecies_graph_3x3box.pdf") 

par(mfrow = c(3,3))
par(mar = c(0, 0, 0, 0))

for(set in species){
  
  print(set)
  
  spnodes <- nodes[grep( pattern = set, x = nodes$species),]

  #island model make all possible connections

  edges <- t(combn(x=spnodes$vertex,m=2))
  # remove edges connected to the scale point
  edges <- edges[-which(edges[,2]==20),]
  # and make the reverse connections
  edges2<-rbind(edges,edges[,c(2,1)])

  #make the n-island model
  island<-graph.data.frame(edges2,spnodes,directed=T)

  geog<-as.matrix(spnodes[,c(6,5)])



  
  plot(island,layout=geog, edge.arrow.size = .5, 
       edge.curved=0.1, label.color = spnodes$sector, 
       edge.lty = 3, vertex.label=spnodes$island, 
       vertex.color=V(island)$sector, vertex.size=0,
       vertex.shape="csquare", main=set)

  lines(x=c(116.82,116.82), y=c(20.68,126.82),type = "l")
  box()

}
dev.off()