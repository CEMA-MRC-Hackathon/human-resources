
# Process raw data and tidy
## A1) Population data
source("./scripts/tidy_population_data.R")
## A2) HIV prevalence data
source("./scripts/tidy_population_data.R")
## A3) compile time needed to treat each case by cadre - John
# TODO: read activity standard for HIV
# TODO: read health facility availability
## A4) Available resources (number in each cadre) data
source("./scripts/tidy_available_resources.R")
## A5) Working time by cadre data
source("./scripts/tidy_working_time_by_cadre.R.R")

# Model calculations
## B1) calculate disease burden (A1 x A2)
source("scripts/calculate_disease_burden.R")
# TODO:
## B2) determine total time resources needed per county (B1 x A3)
## B3) calculate human time resources available by county and cadre (A4 * A5)
source("scripts/calculate_available_time.R")
## B4) compare time resources available vs need to determine unmet needs (B2 - B3)


# Data visualisations
## create data visualisations, including maps of data / results

# create dashboard
