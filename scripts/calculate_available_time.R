library(tidyverse)

# Read in data
data_working_time_by_cadre <- readRDS("./outputs/data_working_time_by_cadre.rds")
data_available_resources <- readRDS("./outputs/data_available_resources.rds")

# Currently all of cadres have the same time resources per year so can simply filter the first row
data_working_time <- data_working_time_by_cadre |>
  filter(id_cadre == "HW1")

# Calculate available time resources by cadre and district
data_available_time_resources <-
  data_available_resources |>
  rename(number = value) |>
  mutate(days_per_year = number * data_working_time$days_per_year,
         hours_per_year = number * data_working_time$hours_per_year,
         minutes_per_year = number * data_working_time$minutes_per_year)

# Save results
saveRDS(data_available_time_resources,
        "./outputs/data_available_time_resources.rds")
