
#Server.R for Shepherd Project

#Calls to library
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
  
  color_columns <- list(
    "obese_overweight_adults" = "percentBMI30",  
    "GDP_tidy" = "gdp",                         
    "Gini_Inequality_Index_tidy" = "gini_inequality_index",  
    "happiness_index_tidy" = "positive_affect"   
  )
  
  color_column <- reactive({
    req(input$GlobalFactor)  # Ensure input$GlobalFactor is available
    
    observe({
      print(paste("Selected Global Factor:", input$GlobalFactor))
      print(paste("Selected column name:", color_column()))
    })
    
    
    # Check if the input value exists in the color_columns list
    if (input$GlobalFactor %in% names(color_columns)) {
      # Return the corresponding column name
      return(color_columns[[input$GlobalFactor]])
    } else {
      # If invalid input, return NULL and handle it gracefully
      stop("Invalid global factor selected.")
    }
  })
  
  
  filtered_data <- reactive({
    
    data <- switch(input$GlobalFactor,
                   "obese_overweight_adults" = obese_overweight_adults,
                   "GDP_tidy" = GDP_tidy,
                   "Gini_Inequality_Index_tidy" = Gini_Inequality_Index_tidy,
                   "happiness_index_tidy" = happiness_index_tidy,
                   stop("Unknown factor"))
    
    
    # Replace all NA values with 0 across the entire dataset
    data[is.na(data)] <- 0
    
    
    # Filter data for the selected year
    filtered <- data %>%
      filter(year == input$year) %>%
      select(c("country", color_column()))

    # Standardize the selected column (color_column) by calculating z-scores
    filtered <- filtered %>%
      mutate(
        standardized_value = (get(color_column()) - mean(get(color_column()), na.rm = TRUE)) / 
          sd(get(color_column()), na.rm = TRUE)
      )
    

    return(filtered)
    

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
    
    #getting the correct column dynamically 
    color_col <- color_column()
    
    # Define color palette
    bins <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, Inf)
    pal <- colorBin("YlOrRd", domain = geo@data[[color_col]], bins = bins) #hard coded: c(geo@data$percentBMI30)
    
    # Update polygons with new data
    leafletProxy("map", data = geo) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~pal(geo@data[[color_col]]), #hard coded: ~pal(percentBMI30)
        fillOpacity = 0.7,
        weight = 1,
        color = "white",
        dashArray = "3",
        highlight = highlightOptions(
          weight = 2,
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE
        ), 
        # Add popup with country name and standardized value
        popup = ~paste(
          "<strong>Country:</strong>", name, "<br>",
          "<strong>", color_col, ":</strong>", geo@data[[color_col]]
      )
    )
  })
  
  
  
  #LEAFLET ON FAST FOOD MAP MANIA ("map2)
  coordinates <- read.csv("Copy of International Domino's Locations (Finalized) - Sheet1.csv")
  
  output$map2 <- renderLeaflet({
    leaflet(geo) %>%
      addTiles() %>%
      addMarkers(data = coordinates,
                 lng = ~Longtitude, 
                 lat = ~Latitude, 
                 label = ~Full.Address, 
                 clusterOptions = markerClusterOptions()) %>%
      setView(lng = 0, lat = 20, zoom = 2) %>%
      addPolygons(
        fillColor = "white", # Default color
        fillOpacity = 0.7,
        weight = 1,
        color = "white",
        dashArray = "3"
      )
  })
  
})
