#Server.R for Shepherd Project








































































































library(shiny)
library(leaflet)


function(input, output) {
  #filtering out data based on which year I choose

  output$GlobalFactorDataTable <- renderTable({
      if (input$GlobalFactor == "Adult Obesity"){
        dataset <- adult_obesity_tidy[adult_obesity_tidy$year == input$year,
                                      c("country", "percentBMI", input$var)]
      }
      
      else if (input$GlobalFactor == "Gross GDP"){
        dataset <- GDP_tidy[GDP_tidy$year == input$year,
                            c("country name", "gdp", input$var)]
      }
      else if (input$GlobalFactor == "Gini Inequality Index"){
        dataset <- Gini_Inequality_Index_tidy[Gini_Inequality_Index_tidy$year == input$year,
                                              c("country name", "gini inequality index", input$var)]
      }
      
      else if (input$GlobalFactor == "Happiness Index"){
        dataset <- happiness_index_tidy[happiness_index_tidy$year == input$year,
                                        c("country", "positive affect", input$var)]
      }
    }
  )
  
}

# choices = c("Adult Obesity",
#             "Gross GDP",
#             "Gini Inequality Index",
#             "Happiness Index"),
# else if (input$GlobalFactor == "")
