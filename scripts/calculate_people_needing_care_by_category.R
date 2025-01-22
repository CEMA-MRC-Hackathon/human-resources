library(tidyverse)
# Read in data
data_national_proportion_by_category <-
  readRDS("./outputs/data_national_population_needing_services_by_category.rds")
data_number_needing_care_by_county <-
  readRDS("./outputs/data_number_needing_treatment_by_county.rds")

# Calculate number needing care by category in each county, assuming that national
# proportions in each category hold.

results <- cross_join(data_number_needing_care_by_county,
                      data_national_proportion_by_category) |>
  mutate(number_needing_care_by_category = round(number_needing_treatment * proportion)) |>
  select(district, category, number_needing_care_by_category)

saveRDS(results, "./outputs/results_number_needing_care_by_category.rds")

