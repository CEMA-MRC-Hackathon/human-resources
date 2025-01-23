library(tidyverse)
library(MetBrewer)
cols <- c(met.brewer("Johnson", 5),
          met.brewer("Archambault", 7)[1:4],
          met.brewer("Java", 5)[5],
          )

data <- readRDS("./outputs/results_hr_deficits_by_county_and_cadre.rds")

x <- "Siaya"
y <- "deficit_in_number_per_year"

data |>
  pivot_longer(-(district:cadre)) |>
  filter(district == x,
         name == y) |>
  ggplot(aes(y = cadre, x = value)) +
    geom_bar(stat = "identity", fill = met.brewer("Isfahan2", 5)[5]) +
  theme_bw() +
  labs(x = y, y = "")

data |>
  pivot_longer(-(district:cadre)) |>
  filter(name == y) |>
  ggplot(aes(y = fct_rev(district), x = value, group = cadre, fill = cadre)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  scale_fill_manual(values = cols) +
  labs(fill = "Cadre of healthworker", y = "", x = y)
