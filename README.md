Collection and calculation of GHG emissions data from waste incineration. 
GHG-inventory-incineration is a collection of scripts designed to facilitate the compilation and analysis of emissions data from waste incineration. 
This project is part of the Inventory of U.S. Greenhouse Gas Emissions and Sinks and is aimed at retrieving, processing, and reporting emissions data at
both national and state levels. The project integrates data retrieval, transformation, and reporting, with built-in automated QA/QC (quality assurance/quality control) 
capabilities.

## Features

Data Retrieval: Retrieve emissions data from local files, web scraping, or APIs.

Data Processing: Collate and transform the data to compute emissions.

Emissions Calculation: Calculate emissions for both national and state-level datasets.

Reporting: Generate detailed reports and data outputs based on the compiled data.

## Installation

Clone the repository to your local machine: git clone https://github.com/USEPA/GHG-inventory-incineration.git

Ensure that you have the required R packages installed. 
You can install any missing dependencies by running the following in your R console: install.packages(c("extrafont", "gt", "gtExtras", "httr", "janitor", "jsonlite", "knitr", "labelled", "quarto", "reactable", "roxygen2", "rvest", "showtext", "tidyverse", "pins", "targets", "visNetwork", "tarchetypes")

## Usage

This repository contains two main components:

National Waste Incineration Emissions Calculation To compute emissions data at the national level, use functions_both.R and functions_national.R. These scripts call on other source scripts and compile data from multiple sources.

State-Level Waste Incineration Emissions Calculation To compute emissions data at the state level, use functions_both.R, functions_national.R, and functions_state.R. The latter script processes state-specific data.

## Data Sources

Emissions data is retrieved from various sources, including

The specific sources for each dataset are defined within the respective source scripts.

## Citation

If you use this software in a scientific publication, please cite it. Citation helps support the continued development and maintenance of the tool and ensures appropriate credit for the methods used.

Preferred citation:

Corra, J. 2025. GHG-inventory-incineration: A toolkit for retrieving, processing, and reporting solid waste incineration emissions data for the U.S. Greenhouse Gas Inventory, with support for both national and state-level analyses. GitHub repository: https://github.com/joewcorra/GHG-inventory-incineration


You may also import the citation automatically using the CITATION.cff file included in this repository (supported by GitHub, Zenodo, and many reference managers).

If your work makes substantial use of this code, or if you would like to discuss methodological details or potential collaboration, please feel free to contact me.

---

