#Server.R for Shepherd Project

library(shiny)
library(leaflet)
library(geojsonio)
library(tidyverse)
library(dplyr)

#Load geographic data 

geo <- geojson_read("countries.geo.json", what = "sp")

#Load data set based on selected factor 
load_factor_data <- function(factor) {
 file_name <- switch(factor,
                      obesity = "obese_overweight_adults.csv",
                      gini = "Gini_Inequality_Index_tidy.csv",
                      happiness = "happiness_index_tidy.csv",
                      gdp = "GDP_tidy.csv")
  
 obesity <- read.csv("obese_overweight_adults.csv")
}
 

shinyServer(function(input, output, session) {
  
 #Expression for filtered data 
  
    
   filtered_data <- reactive({
     
     data <- load_factor_data(input$radio)
     
     # Filter data for the selected year
     data %>%
       filter(Year == input$year) %>%
       select(Entity, percentBMI30)
   })
      #Render leaflet map
   output$map <- renderLeaflet({
     leaflet(geo) %>%
       addTiles() %>%
       setView(lng = 0, lat = 20, zoom = 2) %>%
       addPolygons(
         fillColor = "white", # Default color
         fillOpacity = 0.7,
         weight = 1,
         color = "white",
         dashArray = "3"
       )
   })
   
      
   # Observe changes and update map
   observe({
     # Get filtered data
     data <- filtered_data()
     
     # Join the data with geographic data
     geo@data <- left_join(geo@data, data, by = c("name" = "Entity"))
     
     # Define color palette
     bins <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, Inf)
     pal <- colorBin("YlOrRd", domain = geo@data$percentBMI30, bins = bins)
     
     # Update polygons with new data
     leafletProxy("map", data = geo) %>%
       clearShapes() %>%
       addPolygons(
         fillColor = ~pal(percentBMI30),
         fillOpacity = 0.7,
         weight = 1,
         color = "white",
         dashArray = "3",
         highlight = highlightOptions(
           weight = 2,
           dashArray = "",
           fillOpacity = 0.7,
           bringToFront = TRUE
         )
       )
   })
})