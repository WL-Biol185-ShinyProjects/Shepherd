#UI.R for Shepherd

library(shiny)
library(tidyverse)
library(dplyr)
library(leaflet)


#Loading all relevant data sets
obese_overweight_adults <- read_csv("obese_overweight_adults.csv")
GDP_tidy <- read_csv("GDP_tidy.csv")
Gini_Inequality_Index_tidy <- read_csv("Gini_Inequality_Index_tidy.csv")
happiness_index_tidy <- read_csv("happiness_index_tidy.csv")


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
                                value = c(1975)
                   ),
                   
                   
                   # Select which global factor - dropdown menu
                   selectInput("GlobalFactor",
                               label = "Choose a Global Factor",
                               choices = list("Adult Obesity" = obese_overweight_adults[obese_overweight_adults$year == input$year,
                                                                                        c("country", "percentBMI30", input$var)],
                                  
                                              "Gross GDP" = GDP_tidy[GDP_tidy$year == input$year,
                                                                     c("country name", "gdp", input$var)], 
                                              
                                              "Gini Inequality Index" = Gini_Inequality_Index_tidy[Gini_Inequality_Index_tidy$year == input$year,
                                                                                                   c("country name", "gini inequality index", input$var)], 
                                              
                                              
                                              "Happiness Index" = happiness_index_tidy[happiness_index_tidy$year == input$year,
                                                                                       c("country", "positive affect", input$var)], 
                               selected = "Gross GDP")
                   
                 ),
        # Main panel for the Leaflet map
        mainPanel(
          leafletOutput(outputId = "map", height = "600px")
        )
      )
    ), 
    
    #SECOND PANEL: CORRELATION MATRIX
    tabPanel("Correlation Matrix"), 
    tabPanel("Fast Food Map Mania") 
    
  )
)
)