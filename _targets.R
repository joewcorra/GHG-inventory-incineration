# Targets Pipeline Setup----------------------

# Load packages
library(pins)
library(targets)
library(visNetwork)
library(tarchetypes)


targets::tar_option_set(
  error = "null",
  # garbage_collection = TRUE,
  packages = c(
    "extrafont", "gt", "gtExtras", "httr", "janitor",
    "jsonlite", "knitr", "labelled", 
    "quarto", "reactable", "roxygen2", "rvest",
    "showtext", "tidyverse"
  )
)

# Source custom functions for FFC data
source("functions_national.R")
# source("functions_state.R")
# source("functions_both.R")

# Define the pins board for data retrieval
board <- board_folder("data/pins", versioned = TRUE)

# Define the Pipeline-------------------------------------------

list(
  
  ## Data Retrieval------------------
  
  ### Both national and state------------------------------
  tar_target(
    incineration_factors,
    pin_read(board, "incineration_factors") %>%
      tibble::deframe()
  ),
  
  tar_target(
    msw,
    pin_read(board, "msw")
  ),
  
  tar_target(
    tire_composition,
    pin_read(board, "tire_composition")
  ),
  
  tar_target(
    tire_usage,
    pin_read(board, "tire_usage")
  ), 
  
  tar_target(
   ghgrp_msw_combustors,
    pin_read(board, "ghgrp_msw_combustors")
  )
  
)