############################################################
# DETECTION HOTSPOTS (CLUSTERS)
############################################################

library(sf)
library(dbscan)
library(dplyr)

# Charger données depuis DB
data <- dbGetQuery(con, "SELECT lon, lat, cas FROM cas_epidemio")

coords <- data.frame(data$lon, data$lat)

# Clustering DBSCAN
cl <- dbscan(coords, eps = 0.5, minPts = 5)

data$cluster <- cl$cluster

# Résultat
table(data$cluster)
