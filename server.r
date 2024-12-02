
#Server.R for Shepherd Project

library(shiny)
library(leaflet)

#Loading all datasets
obese_overweight_adults <- read_csv("obese_overweight_adults.csv")
GDP_tidy <- read_csv("GDP_tidy.csv")
Gini_Inequality_Index_tidy <- read_csv("Gini_Inequality_Index_tidy.csv")
happiness_index_tidy <- read_csv("happiness_index_tidy.csv")

countries.geo.json <- geojson_read("countries.geo.json")

#Update selectInput for variables based on selected GlobalFactor

output$variableSelect <- renderUI({
  data <- switch(input$GlobalFactor,
                 "Adult Obesity" = obese_overweight_adults[obese_overweight_adults$year == input$year,
                                                           c("country", "percentBMI30", input$var)],
                 
                 "Gross GDP" = GDP_tidy[GDP_tidy$year == input$year,
                                        c("country name", "gdp", input$var)], 
                 
                 "Gini Inequality Index" = Gini_Inequality_Index_tidy[Gini_Inequality_Index_tidy$year == input$year,
                                                                      c("country name", "gini inequality index", input$var)], 
                 
                 
                 "Happiness Index" = happiness_index_tidy[happiness_index_tidy$year == input$year,
                                                          c("country", "positive affect", input$var)], 
                 
                 )
  
})

#Load geographic data 

geo <- geojson_read("countries.geo.json", what = "sp")

#Load  based on selected factor 
load_factor_data <- function(GlobalFactor) {
}

