# Load required packages
library(shiny)
library(shinydashboard)
library(httr2)
library(tidyverse)
library(DT)
library(shinyjs)
library(writexl)

# System configuration
system_config <- list(
    dhis2_url = Sys.getenv("DHIS2_URL"),
    api_username = Sys.getenv("DHIS2_API_USERNAME"),
    api_password = Sys.getenv("DHIS2_API_PASSWORD")
)



# Source helper functions
source("R/dhis2_api.R")
source("R/excel_handler.R")
source("R/utils.R") 
