#This code builds the atc data frame from finngen data
#projectID: VL20243010
#by: Aleksi Kristian Winstén
#date: 12.11.2024
#University of Turku
setwd("/home/ivm/Projects/VilleLangen/EKG-MachineLearning/")
library(data.table)
library(dplyr)
library(tidyr)

#load the ecg_data and modify it
ecg_data <- fread(file = "./Data/ecg_data.txt", data.table = FALSE)
ecg_data$FileName <- gsub("[._]", "/", ecg_data$FileName)
temp.df <- do.call(rbind, lapply(strsplit(ecg_data$FileName, "/"), function(x) x[c(4,5)]))
colnames(temp.df) <- c("FINNGENID", "MEASID")
ecg_data <- cbind(temp.df, ecg_data)
rm(temp.df)
ecg_dates <- fread(file = "/finngen/library-red/EA3_HEART_FAILURE_1.0/data/EA3_HEART_FAILURE_ecg_info_1.0.txt", data.table = FALSE)
colnames(ecg_dates) <- c("FINNGENID", "MEASID", "ECG_EVENT_AGE" ,"ECG_APPROX_EVENT_DAY", "ECG_TIME")
ecg_data <- left_join(ecg_data, ecg_dates, join_by("FINNGENID", "MEASID" ))
rm(ecg_dates)
#ids <- distinct(na.omit(ecg_data["FINNGENID"]))$FINNGENID

#load the atc data and combine with ecg
long.df <- fread("./Data/atc_longitudinal.gz", data.table = FALSE, select = c(1,3,5,6)) #Antibiotics excluded
colnames(long.df) <- c("FINNGENID", "PURCH_EVENT_AGE", "ATC", "VNR")
#long.df <- filter(long.df, FINNGENID %in% ids)
long.df <- left_join(ecg_data, long.df, join_by(FINNGENID), relationship = "many-to-many")
rm(ecg_data)

#remove those who have not had medication 3 months prior ecg
long.df <- filter(long.df, ECG_EVENT_AGE > PURCH_EVENT_AGE, ECG_EVENT_AGE <= 0.25 + PURCH_EVENT_AGE)
atc_codes <- as.character(filter(data.frame(table(long.df$ATC)), Freq >= 5)[[1]]) #exclude medications used by less than 5 individuals
long.df <- filter(long.df, ATC %in% atc_codes)

#VNR codes
vnr.df <- fread("/finngen/library-green/finngen_R6/finngen_R6_medical_codes/fgVNR_v1.tsv", data.table = FALSE)
long.df <- left_join(long.df, vnr.df, join_by(ATC, VNR), relationship = "many-to-many")
rm(vnr.df)


fwrite(long.df, file = "./Data/medication_codes.gz", sep = '\t', quote = FALSE, na = NA)
rm(long.df)

##################################################################################################
#qt.drugs.df <- pivot_wider(long.df[c("FINNGENID", "MEASID", "QTCorrected", "ATC", "VNR")],
                           #names_from = ATC, 
                           #values_from = c("QTCorrected", "VNR"))
#potential_drugs <- sapply(qt.drugs.df[-1], function(x) mean(x, na.rm=TRUE) > 450)
#qt.drugs.df <- qt.drugs.df[, c(TRUE, as.vector(potential_drugs))]
#data.frame(table(long.df$ATC)) %>% filter(Var1 %in% colnames(qt.drugs.df)[-1])


#long.df |>
#  dplyr::summarise(n = dplyr::n(), .by = c(FINNGENID, MEASID, ATC)) |>
#  dplyr::filter(n > 1L) 
