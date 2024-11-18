#UI.R for Shepherd
































































































library(shiny)
library(leaflet)

# Create the UI
shinyUI(
  navbarPage(
    "Global Trends",

    # First Panel
    tabPanel(
      "Choropleth Map",
      sidebarLayout(
        sidebarPanel(
          # Year slider
          sliderInput(
            inputId = "year",
            label = "Year:",
            min = 1975,
            max = 2016,
            value = 1975,
            step = 1
          ),
          
          # Global factors radio buttons
          radioButtons(
            inputId = "radio", 
            label = h3("Global Factors"),
            choices = list(
              "Adult Obesity" = "obesity", 
              "Gross GDP" = "gdp", 
              "Gini Inequality Index" = "gini", 
              "Happiness Index" = "happiness"
            ),
            selected = "obesity" # Default selected value
          )
        ),
        
        # Main panel for the Leaflet map
        mainPanel(
          leafletOutput(outputId = "map", height = "600px")
        )
      )
    )
  )
)
             #SECOND PANEL: CORRELATION MATRIX
             tabPanel("Correlation Matrix")
             tabPanel("Fast Food Map Mania")
  


