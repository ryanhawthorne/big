library(foreign)
library(dplyr)
library(ggplot2)
library(ggsurvey)
library(survey)
library(srvyr)

ghs_raw <- read.csv("zaf-statssa-ghs-2019-household-v1.csv")

ghs <- ghs_raw %>%
  select(uqnr, house_wgt,totmhinc, FSD_Hung_Adult,FSD_Hung_Child) %>%
  mutate(bin = ntile(totmhinc, 10))

saveRDS(ghs, file = "ghs")


### some descriptives 

ghs %>%
  as_survey(weights = c(house_wgt)) %>%
  group_by(bin) %>%
  summarize(n = survey_total())

# histogram
income_hist <- ggplot(ghs,
                      aes(x = totmhinc,
                          y = ..density..,
                          weight = house_wgt)) +
  geom_histogram()
income_hist

# income deciles

income_bar <- ghs %>%
  group_by(bin) %>%
  survey %>%
  ggplot(aes(x = totmhinc,
                          weight = house_wgt)) +
  geom_bar()
income_bar
  
  