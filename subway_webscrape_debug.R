# 
# # Loading in rvest package needed for web-scraping
#   
# library(dplyr)
# library(rvest)
# 
# 
# 
# subway <- "https://restaurants.subway.com"
# 
# 
# 
# addressParser <- function(url) {                                
#   hrefs <- read_html(url) %>%                                                          
#     html_elements(".Directory-listLink") %>%     
#     html_attr("href")
#   formattedHrefs <- gsub("../", "", hrefs, fixed = TRUE)
#   link <- paste(subway, formattedHrefs, sep = "/")        
#   print(link)
#   if (url == "https://restaurants.subway.com/index.html") {
#     NA
#   } else if (length(hrefs) == 0) {
#       url %>%
#       read_html %>%
#       html_element("#address") %>%
#       html_text2()
#     } else {
#     c(lapply(link, addressParser), recursive = TRUE)      
#   }
# }
# 
# addressParser(subway)






library(dplyr)
library(rvest)

subway <- "https://restaurants.subway.com"


addressParser <- function(url) {                                  
  hrefs <- read_html(url)                                                         
  element <- html_elements(hrefs,".Directory-listLink")                  
  if (length(element) > 0) {
    href <- html_attr(element, "href")
  }  else {
    other_element <- html_elements(hrefs,".Teaser-innerWrapper")
    href <- html_attr(other_element, "href")
  }

  formattedHrefs <- gsub("../", "", href, fixed = TRUE)
  link <- paste(subway, formattedHrefs, sep = "/")                   
  print(link)
  if (url == "https://restaurants.subway.com/index.html") {
    NA
  } else if (length(href) == 0) { 
    url %>%
      read_html() %>%
      html_element("#address") %>%
      html_text2()
  } else {
    c(lapply(link, addressParser), recursive = TRUE)      
  }
}

res <- addressParser(subway)
res



