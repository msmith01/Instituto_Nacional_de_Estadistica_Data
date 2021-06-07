rm(list=ls())
options(scipen = 999)
library(rvest)
library(tidyverse)
library(purrr)
library(stringr)
library(jsonlite)

setwd("/home/bscuser/Escritorio/mobility")

get_expand_url <- function(url) {
  link <- read_html(url) %>%
    html_node(".inebase_capitulo:nth-child(2) .desplegar") %>%
    html_attr("href") %>%
    url_absolute(url)
  return(link)
}

get_provincias_links <- function(url) {
  provincias <- read_html(url) %>%
    html_nodes(".respuestas > .inebase_capitulo:nth-child(2) .inebase_capitulo [id^=c_]") %>%
    html_attr("href") %>%
    url_absolute(url)
  return(provincias)
}

get_details <- function(provincia_url, n) {
  node <- read_html(provincia_url) %>%
    html_node(sprintf(".respuestas > .inebase_capitulo:nth-child(2) .inebase_capitulo:nth-child(%i)", n))
  
  provincia <- node %>%
    html_node(xpath = ".//span/following-sibling::text()[1]") %>%
    html_text(trim = T)
  
  df <- data.frame(
    index = node %>%
      html_nodes(".indice:nth-child(n+3)") %>%
      html_text(),
    
    title = node %>%
      html_nodes("span +.titulo") %>%
      html_text(),
    
    link = node %>%
      html_nodes("span +.titulo") %>%
      html_attr("href") %>% url_absolute(start_url)
  )
  df$provincia <- provincia
  return(df)
}

start_url <- "https://www.ine.es/dynt3/inebase/index.htm?padre=5608"

expand_url <- get_expand_url(start_url)
provincias_links <- get_provincias_links(expand_url)
indices <- 1:length(provincias_links)

df <- purrr::map2_dfr(provincias_links, indices, .f = get_details)

df <- df %>% 
  mutate(
    provincesFolderLocationsNames = str_replace_all(provincia, "/", "_"),
    provincesFolderLocationsNames = str_replace_all(provincesFolderLocationsNames, ",", ""),
    provincesFolderLocationsNames = str_replace_all(provincesFolderLocationsNames, " ", "_"),
    
    titleFolderLocationsNames = str_replace_all(title, "/", "_"),
    titleFolderLocations = paste(getwd(), "data/INE", titleFolderLocationsNames, sep = "/")
  ) %>% 
  mutate(across(where(is.factor), as.character))



# create the folders for each province
setwd("/home/bscuser/Escritorio/mobility/")
dir.create(paste(getwd(), "/data/INE/", sep = ""))
economicDataNames <- unique(df$titleFolderLocations)
economicDataNames %>% 
  map_chr(., ~ dir.create(.x, showWarnings = FALSE))

# create the URLs to download the JSON data
createURLS <- function(x){
  sprintf('https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/%s?tip=AM&', stringr::str_match(x, 't=(\\d+)')[,2])
}

df$json_link <- lapply(df$link, createURLS)
#df$`json_link` <- lapply(df$link, function(x) {sprintf('https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/%s?tip=AM&', stringr::str_match(x, 't=(\\d+)')[,2])} )

df2 <- df %>% 
  mutate(
    rowID = row_number()
  ) %>% 
  group_by(provincia) %>% 
  mutate(
    groupID = row_number()
  )
  # ungroup() %>% 
  # filter(
  #   title != "Porcentaje de población con ingresos por unidad de consumo por debajo/encima de determinados umbrales relativos por sexo y tramos de edad",
  #   title != "Porcentaje de población con ingresos por unidad de consumo por debajo/encima de determinados umbrales relativos por sexo y nacionalidad"
  #   )

# Function to collect the JSON files and store them in each of the folders

# jsonLink = df2$json_link[1] %>% unlist()
# provinceFolderLoc = df2$provincesFolderLocations[1]
# titleFolderLocations = df$titleFolderLocations[1]
# provincesFolderLocationsNames = df$provincesFolderLocationsNames[1]

downloadAndStoreJSONData <- function(jsonLink, titleFolderLocations, provincia, rowID, groupID, provincesFolderLocationsNames){
  destFileLocation = paste(titleFolderLocations, "/", provincesFolderLocationsNames, ".json", sep = "")
  
  if(file.exists(destFileLocation)){
    print(paste("File already exists! skipping..."))
  } else{
    print(paste("Processing: ", provincia, ".", "Group number: ", groupID, "Row number: ", rowID, "Location: ", titleFolderLocations))
    jsonLink = jsonLink %>% unlist()
    download.file(url = jsonLink, destfile = destFileLocation)
    Sys.sleep(1 + rnorm(1, mean = 1, sd = 0.25)) 
  }
}

POSSIBLYdownloadAndStoreJSONData <- possibly(downloadAndStoreJSONData, otherwise = NA_character_)

pmap(list(df2$json_link, df2$titleFolderLocations, df2$provincia, df2$rowID, df2$groupID, df2$provincesFolderLocationsNames), ~POSSIBLYdownloadAndStoreJSONData(..1, ..2, ..3, ..4, ..5, ..6))



##########################

# dat <- df2 %>% 
#   filter(provincia == "Alicante/Alacant")

lnk = df2 %>% 
  filter(rowID == "11") %>% 
  pull(json_link) %>% 
  unlist()
JSON_in = fromJSON(lnk)

