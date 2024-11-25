# Load required packages
library(shiny)
library(shinydashboard)
library(readxl)
library(writexl)
library(httr2)
library(tidyverse)
library(DT)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)

# Configuration
config <- list(
    dhis2_url = Sys.getenv("DHIS2_URL"),
    dhis2_username = Sys.getenv("DHIS2_USERNAME"),
    dhis2_password = Sys.getenv("DHIS2_PASSWORD"),
    max_file_size = 10 * 1024^2  # 10MB
)

# Source helper functions
source("R/dhis2_api.R")
source("R/excel_handler.R")
source("R/utils.R") 