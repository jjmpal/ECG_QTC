#This code combines atc and covariates data frames to QT variants
#projectID: VL20243010
#by: Aleksi Kristian Winstén
#date: 20.11.2024
#University of Turku
setwd("/home/ivm/Projects/VilleLangen/EKG-MachineLearning/")
library(data.table)
library(dplyr)
library(tidyr)

df.scores <- fread("./Data/PRS/PGS002120_scores.tsv.gz", data.table = FALSE, select = c(1,2))
colnames(df.scores) <- c("FINNGENID", "PRS_SCORE")
df.scores$PRS_SCORE <- with(df.scores, (PRS_SCORE - mean(PRS_SCORE))/sd(PRS_SCORE))
df <- fread("./Data/20241121_full_ekg_data_frame.gz", data.table = FALSE)
df <- left_join(df, df.scores, join_by(FINNGENID))
rm(df.scores)

fwrite(df,
       file = "./Data/20241125_full_ekg_data_frame_with_prs.gz",
       quote = FALSE,
       sep = "\t",
       na = NA)

df <- df %>% mutate(across(26:530, ~ if_else(is.na(.x), 0, 1)))

fwrite(df,
       file = "./Data/20241125_full_ekg_data_frame_with_prs_and_atc_is_binary.gz",
       quote = FALSE,
       sep = "\t",
       na = NA)
rm(df)