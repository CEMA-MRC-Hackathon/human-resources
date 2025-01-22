library(tidyverse)

raw_data <- read_csv("./data/Kenya-PLHIV-ART-Catchment.csv")

data <- raw_data |>
  filter(level == 2) |>
  rename(district = area,
         number_needing_treatment = mean) |>
  select(district, number_needing_treatment)

saveRDS(data, "./outputs/data_number_needing_treatment_by_county.rds")
