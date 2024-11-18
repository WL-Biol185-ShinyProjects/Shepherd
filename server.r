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

function(input, output) {
  #filtering out data based on which year I choose

  output$GlobalFactorDataTable <- renderTable({
      if (input$GlobalFactor == "Adult Obesity"){
        dataset <- obese_overweight_adults[obese_overweight_adults$year == input$year,
                                      c("entity", "percentBMI", input$var)]
      }
      
      else if (input$GlobalFactor == "Gross GDP"){
        dataset <- GDP_tidy[GDP_tidy$year == input$year,
                            c("country name", "gdp", input$var)]
      }
      else if (input$GlobalFactor == "Gini Inequality Index"){
        dataset <- Gini_Inequality_Index_tidy[Gini_Inequality_Index_tidy$year == input$year,
                                              c("country name", "gini inequality index", input$var)]
      }
      
      else if (input$GlobalFactor == "Happiness Index"){
        dataset <- happiness_index_tidy[happiness_index_tidy$year == input$year,
                                        c("country", "positive affect", input$var)]
      }
    }
  )
}
}
)

