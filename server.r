#Server.R for Shepherd Project

library(shiny)
library(leaflet)



function(input, output) {
  
  lats <- -90:90
  lons <- -180:180
  
  #sampling a random number to populate latitude and longitude in R
  output$worldMap <- renderLeaflet({
    
    btn <- input$newButton #in Shiny, if you put an input within a render function, you can run the function when the input changes (ex. clicking the button)
    
    leaflet() %>%
      setView(
        lng = sample(lons, 1),
        lat = sample(lats, 1),
        zoom = 5
      ) %>% 
      addTiles()
  })
}