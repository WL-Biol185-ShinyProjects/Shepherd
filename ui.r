#UI.R for Shepherd

library(shiny)
library(leaflet)

#Create multiple pages
shinyUI(
  navbarPage("Happy Meals: Global Factors Related to Obesity",
             
             
             #CREATING FIRST PANEL: LONGITUDINAL CHLOROPLETHS
            
             tabPanel(
               "Longitudinal Chloropleths",
               sidebarLayout(
                 sidebarPanel(
                  
                   
                  #SLIDER
                   sliderInput( "year",
                                "Year:",
                                min = min(adult_obesity_tidy$year),
                                max = max(adult_obesity_tidy$year),
                                value = c(1975)
                   ),
                   
                   
                   # Select which global factor - option 1: dropdown?
                   selectInput("GlobalFactor",
                               label = "Choose a Global Factor",
                               choices = c("Adult Obesity",
                                           "Gross GDP",
                                           "Gini Inequality Index",
                                           "Happiness Index"),
                               selected = "Adult Obesity"),
                   

                   #Select which global factor - option 2: buttons?
              
                   # radioButtons("radio", label = h3("Global Factors"),
                   #              choices = list("Adult Obesity" = 1, "Gross GDP" = 2, "Gini Inequality Index" = 3, "Happiness Index" = 4)
                   #                 
                   #                  
                   # )
                 ),
                 mainPanel(
                   tableOutput("GlobalFactorDataTable") )
               )
             ),
             
    
             
             
             #SECOND PANEL: CORRELATION MATRIX
             tabPanel("Correlation Matrix"),
             tabPanel("Fast Food Map Mania")
  )
)

