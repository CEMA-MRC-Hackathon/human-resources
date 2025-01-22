library(readxl)
library(tidyverse)

raw_col_names <-  read_excel("./data/HR with coutnties and cadre (1).xlsx", range = "E3:CR4", col_names = FALSE)
cadre_name <- unlist(raw_col_names[1, ])
cadre_name <- cadre_name[!is.na(cadre_name)]
facility_ownership <- unlist(raw_col_names[2, ])
n_ownership_type <- length(unique(facility_ownership))
col_names <- paste(rep(cadre_name, each = n_ownership_type),
                   facility_ownership, sep = "_")

raw_data <- read_excel("./data/HR with coutnties and cadre (1).xlsx",
                       range = "D5:CR70", skip = 13)

data <- raw_data |>
  rename(district = `...1`) |>
  ## Filter out summary rows
  filter(!is.na(district),
         str_detect(district, "Level", negate = TRUE),
         str_detect(district, "ublic", negate = TRUE),
         str_detect(district, "Rural|Urban", negate = TRUE)) |>
  ## Use public HR only
  select(district, contains("pub")) |>
  pivot_longer(-district, names_to = "id_cadre") |>
  ## rename id_cadre to
  mutate(id_cadre = gsub("y2cadre_", "HW", id_cadre),
         id_cadre = gsub("pub", "", id_cadre))

unique(data$id_cadre)

saveRDS(data, "./outputs/data_available_resources.rds")
