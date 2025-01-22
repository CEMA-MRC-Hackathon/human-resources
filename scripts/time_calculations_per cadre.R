
#--------------------------------------------------------------
# Script to calculate times needs by each cadre
#--------------------------------------------------------------

# Load data
load("outputs/data_hiv_time_standards.rds")
patients_needing_care_by_category <-readRDS("outputs/results_number_needing_care_by_category.rds")


# expected time spent in each intervention per patient per year for each HIV condition
standards_data <-standards_data |> mutate(expected_time_spent_in_minutes = professional_standard_average_time_in_minutes*percent_of_people_in_this_patient_group_that_would_need_the_intervention*frequency_of_the_required_intervention_per_year_or_the_duration_of_admission_in_days)

# Consider that not all those who need service will be inpatients. So for inpatient interventions we need to adjust the expectation by the probability that a HIv patient requires inpatint services
prob_inpatient = 0.02 # information from Francis. Need hard reference.
standards_data = standards_data |> mutate(inpatient_intervention=grepl("Inpatient",essential_intervention)*1) |> mutate(adjusted_expected_time_spent_in_minutes=expected_time_spent_in_minutes*(1-inpatient_intervention) + expected_time_spent_in_minutes*prob_inpatient*inpatient_intervention)

# calculate total time needed per cadre per patient in each HIV condition
summary_by_cadre <- standards_data |> group_by(disease_condition_risk_factor_public_health_function,occupation) |> summarise(total_time_per_patient_per_year_in_hours=sum(expected_time_spent_in_minutes)/60, .groups = "drop") |>
  rename(category=disease_condition_risk_factor_public_health_function)

# merge with patients_needing_care_by_category
freq(patients_needing_care_by_category$category)
freq(summary_by_cadre$category) 
freq(summary_by_cadre$occupation) # 11 occupations

patients_needing_care_by_category <- left_join(patients_needing_care_by_category,summary_by_cadre, by="category", relationship = "many-to-many")
freq(patients_needing_care_by_category$occupation)

# summaries time by cadre by county
patients_needing_care_by_category <- patients_needing_care_by_category |> mutate(total_time = number_needing_care_by_category*total_time_per_patient_per_year_in_hours)
summary_times_by_cadre_by_county  <- patients_needing_care_by_category |> group_by(district,occupation) |> summarise(total_time_in_hours_per_year=sum(total_time), .groups = "drop")

saveRDS(summary_times_by_cadre_by_county,"outputs/summary_times_by_cadre_by_county.rds")
