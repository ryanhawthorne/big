library(foreign)
library(dplyr)
library(ggplot2)
library(survey)
library(srvyr)
library(forcats)
library(reldist)

ghs_raw <- read.csv("zaf-statssa-ghs-2019-household-v1.csv")

ghs <- ghs_raw %>%
  select(uqnr, house_wgt,totmhinc, FSD_Hung_Adult,FSD_Hung_Child,hholdsz,LAB_SALARY_hh,ad60plusyr_hh,chld17yr_hh) %>%
  mutate(ad18to60yr = hholdsz - ad60plusyr_hh - chld17yr_hh)
  
saveRDS(ghs, file = "ghs")

ghs_svy <- ghs %>%
  select(uqnr, house_wgt,totmhinc, FSD_Hung_Adult,FSD_Hung_Child,hholdsz,LAB_SALARY_hh,ad60plusyr_hh,chld17yr_hh,ad18to60yr) %>%
  as_survey_design(weights = house_wgt) %>%
  mutate(bin10 = cut_number(totmhinc, 10, dig.lab = 5),
         poverty350 = totmhinc < hholdsz * 350,
         poverty585 = totmhinc < hholdsz * 585,
         poverty840 = totmhinc < hholdsz * 840,
         poverty1268 = totmhinc < hholdsz * 1268)


### some descriptives 

ghs_raw %>%
  summarise(mean = mean(hholdsz))

ghs_svy %>%
  group_by(poverty350) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(poverty585) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(poverty840) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(poverty1268) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(bin) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(bin10) %>%
  summarize(mean_size = survey_mean(hholdsz),
            mean_ad18to60yr = survey_mean(ad18to60yr),
            mean_inc = survey_mean(totmhinc),
            mean_salary = survey_mean(LAB_SALARY_hh))

ghs_svy %>%
  group_by(FSD_Hung_Child) %>%
  survey_count()

ghs_svy %>%
  group_by(FSD_Hung_Adult) %>%
  survey_count()


# histogram
income_hist <- ggplot(ghs_raw,
                      aes(x = totmhinc,
                          weight = house_wgt)) +
  geom_histogram(bins = 10)
income_hist

# income deciles

income_bar <- ghs_raw %>%
  mutate(bin = cut_number(totmhinc, 10, dig.lab = 5)) %>% # create 10 bins
  ggplot(aes(x = bin,
                          weight = house_wgt)) +
  geom_bar(fill = "#FF6666") +
  labs(y = "Number of households",
       x = "Household income per month") +
  theme(axis.text.x = element_text(angle = 90))
income_bar
  
### poverty graph - for server

require(scales)
library(tidyr)

big <- 350
poverty <-  ghs %>%
  mutate(income_big = totmhinc + big * ad18to60yr) %>%
  mutate(poverty350 = income_big < hholdsz * 350,
         poverty585 = income_big < hholdsz * 585,
         poverty840 = income_big < hholdsz * 840,
         poverty1268 = income_big < hholdsz * 1268) %>%
  select(poverty350, poverty585, poverty840, poverty1268, uqnr, house_wgt) %>%
  pivot_longer(cols = starts_with("poverty"), 
               names_to = "poverty_line",
               values_to = "poor")  %>%
  filter(poor == TRUE) 

lines <- c("poverty350", "poverty585", "poverty840", "poverty1268") # for ordering in ggplot graph

poverty365_bar <- ggplot(poverty,
                         aes(x = poverty_line,
             weight = house_wgt)) +
  geom_bar(fill = "#FF6666") +
  theme(text = element_text(size = 10),
        axis.text.y = element_text(size = 10,
                                   colour = "Black"),
        axis.title.x = element_text(size = 10,
                                    colour = "Black"),
        axis.title.y = element_text(size = 10,
                                    colour = "Black")) +
  labs(y = "Number of households below the poverty line",
       x = "Poverty line (Rands per person per month)") +
  scale_x_discrete(limits = lines,
                   labels = c("poverty350" = "R350", "poverty585" = "R585", "poverty840" = "R840", "poverty1268" = "R1268")) +
  theme(axis.text.x = element_text(angle = 90,
                                   size = 10,
                                   colour = "Black")) +
  scale_y_continuous(labels = comma) +
  geom_text(stat='count', 
            aes(label=scales::comma(..count..)),
            vjust = -1,
            size = 3.5) 
poverty365_bar

### cost computation

adults <- ghs_svy %>%
  survey_tally(ad18to60yr) %>%
  pull(n)
cost<- as.numeric(big) * adults * 12 
cost

### hunger graph - for server





### gini computation

weights <- ghs %>%
  pull(house_wgt)
income_big <- ghs %>%
  mutate(income_big = totmhinc + big * ad18to60yr) %>%
  pull(income_big)

inequality <- round(gini(income_big, weights), 2)  
inequality

