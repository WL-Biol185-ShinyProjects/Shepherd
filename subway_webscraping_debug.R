library(dplyr)
library(rvest)

subway <- "https://restaurants.subway.com"

addressParser <- function(url) {                                
  hrefs <- read_html(url) %>%                                                          
    html_elements(".Directory-listLink") %>%     
    html_attr("href")
  formattedHrefs <- gsub("../", "", hrefs, fixed = TRUE)
  link <- paste(subway, formattedHrefs, sep = "/")
  
  other_address <- read_html(url) %>%
    html_elements(".Teaser-innerWrapper")
  if (length(other_address) > 0) {
    hrefs <- read_html(url) %>%                                                          
      html_elements(".Teaser-title") %>%     
      html_attr("href")
    
     print(link)
  } else if (url == "https://restaurants.subway.com/index.html") {
    NA
  } else if (length(hrefs) == 0) {
    url %>%
      read_html %>%
      html_element("#address") %>%
      html_text2()
  } else {
    c(lapply(link, addressParser), recursive = TRUE)      
  }
}

addressParser(subway)
