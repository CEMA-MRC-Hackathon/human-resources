library(tidyverse)
library(readxl)

raw_data <- read_excel("./data/population in need of services.xlsx")

data <- raw_data |>
  rename(category = `Disease/Risk Factor`,
         number = `2024`) |>
  select(category, number) |>
  filter(str_detect(category, "HIV")) |>
  mutate(proportion = number / sum(number))

message(sprintf("The total population in need of services is %.3g million",
                sum(data$number) / 1e6))

saveRDS(data, "./outputs/data_national_population_needing_services_by_category.rds")
