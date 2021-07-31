library(foreign)

ghs_raw <- read.csv("zaf-statssa-ghs-2019-household-v1.csv")

ghs_income <- ghs_raw$totmhinc
saveRDS(ghs_income, file = "ghs_income")