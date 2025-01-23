library(tidyverse)
library(ggmap)
library(sf)
library(scales)


raw_sf_data <- sf::st_read("./data/county_shapefiles/ken_admbnda_adm1_iebc_20191031.shp")
data_number_needing_care_by_county <- readRDS("./outputs/data_number_needing_treatment_by_county.rds")
data_available_time_resources <- readRDS("./outputs/data_available_time_resources.rds")

# Look for discrepancies in district names
setdiff(raw_sf_data$ADM1_EN, data_number_needing_care_by_county$district)
setdiff(data_available_time_resources$district, raw_sf_data$ADM1_EN)

# Correct district names in shapefiles to match those used throughout analysis
sf_data <- raw_sf_data |>
  mutate(district = case_when(
    ADM1_EN == "Taita Taveta" ~ "Taita-taveta",
    ADM1_EN == "Tharaka-Nithi" ~ "Tharaka-nithi",
    ADM1_EN == "Trans Nzoia" ~ "Trans-nzoia",
    ADM1_EN == "Elgeyo-Marakwet" ~ "Elgeyo-marakwet",
    ADM1_EN == "Nairobi" ~ "Nairobi (county)",
    TRUE ~ ADM1_EN
  ))

# Check again for discrepancies
setdiff(sf_data$district, data_number_needing_care_by_county$district)

results <- sf_data |>
  left_join(data_number_needing_care_by_county) |>
  left_join(data_available_time_resources) |>
  rename(`Days available per year` = days_per_year)

unique(results$cadre)
y <- "Days available per year"
x <- "Medical Officer"

results |>
  filter(cadre == x) |>
  ggplot() +
  geom_sf(aes(fill = !!sym(y))) +
  theme_minimal() +
  scale_fill_viridis_c(labels = scales::comma) +
  labs(title = y, subtitle = x, fill = "Number")



