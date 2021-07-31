library(foreign)
library(dplyr)

ghs_raw <- read.csv("zaf-statssa-ghs-2019-household-v1.csv")

ghs <- ghs_raw %>%
  select(totmhinc, FSD_Hung_Adult,FSD_Hung_Child)

saveRDS(ghs, file = "ghs")
