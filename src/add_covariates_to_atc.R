#This code combines atc data frame to covariates used in analysis
#projectID: VL20243010
#by: Aleksi Kristian Winstén
#date: 20.11.2024
#University of Turku
setwd("/home/ivm/Projects/VilleLangen/EKG-MachineLearning/")
library(data.table)
library(dplyr)
library(tidyr)

#load atc data
df <- fread("./Data/medication_codes.gz", data.table = FALSE)

#connect to the BigQuery
source("/home/ivm/R/bigrquesry_connect.R")

#collect covariates
cov.df <- endpoints %>% filter(ENDPOINT %in% c("N14_CHRONKIDNEYDIS", "I9_CHD", "I9_HEARTFAIL", "E4_DIABETES")) %>% collect()

#combine to atc data
df <- left_join(df, cov.df, join_by(FINNGENID), relationship = "many-to-many")
rm(cov.df)
df <- mutate(df, ENDPOINT_ENTRY_AGE = AGE, .keep = "unused")
df <- mutate(df, ENDOINT_BEFORE_ECG = if_else(ENDPOINT_ENTRY_AGE < ECG_EVENT_AGE, 1, 0))

#make sex
sex.df <- covariates %>% select(FINNGENID = FID, SEX_IMPUTED) %>% collect()

#add sex to data frame
df <- left_join(df, sex.df, join_by(FINNGENID))
rm(sex.df)

#first measurement
first.meas <- df %>% group_by(FINNGENID) %>% arrange(ECG_EVENT_AGE, .by_group = TRUE) %>% select(FINNGENID, MEASID) %>% slice_head(n=1) %>% pull(MEASID)

#filter only the first ecg measurement
df <- filter(df, MEASID %in% first.meas) 
rm(first.meas)

fwrite(df, "./Data/atc_covariates_df.gz", sep = '\t', quote = FALSE, na = NA)
