
#Server.R for Shepherd Project

#Calls to library
library(shiny)
library(leaflet)
library(geojsonio)
library(tidyverse)
library(dplyr)
library(sf)
library(ggrepel)
library(plotly)

#Loading all datasets
obese_overweight_adults <- read.csv("obese_overweight_adults.csv")
GDP_tidy <- read.csv("GDP_tidy.csv")
Gini_Inequality_Index_tidy <- read.csv("Gini_Inequality_Index_tidy.csv")
happiness_index_tidy <- read.csv("happiness_index_tidy.csv")

countries.geo.json <- geojson_read("countries.geo.json")


#Load geographic data 

geo <- geojson_read("countries.geo.json", what = "sp")


shinyServer(function(input, output, session) {
  #DEFINITIONS
  output$headerText <- renderText({
    "In this page, feel free to read about each Global Factor we’ve selected. For each, we have provided a current definition and why we decided to include it. 
"
  })
  
  #Define adult obesity text
  output$obesityText <- renderText({
    "Adult obesity is a serious health condition that affects all parts of the body’s systems. It is highly correlated to outcomes such as hypertension, heart disease, cancer, type II diabetes, sleep apnea, osteoarthritis, and more. It is also strongly connected to an individual or community’s economic constraints with some of the largest predictors of future obesity being access to healthy food, access to nutrition education, and sedentary lifestyles.
    
BMI (body mass index) is a commonly used measurement of body fat based on an individual’s height and weight. Individuals with a BMI of 25 or higher are classified as overweight while individuals with a BMI of 30 or higher are classified as clinically obese. 
    
With this in mind, we have chosen the percentage of people in a given country with a BMI of 30 or higher to represent adult obesity.
    
However, BMI does have some flaws and limitations. For example, although a high BMI is generally related to increased body fat, this measure’s use of body weight and height doesn’t account for overall body composition as well as differences between races and sexes. 
"
  })
  
  
  output$gdpText <- renderText({
    "Gross domestic product (GDP) is the total market value of all goods and services produced by a country over one year and serves as the most common indicator of economic performance. We chose it because prosperity and economic health are generally correlated to a higher standard of living because of increased access to goods and services in addition to stronger healthcare and education. However, depending on how resources are distributed in a given society, this may not necessarily be the case.
In our app, you’ll find a country’s gross GDP in a given year as well as a country’s GDP by capita (per person). 
"
  }) 
  
  output$giniText <- renderText({
    "The Gini index (or Gini coefficient) is a measure of income inequality within a given population. 
    It ranges from 0 to 1, with perfect equality represented by 0 (everyone has equal wealth) and perfect inequality represented by 1 (one person has all the wealth and nobody else). 
    A higher Gini index indicates greater inequality, meaning that wealth is concentrated in the hands of fewer people. 
    In contrast, lower values imply a more equitable distribution of wealth. 
    We included this variable in our app because 1) inequality affects how gross GDP can improve an individual’s quality of life and 2) we wanted to investigate how inequality correlates to factors like adult obesity and happiness.
"
    
  })
  
  output$happinessText <- renderText({
    "The World Happiness Report assesses and ranks countries according to factors that influence subjective well-being and happiness. 
    Of these factors such as “GDP per capita”, “social support”, “freedom to make life choices”, “generosity”, and more, we selected “positive affect”. 
    Positive affect specifically refers to the frequency of positive emotions like joy and satisfaction, and a higher score indicates that the population tends to feel happy and content more often. 
    We chose this specific measure because we felt it most directly represented general happiness and/or subjective quality of life."
    
  })
  
  
  #LONGITUDINAL CHLOROPLETHS
  #Expression for filtered data 
  
  color_columns <- list(
    "obese_overweight_adults" = "percentBMI30",  
    "GDP_tidy" = "gdp",                         
    "Gini_Inequality_Index_tidy" = "gini_inequality_index",  
    "happiness_index_tidy" = "positive_affect"   
  )
  
  color_column <- reactive({
    req(input$GlobalFactor)  # Ensure input$GlobalFactor is available
    
    observe({
      print(paste("Selected Global Factor:", input$GlobalFactor))
      print(paste("Selected column name:", color_column()))
    })
    
    
    # Check if the input value exists in the color_columns list
    if (input$GlobalFactor %in% names(color_columns)) {
      # Return the corresponding column name
      return(color_columns[[input$GlobalFactor]])
    } else {
      # If invalid input, return NULL and handle it gracefully
      stop("Invalid global factor selected.")
    }
  })
  
  
  filtered_data <- reactive({
    
    selected_year <- as.integer(format(input$year, "%Y"))
    print(paste("Filtering data for year:", selected_year))
    
    data <- switch(input$GlobalFactor,
                   "obese_overweight_adults" = obese_overweight_adults,
                   "GDP_tidy" = GDP_tidy,
                   "Gini_Inequality_Index_tidy" = Gini_Inequality_Index_tidy,
                   "happiness_index_tidy" = happiness_index_tidy,
                   stop("Unknown factor"))
    
    
    # Replace all NA values with 0 across the entire dataset
    data[is.na(data)] <- 0
    
    
    # Filter data for the selected year
    filtered <- data %>%
      filter(year == selected_year) %>%
      select(c("country", color_column()))

    # Get percentiles for comparison from the selected column (color_column)
    filtered <- filtered %>%
      mutate(
        percentile = ntile(get(color_column()), 100)
      )
    

    return(filtered)
    

  })
  
  
  #Render leaflet map
  output$map <- renderLeaflet({
    leaflet(geo) %>%
      addTiles() %>%
      setView(lng = 0, lat = 20, zoom = 2) %>%
      addPolygons(
        fillColor = "white", # Default color
        fillOpacity = 0.7,
        weight = 1,
        color = "white",
        dashArray = "3"
      )
  })
  
  #Include text box for "year_info"
  output$year_info <- renderText({
    "
    Adult Obesity: 1975 - 2016
    Gross GDP: 1988 - 2016
    Gini Inequality Index: 1975 - 2005
    Happiness Index: 2005 - 2016
    "
  })
  
  # Observe changes and update map

  
  observe({
    # Get filtered data
    data <- filtered_data()
    
    # Join the data with geographic data
    geo@data <- left_join(
      geo@data, 
      data, 
      by = c("name" = "country")) #c("name" = "country")) returns functionally bc i changed the names but "id" = "code" doesn't?
    
    #getting the correct column dynamically 
    color_col <- color_column()
    
    # Define color palette
    bins <- seq(0, 100, by = 10) #bins by 10 percentiles
    pal <- colorBin("YlOrRd", domain = geo@data$percentile, bins = bins)
    
    # Update polygons with new data based on percentile
    leafletProxy("map", data = geo) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~pal(geo@data$percentile), #hard coded: ~pal(percentBMI30)
        fillOpacity = 0.7,
        weight = 1,
        color = "white",
        dashArray = "3",
        highlight = highlightOptions(
          weight = 2,
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE
        ), 
        
        # Add popup with country name, value of thing, and percentile
        popup = ~paste(
          "<strong>Country:</strong>", name, "<br>",
          "<strong>", color_col, ":</strong>", geo@data[[color_col]], "<br>",
          "<strong>Percentile Rank:</strong>", geo@data$percentile
      )
    )
  })
  
  
  #CORRELATIONAL STUFF
  output$pearsoncorrelationText <- renderText({
    "In this box, we're going to talk about what Pearson correlations are, and the Pearson correlations between our variables."
    
  })
  
  # Define Pearson Correlation
  output$correlationdefinitionText <- renderText({
    "Pearson correlations are a way to measure the linear correlation between two different variables.
The pearson correlation coefficient is a number between -1 and 1 that can measure how strong the 
relationship between the two variables are, along with the direction in which the correlation goes 
(positive or negative)."
  })
  
  #prepare the data sets!
  #obesity
  unfiltered_obesity_df <- read.csv("obese_overweight_adults.csv")
  filtered_obesity_df <- unfiltered_obesity_df %>%
    select(1, 2, 3, 4) %>%
    filter(unfiltered_obesity_df$year == 2016)
  
  
  #happiness
  unfiltered_happy_df <- read.csv("happiness_index_tidy.csv") 
  filtered_happy_df <- unfiltered_happy_df %>%
    select(2, 3, 4, 12) %>%
    filter(unfiltered_happy_df$year == 2016)
  
  #gdp
  unfiltered_gdp_df <- read.csv("GDP_tidy.csv")
  filtered_gdp_df <- unfiltered_gdp_df %>%
    select(2, 3, 5, 6) %>%
    filter(unfiltered_gdp_df$year == 2016)
  
  country_pop <- read.csv("country_pop.csv") 
  country_pop <- country_pop %>%
    select(2, "X2016")
  
  colnames(country_pop)[colnames(country_pop) == "Country.Code"] <- "Code"
  colnames(country_pop)[colnames(country_pop) == "X2016"] <- "Population"
  
  #table joins
  
  result <-  filtered_obesity_df %>%
    left_join(filtered_happy_df, by = "country")
  
  variables_df <- result %>%
    left_join(filtered_gdp_df, by = "country")
  
  variables_df <- variables_df %>%
    left_join(country_pop, by = c("code.x" = "Code"))
  
  print(colnames(variables_df))
  
  variables_df <- variables_df %>%
    select(1, 4, 7, 8, 9, 10, 11) 
  
  print(colnames(variables_df))
  
  
  #Get rid of NA gdp rows, then create a column with calculated gdp_per_capita
  clean_variables_df <- variables_df %>%
    filter(!is.na(gdp) & !is.na(Population)) %>%  # Use 'variables_df' instead of 'filtered_variables_df'
    mutate(gdp_per_capita = (gdp / Population))
  
  print(colnames(variables_df))  #okay did it give me the columns i wanted or not
  
  
  #Correlation time
  print(head(clean_variables_df))
  
  correlation_plot <- reactive({
    # Switch logic to determine variables for the selected correlation
    switch(input$correlation_type,
           "Obesity_GDPpercapita_plot" = {
             correlation <- cor(clean_variables_df$gdp_per_capita, clean_variables_df$percentBMI30, method = "pearson", use = "complete.obs")
             ggplot(clean_variables_df, aes(x = gdp_per_capita, y = percentBMI30)) +
               geom_point(color = "blue", alpha = 0.7) +  # Scatter plot
               geom_smooth(method = "lm", color = "red", se = TRUE) +  # Line of best fit
               geom_text_repel(aes(label = country), size = 3) +  # Add country labels
               labs(
                 title = "GDP per Capita vs Obesity Rate",
                 subtitle = paste("Pearson Correlation: ", round(correlation, 2)),
                 x = "GDP per Capita",
                 y = "Obesity Rate"
               ) +
               theme_minimal()
           },
           "Obesity_GDP_plot" = {
           correlation <- cor(clean_variables_df$gdp, clean_variables_df$percentBMI30, method = "pearson", use = "complete.obs")
             ggplot(clean_variables_df, aes(x = gdp, y = percentBMI30)) +
               geom_point(color = "blue", alpha = 0.7) +  # Scatter plot
               geom_smooth(method = "lm", color = "red", se = TRUE) +  # Line of best fit
               geom_text_repel(aes(label = country), size = 3) +  # Add non-overlapping country labels
               labs(
                 title = "Gross GDP vs Obesity Rate",
                 subtitle = paste("Pearson Correlation: ", round(correlation, 2)),
                 x = "Gross GDP",
                 y = "Obesity Rate"
               ) +
               theme_minimal()
            },
  
           "Happiness_GDPpercapita_plot" = {
             correlation <- cor(clean_variables_df$gdp_per_capita, clean_variables_df$positive_affect, method = "pearson", use = "complete.obs")
             ggplot(clean_variables_df, aes(x = gdp_per_capita, y = positive_affect)) +
               geom_point(color = "blue", alpha = 0.7) +  # Scatter plot
               geom_smooth(method = "lm", color = "red", se = TRUE) +  # Line of best fit
               geom_text_repel(aes(label = country), size = 3) +  # Add country labels
               labs(
                 title = "GDP per Capita vs Happiness",
                 subtitle = paste("Pearson Correlation: ", round(correlation, 2)),
                 x = "GDP per Capita",
                 y = "Happiness (Positive Affect)"
               ) +
               theme_minimal()
           },
           
           "Happiness_GDP_plot" = {
           correlation <- cor(clean_variables_df$gdp, clean_variables_df$positive_affect, method = "pearson", use = "complete.obs")
             ggplot(clean_variables_df, aes(x = gdp_per_capita, y = positive_affect)) +
               geom_point(color = "blue", alpha = 0.7) +  # Scatter plot
               geom_smooth(method = "lm", color = "red", se = TRUE) +  # Line of best fit
               geom_text_repel(aes(label = country), size = 3) +  # Add non-overlapping country labels
               labs(
                 title = "Gross GDP vs Happiness Level",
                 subtitle = paste("Pearson Correlation: ", round(correlation, 2)),
                 x = "GDP per Capita",
                 y = "Happiness Level"
               ) +
               theme_minimal()
           },
           
           "Obesity_Happiness_plot" = {
           correlation <- cor(clean_variables_df$percentBMI30, clean_variables_df$positive_affect, method = "pearson", use = "complete.obs")
             ggplot(clean_variables_df, aes(x = percentBMI30, y = positive_affect)) +
               geom_point(color = "blue", alpha = 0.7) +  # Scatter plot
               geom_smooth(method = "lm", color = "red", se = TRUE) +  # Line of best fit
               geom_text_repel(aes(label = country), 
                               size = 3, 
                               max.overlaps = 100) +  # Increase max.overlaps
               labs(
                 title = "Obesity Rate vs Happiness Level",
                 subtitle = paste("Pearson Correlation: ", round(correlation, 2)),
                 x = "Obesity Rate",
                 y = "Happiness Level"
               ) +
               theme_minimal()
           }
    )
  })
  
  # Render the selected correlation plot
  output$dynamic_correlation_plot <- renderPlot({
    correlation_plot()
  })
  
  #LEAFLET ON FAST FOOD MAP MANIA ("map2")
  coordinates <- read.csv("Copy of International Domino's Locations (Finalized) - Sheet1.csv")
  coordinates_McDonalds <- read.csv("McDonalds Global.csv")
  coordinates_Starbucks <- read.csv("Starbucks.csv")
  
  #Select and return data set corrresponding to drop-down choice
  filtered_coordinates <- reactive({                                                   
    switch(input$fastFoodDataset,                                                      # Switches based on the user's dropdown selection.
           "coordinates" = coordinates,      
           "coordinates_Starbucks" = coordinates_Starbucks,
           "coordinates_McDonalds" = coordinates_McDonalds)
  })
  
  
  output$map2 <- renderLeaflet({                                                      
    leaflet() %>%                                                                      
      addTiles() %>%                                                                   
      setView(lng = 0, lat = 20, zoom = 2)                                             
  })
  
  observe({                                                                            
    data <- filtered_coordinates()                                                     
    data <- data %>%
      filter(!is.na(longitude) & !is.na(latitude) &                                   
               longitude != 0 & latitude != 0) 
      
    leafletProxy("map2") %>%                                                           
      clearMarkers() %>%                                                               
      clearMarkerClusters() %>%  
      addMarkers(data = data,                                                         
                 lng = ~longitude,                                                     
                 lat = ~latitude,                                                     
                 label = ~address,                                                   
                 clusterOptions = markerClusterOptions())
      
    })
  
  #Define raw description header text
  output$rawdescText <- renderText({
    "Select a factor to view its corresponding data set!"
  })
  
  # Create a reactive expression to select the appropriate data based on the input
  selected_data <- reactive({
    switch(input$GlobalFactor2,
           "obese_overweight_adults" = obese_overweight_adults,
           "GDP_tidy" = GDP_tidy,
           "Gini_Inequality_Index_tidy" = Gini_Inequality_Index_tidy,
           "happiness_index_tidy" = happiness_index_tidy,
           stop("Unknown factor")
    )
  })
  
  #column select checkboxes
  output$checkbox <- renderUI({
    data <- selected_data()
    checkboxGroupInput(inputId = "columns",
                       label = "Select columns",
                       choices = colnames(data),
                       selected = colnames(data),
                       inline = TRUE) 
  })
  
  # spits out table
  output$data_table <- renderTable({
    data <- selected_data()
    selected_columns <- input$columns
    data[, selected_columns, drop = FALSE] 
    
    if (length(selected_columns) > 0) {
      return(data[, selected_columns, drop = FALSE])  
    } else {
      return(NULL)
    }
  })
  
  #if there's nothing selected, it'll tell you. if not, the text box won't
  output$null_message <- renderText({
    selected_columns <- input$columns
    
    if (length(selected_columns) == 0) {
      return("Please select a column to view!")} 
    else {
      return(NULL)
    }
  })

  #PROBABLY NEED TO INSERT PEARSON THINGS HERE FOR SERVER SIDE
  # output$ggPlot <- renderPlot
  
  
  
  
  }
)
