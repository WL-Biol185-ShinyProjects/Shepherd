#UI.R for Shepherd

library(shiny)
library(leaflet)

#Create multiple pages
shinyUI(
  navbarPage("Happy Meals: Global Factors Related to Obesity",
             
             
             
             
             #FIRST PANEL: LONGITUDINAL CHLOROPLETHS 
             tabPanel(
               "Longitudinal Chloropleths",
               sidebarLayout(
                 sidebarPanel(
                   sliderInput( "year",
                                "Year:",
                                min = 1975,
                                max = 2016,
                                value = 1975
                   ),
                   # Select which
                   radioButtons("radio", label = h3("Global Factors"),
                                choices = list("Adult Obesity" = 1, "Gross GDP" = 2, "Gini Inequality Index" = 3, "Happiness Index" = 4)
                   )
                 ),
                 mainPanel( plotOutput("distPlot") )
               )
             ),
             
    
             
             
             #SECOND PANEL: CORRELATION MATRIX
             tabPanel("Correlation Matrix"),
             tabPanel("Fast Food Map Mania")
  )
)

