
# Process raw data and tidy
## A1) Population data
source("./scripts/tidy_population_data.R")
## A2) HIV prevalence data
source("./scripts/tidy_population_data.R")
## A3) compile time needed to treat each case by cadre - John
source("./scripts/tidy_activity_standards.R")
source("./scripts/time_calculations_per cadre")
## A4) Available resources (number in each cadre) data
source("./scripts/tidy_available_resources.R")
## A5) Working time by cadre data
source("./scripts/tidy_working_time_by_cadre.R.R")
## A6) # PLWHIV needing care per county (PLHIV-ART-catchment)
source("./scripts/tidy_plhiv_needing_care_by_county.R")
## A7) Calculate national % in each category needing care
source("./scripts/tidy_national_people_needing_care_by_disease_category.R")

# Model calculations
## B1) calculate disease burden (A1 x A2)
source("scripts/calculate_disease_burden.R")
## B3) Split # needing care by category (A6 * A7)
source("scripts/calculate_people_needing_care_by_category.R")

## B4) determine total time resources needed per county (B3 x A3)
## B5) calculate human time resources available by county and cadre (A4 * A5)
source("scripts/calculate_available_time.R")
## B6) compare time resources available vs need to determine unmet needs (B4 - B5)


# Data visualisations
## create data visualisations, including maps of data / results

# create dashboard
