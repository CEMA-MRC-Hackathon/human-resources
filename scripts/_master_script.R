
# Process raw data and tidy
## A1) Population data
source("./scripts/tidy_population_data.R")
## A2) HIV prevalence data
source("./scripts/tidy_population_data.R")
## A3) compile time needed to treat each case by cadre - John
## A4) collate human time resources available by county and cadre - Lilith
# TODO: read available working time - Lilith
# TODO: read activity standard for HIV
# TODO: read health facility availability

# Model calculations
## B1) calculate disease burden (A1 x A2)
source("scripts/calculate_disease_burden.R")
# TODO:
## B2) determine total time resources needed per county (B1 x A3)
## compare time resources available vs need to determine unmet needs (B2 - A4)

# Data visualisations
## create data visualisations, including maps of data / results


# create dashboard
