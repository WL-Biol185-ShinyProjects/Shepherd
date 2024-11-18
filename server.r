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
  


# choices = c("Adult Obesity",
#             "Gross GDP",
#             "Gini Inequality Index",
#             "Happiness Index"),
# else if (input$GlobalFactor == "")
