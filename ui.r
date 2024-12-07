#UI.R for Shepherd


library(shiny)
library(tidyverse)
library(dplyr)
library(leaflet)
library(geojsonio)
library(data.table)

#Loading all datasets
obese_overweight_adults <- read.csv("obese_overweight_adults.csv")
GDP_tidy <- read.csv("GDP_tidy.csv")
Gini_Inequality_Index_tidy <- read.csv("Gini_Inequality_Index_tidy.csv")
happiness_index_tidy <- read.csv("happiness_index_tidy.csv")


#Create the UI

shinyUI(
  navbarPage("Happy Meals: Global Factors Related to Obesity",
             
             #FIRST PANEL: LONGITUDINAL CHLOROPLETHS 
             tabPanel(
               "Longitudinal Chloropleths",
               
               sidebarLayout(
                 
                 
                     sidebarPanel(
                       
                       #SLIDER
                       sliderInput( "year",
                                    "Year:",
                                    min = min(obese_overweight_adults$year),
                                    max = max(obese_overweight_adults$year),
                                    value = c(1975),
                                    step = 1
                       ),
                       
                       
                       # Select which global factor - dropdown menu
                       #DEBUG NOTE: input isn't an object, R is trying to read it as one - I MUST RECONCILE THIS WITH THE CODE BECAUSE IDK WHICH NAMES ARE WHICH. GET RID OF SWITCH
                       selectInput("GlobalFactor",
                                   label = "Choose a Global Factor",
                                   choices = list("Adult Obesity" = "obese_overweight_adults",
                                                 
                                                  "Gross GDP" = "GDP_tidy",
                                                  
                                                  "Gini Inequality Index" = "Gini_Inequality_Index_tidy",
                                                  
                                                  "Happiness Index" = "happiness_index_tidy",
              
                                                  selected = "Adult Obesity"),
                  
          
                       )             
                    ),
                     
              
                  # Main panel for the Leaflet map
                        mainPanel(
                            leafletOutput(outputId = "map", height = "600px")
                       ),
                  
                  
      ),

    ),
    #SECOND PANEL: CORRELATION MATRIX
    tabPanel(
      "Correlation Matrix"
      #NOTE TO SELF THIS IS A GEOMPOINT WITH A REGRESSIONA AND TWO DROP-DOWNS
      
    ), 
    
    #THIRD PANEL: Fast Food Map Mania
    tabPanel(
      "Fast Food Map Mania",
      
      
      #upload leaflet wtih markers - note, this will have to be adjustable later?
      mainPanel(
        leafletOutput(outputId = "map2", height = "600px"),

    ),
    
    #FOURTH PANEL: could select for raw data
    tabPanel(
      "Raw Data"
      #NOTE TO SELF, EASY TO PUT IN IF HE'LL ACCEPT JANKY CODE
      
      

    ),

    
  )
)

)