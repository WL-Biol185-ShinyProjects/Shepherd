
library(dplyr)
library(rvest)

# Web Parser Function
addressParser <- function(url) {   
  hrefs <- read_html(url) %>%                                                   
    html_elements(".Directory-listLink") %>%     
    html_attr("href") 
 
  # Absolute URLs
  formattedHrefs <- gsub("../", "", hrefs, fixed = TRUE) 
  link <- paste(subway, formattedHrefs, sep = "/")
  
  # Needed to check if url is the address page
  addressLink <- read_html(url) %>%
    html_elements("#address")
    html_text()
  # Needed for the other address format check to work
  dirlistLink <- read_html(url) %>% 
    html_elements(".Directory-listLink") 
  
  # If length(class dir-list) == 0
  if (length(dirlistLink) == 0) {
    
    # TRUE: Check if length(class Teaser title) > 0)
    teaserLink <- read_html(url) %>% 
      html_elements(".Teaser-innerWrapper") 
    
    if (length(teaserLink) > 0) {
      
      # TRUE: extract address 
      url %>%
        read_html %>% 
        html_element(".c-address") %>% 
        html_text2() 
      
      # Extract Address
      
      # FALSE: Check if url == faulty url
    } else {
      if (url == "https://restaurants.subway.com/index.html") { 
        
        # TRUE: NA
        NA 
        
        # FALSE: Extract address
      } else { 
        url %>%
          read_html %>% 
          html_element("#address") %>% 
          html_text2() 
      }
    }
  # If length(class dir-list) == 0 is FALSE: Check if it is an address page
  } else { 
    if (url == addressLink) {
      
      # TRUE: Extract address
      url %>%
        read_html %>% 
        html_element("#address") %>% 
        html_text2() 
      
      # FALSE: Call function again (recursion)
    } else {
      c(lapply(link, addressParser), recursive = TRUE)
        }
      }
}

# Subway website
subway <- "https://restaurants.subway.com"

# Calling function on Subway website
addressParser(subway)
  
  