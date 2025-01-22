
#--------------------------------------------------------------
# Script to calculate times needs by each cadre
#--------------------------------------------------------------

# Load data
load("outputs/data_hiv_time_standards.rds")

# dummy dataset (for now) of hiv patients needing care in each county.
patients_per_hiv_condition <- data.frame(condition=rep(unique(standards_data$disease_condition_risk_factor_public_health_function),47))
patients_per_hiv_condition <- patients_per_hiv_condition |> group_by(condition) |> mutate(county=n)



# 2% of require inpatient care