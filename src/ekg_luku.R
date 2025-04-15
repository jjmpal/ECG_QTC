# Kirjastot
library("plyr")
library("XML")
library("purrr")

# Listaa luettavat tiedostot, 5MIN kestää
setwd("/finngen/library-red/EA3_HEART_FAILURE_1.0/data/ecg")
files <- list.files(full.names = TRUE,recursive = T)

# Poimii halutut tiedot, tässä noden <RestingECGMeasurements> alla
parse_xml <- function(FileName){
  d1 <- xmlToDataFrame(nodes=getNodeSet(xmlParse(FileName),"//RestingECGMeasurements"),stringsAsFactors = FALSE)
  cbind(d1,FileName)
}
# Kaikki ekg:t eivät oikeaa muotoa, joukossa esim rasitus-ekg:t niin ohitetaan ne
parse_xml2 <- possibly(parse_xml,otherwise = data.frame(0))

# Varoitus, kestää useita tunteja. Voi tehdä halutessaan osan ensin ja sitten yhdistää
#system.time(df <- ldply(files[1:100],parse_xml2))
system.time(df <- ldply(files,parse_xml2))
