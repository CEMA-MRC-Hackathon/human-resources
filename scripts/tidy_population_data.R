library(tidyverse)
library(readxl)

raw_data <- read_excel("data/Population projections_percounty.xlsx",
                       range = "E2:W49")

data <- raw_data |>
  select(District, `2024`) |>
  rename(district = District,
         population = `2024`)

# Check all districts are present
n_districts <- nrow(data)

if (n_districts != 47) {
  warning(
    sprintf("There are %s districts present, when there should be 47",
                  n_districts)
  )
}

# Check total population is reasonable
message(
  sprintf("The total 2024 population of Kenya is %.3g million",
          sum(data$population) / 1e6)
)

# Save data for onward analysis
saveRDS(data, "./outputs/data_population.rds")



