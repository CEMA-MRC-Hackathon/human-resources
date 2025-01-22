library(tidyverse)

# Read in data:
# 1) prevalence by county
# 2) population by county
data_prevalence <- readRDS("./outputs/data_hiv_prevalence.rds")
data_population <- readRDS("./outputs/data_population.rds")

# calculate disease burden by county
data <- left_join(data_population, data_prevalence) |>
  mutate(burden = prevalence * population)

# save the results
saveRDS(data, "./outputs/results_disease_burden.rds")
