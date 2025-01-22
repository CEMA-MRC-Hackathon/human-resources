library(readxl)
library(tidyverse)

raw_data <- read_excel("./data/Availabe working time.xlsx", range = "C3:G49")

data <- raw_data |>
  rename(id_cadre = `No.`,
         cadre = `List of cadres`,
         days_per_year = `Available Working Days Per Year`,
         hours_per_year = `Available Working Hours Per Year`,
         minutes_per_year = `Available Working Minutes Per Worker per Year`)

saveRDS(data, "./outputs/data_available_working_time.rds")
