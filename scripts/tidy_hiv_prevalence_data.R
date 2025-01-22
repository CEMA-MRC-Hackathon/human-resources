library(tidyverse)
library(readxl)

raw_data <- read_excel("./data/HIV_Prevlance percounty.xlsx", range = "B2:D49")

# read in data and format to be consistent with other data sets
data <- raw_data |>
  rename(district = District,
         prevalence = `District % share of Population (a)`) |>
  select(district, prevalence)

# Save data for onward analysis
saveRDS(data, "./outputs/data_hiv_prevalence.rds")
