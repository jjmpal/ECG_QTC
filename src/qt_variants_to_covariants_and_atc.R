#This code combines atc and covariates data frames to QT variants
#projectID: VL20243010
#by: Aleksi Kristian Winstén
#date: 20.11.2024
#University of Turku
setwd("/home/ivm/Projects/VilleLangen/EKG-MachineLearning/")
library(data.table)
library(dplyr)
library(tidyr)
library(vcfR)

#load qt variants
vcf_file <- "./Data/plink_output/variant_ids.vcf"
snp.df <- read.vcfR(vcf_file, verbose = TRUE)
meta <- snp.df@meta
fix <- snp.df@fix
gt <- snp.df@gt
rm(snp.df)
colnames(gt) <- c("FORMAT", sapply(strsplit(colnames(gt[,-1]), "_"), function(x) x[1]))
gt <- cbind(VARIANT = fix[,3], gt[,-1])
gt <- data.frame(gt)
gt <- pivot_longer(gt, !VARIANT, names_to = "FINNGENID", values_to = "GT")
gt <- pivot_wider(gt, names_from = VARIANT, values_from = GT)

for (i in 2:562) {
  gt[[i]] <- sapply(strsplit(gt[[i]], "/"), function(x) sum(as.numeric(x)))
}

#modify covariates and atc data frame
df.1 <- fread("./Data/atc_covariates_df.gz", data.table = FALSE, select = c(1, 3:20, 22:27, 29, 30))
df.1 <- distinct(df.1)
df.1 <- pivot_wider(df.1, names_from = ATC, values_from = VNR, values_fn = first)
df.1 <- df.1 %>% group_by(FINNGENID) %>% slice_head(n=1)

df.2 <- fread("./Data/atc_covariates_df.gz", data.table = FALSE, select = c(1, 59, 64, 65))
df.2 <- distinct(df.2)
df.2 <- pivot_wider(df.2, names_from = ENDPOINT, values_from = ENDOINT_BEFORE_ECG)

df <- merge(df.1, df.2, by = "FINNGENID")
rm(df.1, df.2)

df <- left_join(df, gt, join_by(FINNGENID))
rm(gt)

fwrite(df, "./Data/20241121_full_ekg_data_frame.gz", sep = "\t", quote = FALSE, na = NA)
