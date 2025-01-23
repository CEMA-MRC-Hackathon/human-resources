#--------------------------------------------------------------
# Script used for calculating deficits in HR needs
#--------------------------------------------------------------

# load data
data_available_time_resources <- readRDS("outputs/data_available_time_resources.rds")
summary_times_by_cadre_by_county <- readRDS("outputs/summary_times_by_cadre_by_county.rds")

# rename variables to match
summary_times_by_cadre_by_county <- summary_times_by_cadre_by_county |> rename(cadre = occupation)

# data check before for merge
(!all(summary_times_by_cadre_by_county$cadre %in% data_available_time_resources$cadre)) # some cadres are missing in the time availability data
freq(data_available_time_resources$cadre)
freq(summary_times_by_cadre_by_county$cadre) # differing naming systems for cadres between the two sources.
unique(data_available_time_resources$district) # 50 counties, need to drop 'district' that are not counties (Private, NGO, FBO), these wont be picked by merge anyway

# After discussion with Francis (MoH) the following mappings were agreed
summary_times_by_cadre_by_county <- summary_times_by_cadre_by_county |> mutate_at(which(names(summary_times_by_cadre_by_county)=="cadre"), ~case_when(
  . == "Obstetrician & Gynaecologist"   ~ "Medical Doctor Specialist",
  . == "Infectious Diseases Specialist" ~ "Medical Doctor Specialist",
  TRUE ~ .)
)

summary_times_by_cadre_by_county <- summary_times_by_cadre_by_county |> mutate_at(which(names(summary_times_by_cadre_by_county)=="cadre"), ~case_when(
  . == "Medical Laboratory Scientist"   ~ "Laboratory Technician/Technologist",
  . == "Medical Laboratory Technician"  ~ "Laboratory Technician/Technologist",
  TRUE ~ .)
)

summary_times_by_cadre_by_county <- summary_times_by_cadre_by_county |> mutate_at(which(names(summary_times_by_cadre_by_county)=="cadre"), ~case_when(
  . == "Clinical Pharmacist"  ~ "Pharmacist",
  . == "Pharmacy Technician"  ~ "Pharmaceutical Technologist",
  . == "Community health worker/Village health worker"  ~ "Counselling Psychologists/Medical social workers",
  TRUE ~ .)
)

# sum the times_by_cadre_by_county for the merged cadres
summary_times_by_cadre_by_county <- summary_times_by_cadre_by_county |> group_by(district, cadre) |> 
  summarise(total_time_in_hours_per_year=sum(total_time_in_hours_per_year), .groups = "drop") |> unique()


data_available_time_resources <- data_available_time_resources |> mutate_at(which(names(data_available_time_resources)=="cadre"), ~case_when(
  . == "Enrolled Nurses"   ~ "Associate Nurse/Enrolled Nurse/Nursing Assistant",
  . == "Nursing Officer"   ~ "Associate Nurse/Enrolled Nurse/Nursing Assistant",
  . == "Registered Nurse"  ~ "Associate Nurse/Enrolled Nurse/Nursing Assistant",
  TRUE ~ .)
)

data_available_time_resources <- data_available_time_resources |> mutate_at(which(names(data_available_time_resources)=="cadre"), ~case_when(
  . == "Clinical Officer"               ~ "Clinical Officer/Physician Assistant",
  . == "Clinical Officer (Specialist)"  ~ "Clinical Officer/Physician Assistant",
  . == "Clinical Officer Interns"       ~ "Clinical Officer/Physician Assistant",
  TRUE ~ .)
)


data_available_time_resources <- data_available_time_resources |> mutate_at(which(names(data_available_time_resources)=="cadre"), ~case_when(
  . == "Medical Officer"           ~ "General Medical Practitioner (Generalist Doctor)",
  . == "Medical Officer Interns"   ~ "General Medical Practitioner (Generalist Doctor)",
  TRUE ~ .)
)

# sum the available_time_resources for the merged cadres
data_available_time_resources <- data_available_time_resources |> group_by(district, cadre) |> select(-id_cadre) |> 
  summarise_at(c("number","days_per_year","hours_per_year","minutes_per_year"),sum) |> unique()

# ready to merge? check if cadres in the summary_times_by_cadre_by_county is a subset of those in data_available_time_resources
(!all(summary_times_by_cadre_by_county$cadre %in% data_available_time_resources$cadre)) # cadres match: ready to merge
(!all(summary_times_by_cadre_by_county$district %in% data_available_time_resources$district)) # need to unify district names.
freq(summary_times_by_cadre_by_county$district)
freq(data_available_time_resources$district)  # some county names differ, we correct those below

summary_times_by_cadre_by_county <- summary_times_by_cadre_by_county |> mutate_at(which(names(summary_times_by_cadre_by_county)=="district"), ~case_when(
  . == "Elgeyo-marakwet"    ~ "Elgeyo Marakwet",
  . == "Murang'a"           ~ "Muranga",
  . == "Nairobi (county)"   ~ "Nairobi",
  . == "Taita-taveta"       ~ "Taita Taveta",
  . == "Tharaka-nithi"      ~ "Tharaka Nithi",
  . == "Trans-nzoia"        ~ "Trans Nzoia",
  TRUE ~ .)
)

# Now merge
working_time_per_personel_per_year_in_hours = 1752 # sourced from ./outputs/data_working_time_by_cadre, shows similar time across cadre

results_hr_deficits_by_county_and_cadre <- left_join(summary_times_by_cadre_by_county,data_available_time_resources, by=c("district","cadre")) |> select(-c("days_per_year","minutes_per_year")) |>
  rename(hours_needed_per_year=total_time_in_hours_per_year, hours_available_per_year=hours_per_year) |>
  mutate(deficit_in_hours_per_year = hours_needed_per_year-hours_available_per_year) |>
  mutate(deficit_in_number_per_year = round(deficit_in_hours_per_year/(working_time_per_personel_per_year_in_hours)))


saveRDS(results_hr_deficits_by_county_and_cadre,"outputs/results_hr_deficits_by_county_and_cadre.rds")

