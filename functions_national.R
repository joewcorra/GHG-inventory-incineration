

get_tire_incineration <- function(tire_composition,
                                  tire_usage,
                                  incineration_factors) {

weighted_averages_tires <- tire_composition %>%
  group_by(year, tire_type) %>% 
  # Calculate weight of disposed tires by year and type
  summarize(tires_disposed = weight * percent_disposed, 
            rubber = percent_disposed * percent_synthetic_rubber, 
            cb = percent_disposed * percent_carbon_black) %>%
  # Now sum weights by year
  summarize(average_tires_disposed = sum(tires_disposed), 
            average_rubber = sum(rubber),
              average_cb = sum(cb)) %>%
  ungroup()
  
tire_incineration <- tibble(year = 1990:2022) %>%
  left_join(tire_usage %>%
              # retain tires burned for fuel only
              filter(fuel == TRUE) %>%
              group_by(year) %>%
              summarize(tires_used = sum(value, na.rm = TRUE)), 
            by = "year") %>%
  ungroup() %>%
  # Interpolate usage values for missing years
  mutate(tires_used = case_when(
    # Special case for 1999 since there is a 3-year data gap
    year == 1999 & is.na(tires_used) ~ lag(tires_used, 1) + ((lead(tires_used, 2) - lag(tires_used, 1)) / 3),
    is.na(tires_used) ~ lag(tires_used, 1) + ((lead(tires_used, 1) - lag(tires_used, 1)) / 2), 
    .default = tires_used)) %>%
  # Special case for 2000 since 1999 value must be determined first
  mutate(tires_used = if_else(year == 2000 & is.na(tires_used), 
                              lag(tires_used, 1) + ((lead(tires_used, 2) - lag(tires_used, 1)) / 3),
                              tires_used)) %>%
  left_join(weighted_averages_tires, by = "year") %>%
  mutate(tires_incinerated = case_when(
    # Different method depending on year(pre or post 2005)
    year <= 2004 ~ tires_used * average_tires_disposed / incineration_factors["short_tons_to_lbs"] * 1000,
    .default = tires_used)) %>%
  # Different method in 2008, 2010, 2012
  mutate(tires_incinerated = if_else(year %in% c(2008, 2010, 2012), 
                                     lag(tires_incinerated, 1) + ((lead(tires_incinerated, 1) - lag(tires_incinerated, 1)) / 2), 
                                     tires_incinerated))
return(tire_incineration)

}
  

get_msw_other_incineration <- function(msw, 
                                       tire_incineration) {
  
  msw_other_incineration <- msw %>% 
    left_join(tire_incineration %>% 
                select(year, tires_incinerated), 
              by = "year") %>%
    mutate(msw_incinerated = msw * discarded * incineration_factors["short_tons_to_metric_tons"] * incinerated, 
           msw_combined = msw_incinerated / incineration_factors["short_tons_to_metric_tons"],
           msw_no_tires = msw_combined - tires_incinerated) %>%
    tanagerharmonize::pre_clean()
  
  return(msw_other_incineration)
  
}


get_tires_emissions <- function(tire_incineration, 
                                incineration_factors) {
  
  tires_emissions <- tire_incineration %>%
    mutate(cb_emissions = tires_incinerated / 1000 * 
             average_cb * 
             incineration_factors["c_content_carbon_black"] * 
             incineration_factors["short_tons_to_metric_tons"],
           rubber_emissions = tires_incinerated / 1000 * 
             average_rubber * 
             incineration_factors["c_content_rubber"] * 
             incineration_factors["short_tons_to_metric_tons"], 
           co2_emissions = incineration_factors["carbon_to_carbon_dioxide"] * 
             (rubber_emissions + cb_emissions))
  
  return(tires_emissions)
  
}


get_ghgrp_emissions <- function(ghgrp_msw_combustors) {
  
  # 2011-present data
  ghgrp_emissions <- ghgrp_msw_combustors %>%
    rename(year = reporting_year)  %>%
    group_by(year) %>%
    summarize(ghg_quantity = sum(ghg_quantity_metric_tons_co2e, na.rm = TRUE) * 1000, 
              waste = sum(short_tons_waste, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(waste_carbon_content = ghg_quantity / waste) 
  
  # Add pre-2011 data using the average of the 2011-present data
  pre_ghgrp_data <- tibble(year = as_factor(1990:2011), 
                           waste_carbon_content = mean(ghgrp_emissions$waste_carbon_content))
  
  
  ghgrp_emissions <- bind_rows(ghgrp_emissions %>% 
                                 select(year, waste_carbon_content), 
                               pre_ghgrp_data)
  
  return(ghgrp_emissions)
  
}

get_msw_other_emissions <-function(ghgrp_emissions, 
                                   msw_other_incineration) {
  
  msw_other_emissions <- msw_other_incineration %>%
    left_join(ghgrp_emissions, by = "year") %>%
    mutate(co2_emissions = waste_carbon_content * msw_no_tires / 10^9)
    
  return(msw_other_emissions)
  
  
}