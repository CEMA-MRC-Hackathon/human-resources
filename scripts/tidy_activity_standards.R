
#--------------------------------------------------------------
# Script used for tidying activity standards data for use in the model
#--------------------------------------------------------------

# Load libraries
library(tidyverse)
library(readxl)
library(descr)

#-------------------
# load data and examine 
#-------------------

# Minutes used for each task
standards_times <- read_xlsx("Activity standard_minuites.xlsx")
# cadres required for attending to HIV
standards_data <- read_xlsx("data/Activity_standard for HIV.xlsx", skip=1)

#make all variable names to be in small letters and spaces be underscores
names(standards_times) <- gsub("[()]","",gsub("/","_",tolower(gsub(" ","_",names(standards_times)))))
names(standards_data)  <- gsub("[()]","",gsub("/","_",tolower(gsub(" ","_",names(standards_data)))))

# drop missing records
standards_times <- na.omit(standards_times)  # 17 records missing information, extra cells in the excel file

# Check duplicates duplicates in the disease conditions (standards_data) data by some key variables.
standards_data  <- standards_data |> distinct(disease_condition_risk_factor_public_health_function,public_health_function_based_on_coc,occupation, essential_intervention, .keep_all = T) # one records dropped.
standards_times <- standards_times |> distinct(public_health_function_along_the_continuum_of_care,occupation, essential_intervention, .keep_all = T) # one records dropped.


# Confirm occupation matching between the two data sources
if (!all(standards_data$occupation %in% standards_times$occupation)) {
   cat("Some occupations in the disease conditions data are not in the activity standard times dataset")} else{
   cat("All occupations occupations in the disese conditions data are in the activity standards data. OK")
  }

# Confirm public health function categories match between datasets
freq(standards_data$public_health_function_based_on_coc)
freq(standards_times$public_health_function_along_the_continuum_of_care) # needs some editing to proper case for all entries 
standards_times <- standards_times |> mutate(public_health_function_based_on_coc=str_to_title(public_health_function_along_the_continuum_of_care))

if (!all(standards_data$public_health_function_based_on_coc %in% standards_times$public_health_function_based_on_coc)){
  cat("Some health functions in the disease conditions data are not in the activity standard times dataset")
} else {
  cat("All health functions in the disease conditions data are in the activity standards data. OK")
}

# Confirm essential interventions categories between datasets. 
# NB: (might need data with numeric code for essential interventions to avoid problems with text fields)
if (!all(standards_data$essential_intervention %in% standards_times$essential_intervention)){
  cat("Some essential interventions in the disease conditions data are not in the activity standard times dataset")
} else {
  cat("All essential interventions in the disease conditions data are in the activity standards data. OK")
}

# Merge: add extra variables from standard times data to the disease conditions data
standards_data <-  left_join(standards_data,standards_times, by=c("public_health_function_based_on_coc","occupation","essential_intervention")) |> select(-starts_with("no")) |> 
  select(-c(public_health_function_along_the_continuum_of_care,support_allowance_standard_cas,mean_standard_workload,high_max._activity_standard,low_min._activity_standard))

# Missingness: remove categories that don't have time estimates. Expert process of eliciting time
# did not have all combinations (occupation, conditions and intervention)- info from Francis MoH
standards_data <- standards_data |> subset(!is.na(professional_standard_average_time_in_minutes)) 

# Checks for units of measurement.
standards_data <- standards_data |> subset(activity_type=="Direct_Patient_Care") # drop any support activity time for now, future model refinments will include it.
freq(standards_data$unit_of_measurement) # need to unify this into common unit

save(standards_data,file="outputs/data_hiv_time_standards.rds")
