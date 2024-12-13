#UI.R for Shepherd

library(shiny)
library(tidyverse)
library(dplyr)
library(leaflet)
library(geojsonio)
library(sf)
library(ggrepel)
library(plotly)

#Loading all datasets
obese_overweight_adults <- read.csv("obese_overweight_adults.csv")
obese_overweight_adults$year <- as.integer(obese_overweight_adults$year) #calling it an integer here but a date in SliderInput
GDP_tidy <- read.csv("GDP_tidy.csv")
Gini_Inequality_Index_tidy <- read.csv("Gini_Inequality_Index_tidy.csv")
happiness_index_tidy <- read.csv("happiness_index_tidy.csv")


#Create the UI

shinyUI(
  navbarPage("Happy Meals: Global Factors Related to Obesity",
             
             #FIRST PANEL: DEFINITION OVERVIEW
             tabPanel(
               "Definition Overview",
               
               fluidRow(
                 column(12,
                        tags$h2(strong("Introduction")),
                        verbatimTextOutput("headerText"))
               ),
               
               fluidRow(
                 column(12,
                        tags$h3(strong("Adult Obesity")),
                        verbatimTextOutput("obesityText"))
               ),
               fluidRow(
                 column(12,
                        tags$h3(strong("Gross Domestic Product (GDP)")),
                        verbatimTextOutput("gdpText"))
               ),
               fluidRow(
                 column(12,
                        tags$h3(strong("Gini Inequality Index")),
                        verbatimTextOutput("giniText"))
               ),
               fluidRow(
                 column(12,
                        tags$h3(strong("Happiness Index")),
                        verbatimTextOutput("happinessText"))
               )
             ),
             
             #SECOND PANEL: LONGITUDINAL CHLOROPLETHS 
             tabPanel(
               "Longitudinal Chloropleths",
               
               sidebarLayout(
                 sidebarPanel(
                   #SLIDER
                   sliderInput( 
                     "year",
                     "Year:",
                     min = as.Date(paste(min(obese_overweight_adults$year), "01", "01", sep = "-")),  
                     max = as.Date(paste(max(obese_overweight_adults$year), "01", "01", sep = "-")),  
                     value = as.Date(paste(min(obese_overweight_adults$year), "01", "01", sep = "-")),
                     step = 365,  # days per year
                     timeFormat = "%Y"  
                   ),
                   
                   #COULD COMBINE WIDGET 1 WITH THE MARKERS - MERGE GEOSPATIAL DATA FOR ADD MARKERS - might have to merge latitude and longitude if they're different
                   
                   
                   # Select which global factor - dropdown menu
                   #DEBUG NOTE: input isn't an object, R is trying to read it as one - I MUST RECONCILE THIS WITH THE CODE BECAUSE IDK WHICH NAMES ARE WHICH. GET RID OF SWITCH
                   selectInput("GlobalFactor",
                               label = "Choose a Global Factor",
                               choices = list(
                                              "Adult Obesity" = "obese_overweight_adults",
                                              
                                              "Gross GDP" = "GDP_tidy",
                                              
                                              "Gini Inequality Index" = "Gini_Inequality_Index_tidy",
                                              
                                              "Happiness Index" = "happiness_index_tidy"
                              
                                              ),
                              ),
                   tags$h5(strong("Available Years per Factor")),
                   verbatimTextOutput("year_info")
                 ),
                 
                 
                 # Main panel for the Leaflet map
                 mainPanel(
                   leafletOutput(outputId = "map", height = "600px")
                 ),
                 
                 
               ),
               
             ),
             
             #CORRELATION ANALYSIS
             tabPanel(
               "Correlation Analysis",
               fluidRow(
                 column(12,
                        tags$h3(strong("Pearson Correlations")),
                        verbatimTextOutput("pearsoncorrelationText")),

                 plotOutput("Obesity_GDPpercapita_plot"),
                 plotOutput("Obesity_GDPgross_plot"),
                 plotOutput("Happiness_GDPpercapita_plot"),
                 plotOutput("Happiness_GDPgross_plot"),
                 plotOutput("Obesity_Happiness_plot"),
               )
               
             ), 
             
             #FAST FOOD MAP MANIA
             tabPanel(
               "Fast Food Map Mania",
               sidebarLayout(
                 sidebarPanel(
                   h4("Explore Global Fast Food Locations"),             #Heading for context 
                   p("Use the dropdown menu below to explore the worldwide locations of popular fast food chains, including Domino's, Starbucks, and McDonald's. 
                     The map dynamically updates based on your selection. Click on marker clusters to zoom in, or click individual markers to view specific addresses."),
                    selectInput("fastFoodDataset",
                                label = "Select a Fast Food Chain",
                               choices = list(
                                 "Domino's" = "coordinates",
                                 "Starbucks" = "coordinates_Starbucks",
                                 "McDonald's" = "coordinates_McDonalds"
                               ),
                               selected = "coordinates") # Default selection
                 ),
                 
                 
                 mainPanel(
                   leafletOutput(outputId = "map2", height = "600px")
                 )
               )
             ),
               
               
               #FOURTH PANEL: could select for raw data
             tabPanel(
               "Raw Data",
               
               fluidRow(
                 column(12,
                        tags$h3(strong("Raw Data Tables")),
                        verbatimTextOutput("rawdescText"))
               ),
               
               selectInput("GlobalFactor2",
                           label = "Choose a Global Factor",
                           choices = list(
                             "Adult Obesity" = "obese_overweight_adults",
                             
                             "Gross GDP" = "GDP_tidy",
                             
                             "Gini Inequality Index" = "Gini_Inequality_Index_tidy",
                             
                             "Happiness Index" = "happiness_index_tidy"
                             
                           ),
               ),
               uiOutput("checkbox"),
               textOutput("null_message"),
               tableOutput("data_table")  #outputs data table
             )
  )
)