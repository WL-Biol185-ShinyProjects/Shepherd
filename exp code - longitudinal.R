experimental code to avoid hard coding obesity


#EXPERIMENTAL CODE TO AVOID HARD CODING JUST ADULT OBESITY 
output$GlobalFactorDataTable <- renderTable({
  dt    
},include.rownames=FALSE)

reactive(
  if (input$GlobalFactor == "Adult Obesity") {
    dt <- adult_obesity_tidy[adult_obesity_tidy$year == input$year,] 
    dt[,c("country", "percentBMI",input$var)]
  }
  
)   
}

  
  #EXPERIMENTAL CODE TO AVOID HARD CODING JUST ADULT OBESITY 
  observeEvent(input$GlobalFactor) 
  if (input$GlobalFactor == "Adult Obesity") {
    dt <- (adult_obesity_tidy.csv) #I NEED TO FIX THIS TO REFLECT WHICH ONE I PULL FOR TABLE GENERATION
    
  }