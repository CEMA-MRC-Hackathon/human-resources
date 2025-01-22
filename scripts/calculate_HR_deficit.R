#--------------------------------------------------------------
# Script used for calculating deficits in HR needs
#--------------------------------------------------------------

# load data
data_available_time_resources <- readRDS("outputs/data_available_time_resources.rds")
summary_times_by_cadre_by_county <- readRDS("outputs/summary_times_by_cadre_by_county.rds")

# rename variables to match
summary_times_by_cadre_by_county <- summary_times_by_cadre_by_county |> rename(cadre = occupation)

# merge
freq(data_available_time_resources$cadre)
freq(summary_times_by_cadre_by_county$cadre)

Associate Nurse/Enrolled Nurse/Nursing Assistant -> Enrolled Nurses + Nursing Officer + Registered Nurse 
Clinical Officer/Physician Assistant -> Clinical Officer  + Clinical Officer (Specialist)  + Clinical Officer Interns
Clinical Pharmacist  -> Pharmacist
Pharmacist - Pharmacist
Pharmacy Technician -> Pharmaceutical Technologist  
Community health worker/Village health worker -> Counselling Psychologists/Medical social workers 
General Medical Practitioner (Generalist Doctor) ->  + Medical Officer + Medical Officer Interns
Infectious Diseases Specialist -> Medical Doctor Specialist 
Medical Laboratory Scientist -> Laboratory Technician/Technologist 
Medical Laboratory Technician ->  Laboratory Technician/Technologist 
Obstetrician & Gynaecologist -> Medical Doctor Specialist 




results_hr_deficits_by_county_and_cadre <- left_join(summary_times_by_cadre_by_county,data_available_time_resources, by=c("district","cadre"))

county,cadre,hoursneeded,hours avaiable, defitic, placement number


