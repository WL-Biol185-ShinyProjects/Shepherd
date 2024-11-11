#UI.R for Shepherd

library(shiny)
library(leaflet)

#Define UI for application that draws a histogram
fluidPage(
  
  #Application title
  titlePanel("Happy Meals: Factors Related to Obesity"),
  
  #Add a button!
  p(actionButton("titleButton", "Click Here", icon = NULL, width = NULL)),
  
)