library(leaflet)
library(dplyr)


coordinates <- read.csv("Copy of International Domino's Locations (Finalized) - Sheet1.csv")

leaflet(data = coordinates) %>%
  addTiles() %>%
  addMarkers(label = ~place, clusterOptions = markerClusterOptions())

