#Server.R for Shepherd Project



#Calls to library
#Server.R for Shepherd Project

library(shiny)
library(leaflet)
library(geojsonio)
library(tidyverse)
library(dplyr)
library(data.table)

#Loading all datasets
obese_overweight_adults <- read.csv("obese_overweight_adults.csv")
GDP_tidy <- read.csv("GDP_tidy.csv")
Gini_Inequality_Index_tidy <- read.csv("Gini_Inequality_Index_tidy.csv")
happiness_index_tidy <- read.csv("happiness_index_tidy.csv")

countries.geo.json <- geojson_read("countries.geo.json")

#Load geographic data 

geo <- geojson_read("countries.geo.json", what = "sp")
  

shinyServer(function(input, output, session) {
  #WIDGET ONE
  
  #Expression for filtered data 
  filtered_data <- reactive({
    
    data <- switch(input$GlobalFactor,
                   "obese_overweight_adults" = obese_overweight_adults,
                   "GDP_tidy" = GDP_tidy,
                   "Gini_Inequality_Index_tidy" = Gini_Inequality_Index_tidy,
                   "happiness_index_tidy" = happiness_index_tidy,
                   stop("Unknown factor"))
    
    # Filter data for the selected year
    filtered <- data %>%
      filter(year == input$year) %>%
      select(c(1,4))
    return(filtered)

    # output$variableSelect <- renderUI({
    #   data <- switch(input$GlobalFactor,
                     # "Adult Obesity" = obese_overweight_adults[obese_overweight_adults$year == input$year,
                     #                                           c("country", "percentBMI30", input$var)],
                     # 
                     # "Gross GDP" = GDP_tidy[GDP_tidy$year == input$year,
                     #                        c("country name", "gdp", input$var)], 
                     # 
                     # "Gini Inequality Index" = Gini_Inequality_Index_tidy[Gini_Inequality_Index_tidy$year == input$year,
                     #                                                      c("country name", "gini inequality index", input$var)], 
                     # 
                     # 
                     # "Happiness Index" = happiness_index_tidy[happiness_index_tidy$year == input$year,
                     #                                          c("country", "positive affect", input$var)], 
                     
      
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
  #hard-coded lines: "country" is obesity and happiness, "country name" is GDP and Gini Inequality
  #lines: 94, 98, 104
  
  observe({
    # Get filtered data
    data <- filtered_data()
    
    # Join the data with geographic data
    geo@data <- left_join(
      geo@data, 
      data, 
      by = c("name" = "country"))
    
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
  }
)

})
  

