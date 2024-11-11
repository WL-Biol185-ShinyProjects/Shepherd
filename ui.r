#UI.R for Shepherd

library(shiny)
library(leaflet)
library(bslib)

#Define UI for application that draws a histogram
fluidPage(
  
  #Application title
  titlePanel("Happy Meals: Factors Related to Obesity"),
  
  #Add a button!
  p(actionButton("titleButton", "Click Here", icon = NULL, width = NULL)),
  
  navset_card_underline(
    
    nav_panel("Plot", plotOutput("plot")),
    
    nav_panel("Summary", tableOutput("summary")),
    
    nav_panel("Data", DT::dataTableOutput("data")),
    
    nav_panel(
      "Reference",
      markdown(
        glue::glue(
          "These data were obtained from [IMDB](http://www.imdb.com/) and [Rotten Tomatoes](https://www.rottentomatoes.com/).
  
        The data represent {nrow(movies)} randomly sampled movies released between 1972 to 2014 in the United States.
        "
        )
      )
    )
  )
)