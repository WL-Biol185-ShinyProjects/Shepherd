#Server.R for Shepherd Project

library(shiny)
library(leaflet)
library(geojsonio)
library(tidyverse)
library(dplyr)

#Loading all datasets
obese_overweight_adults <- read_csv("obese_overweight_adults.csv")
GDP_tidy <- read_csv("GDP_tidy.csv")
Gini_Inequality_Index_tidy <- read_csv("Gini_Inequality_Index_tidy.csv")
happiness_index_tidy <- read_csv("happiness_index_tidy.csv")

countries.geo.json <- geojson_read("countries.geo.json")


#Load geographic data 

geo <- geojson_read("countries.geo.json", what = "sp")

#Load  based on selected factor 
load_factor_data <- function(GlobalFactor) {
  }
    