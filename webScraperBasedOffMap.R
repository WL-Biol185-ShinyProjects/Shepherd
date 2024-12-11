
library(dplyr)
library(rvest)
library(RCurl)

# Subway website
subway <- "https://restaurants.subway.com"

# Web Parser Function
addressParser <- function(url) {   
  
  if (!url.exists(url)) { return(NA) }
  
  hrefs <- read_html(url) %>%                                                   
    html_elements(".Directory-listLink") %>%     
    html_attr("href")
  
  # Absolute URLs
  formattedHrefs <- gsub("../", "", hrefs, fixed = TRUE) 
  link <- paste(subway, formattedHrefs, sep = "/")
  
  print(length(link))
  print(link)
  
  if (length(link) == 1 && link == "https://restaurants.subway.com/index.html" || link == "https://restaurants.subway.com/") {
    return(NA)
  }
  
  # Needed to check if url is the address page
  addressLink <- read_html(url) %>%
    html_elements(".c-address") %>%
    html_elements("#address") 
  # Needed for the other address format check to work
  dirlistLink <- read_html(url) %>% 
    html_elements(".Directory-listLink") 
  # Needed to check for teaserLink
  teaserLink <- read_html(url) %>% 
    html_elements(".Teaser-innerWrapper") 
  # If length(class dir-list) == 0
  if (length(dirlistLink) == 0) {
    
    # TRUE: Check if length(class Teaser title) > 0)
    if (length(teaserLink) > 0) {
      
      # TRUE: get HREF
      
      teaserHrefs <- read_html(url) %>%                                                   
        html_elements(".Teaser-title") %>%     
        html_attr("href") 
      # Absolute Link based on new HREF
      formattedTeaserHrefs <- gsub("^((\\.\\./)+)", "", teaserHrefs)
      teaserAddressLink <- paste(subway, formattedTeaserHrefs, sep = "/")
      # Extract address 
      
      if (length(teaserLink) == 1) {
        addressParser(teaserAddressLink)
      } else {
        c(lapply(teaserAddressLink, addressParser), recursive = TRUE)  
      }
      
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
  
    if (length(addressLink) == 0) {
      
      c(lapply(link, addressParser), recursive = TRUE)
      
    } else if (url == addressLink) {
      
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



# Calling function on Subway website
addressParser(subway)


#  if (grepl("additional-locations", link)) {
#   invalid <- link
#   NA }
  
  