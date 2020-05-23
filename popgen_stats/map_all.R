#map script
#Maps all samples
register_google(key="AIzaSyDNG9eIBTcVvGsQ-Wjh2WjzvsPAFnBoCgU")
install.packages("ggmap", dependencies=T)
library(ggmap)
setwd("C:/Users/jacog/Desktop/Dongsha/data/")
cstr_m<-read.csv("map_cords.csv")

#find the midpoint of all sampled points
samp_mean<-sapply(cstr_m[,c("decimalLongitude","decimalLatitude")],mean)
pmap <- get_map(location = samp_mean, maptype = "terrain", source = "google",zoom=3)
cstr_map<-ggmap(pmap) + geom_count(data = cstr_m, mapping = aes(x = decimalLongitude, y = decimalLatitude), color="red") 

cstr_map

#Maps one sample
install.packages("ggmap", dependencies=T)
library(ggmap)
setwd("C:/Users/jacog/Desktop/Dongsha/Figures/")
cstr_m<-read.csv("all_metadata.csv")

#find the midpoint of all sampled points
samp_mean<-sapply(cstr_m[,c("decimalLongitude","decimalLatitude")],mean)
pmap <- get_map(location = samp_mean, maptype = "terrain", source = "google",zoom=3)
cstr_map<-ggmap(pmap) + geom_count(data = cstr_m, mapping = aes(x = decimalLongitude, y = decimalLatitude), color="red") 

cstr_map