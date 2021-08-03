library(foreign)
library(dplyr)
library(ggplot2)
library(survey)
library(srvyr)
library(forcats)
library(reldist)
library(scales)
library(tidyr)

ghs_raw <- read.csv("zaf-statssa-ghs-2019-household-v1.csv")

ghs <- ghs_raw %>%
  select(uqnr, house_wgt,totmhinc, FIN_EXP,FSD_WORRIED,FSD_SKIPPED, FSD_HUNGRY, FSD_Hung_Adult,FSD_Hung_Child,hholdsz,LAB_SALARY_hh,ad60plusyr_hh,chld17yr_hh) %>%
  mutate(ad18to60yr = hholdsz - ad60plusyr_hh - chld17yr_hh) %>%
  mutate(bin10 = cut_number(totmhinc, 10, dig.lab = 5),
         poverty350 = totmhinc < hholdsz * 350,
         poverty585 = totmhinc < hholdsz * 585,
         poverty840 = totmhinc < hholdsz * 840,
         poverty1268 = totmhinc < hholdsz * 1268)
  
saveRDS(ghs, file = "ghs")

ghs_svy <- ghs %>%
  as_survey_design(weights = house_wgt) 



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

ghs_svy %>%
  group_by(FIN_EXP) %>%
  survey_count()

ghs_svy %>%
  group_by(FSD_HUNGRY) %>%
  survey_count()

ghs_svy %>%
  group_by(FSD_Hung_Adult) %>%
  survey_count()

ghs_svy %>%
  group_by(FSD_WORRIED) %>%
  survey_count()

ghs_svy %>%
  group_by(FSD_SKIPPED) %>%
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
  
### poverty graph using income - for server

big <- 0
poverty_inc <-  ghs %>%
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

poverty_inc_bar <- ggplot(poverty_inc,
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
poverty_inc_bar


### poverty using expenditure

poverty_exp <-  ghs %>%
  mutate(exp_big = FIN_EXP + big * ad18to60yr) %>%
  mutate(poverty350 = exp_big < hholdsz * 350,
         poverty585 = exp_big < hholdsz * 585,
         poverty840 = exp_big < hholdsz * 840,
         poverty1268 = exp_big < hholdsz * 1268) %>%
  select(poverty350, poverty585, poverty840, poverty1268, uqnr, house_wgt) %>%
  pivot_longer(cols = starts_with("poverty"), 
               names_to = "poverty_line",
               values_to = "poor")  %>%
  filter(poor == TRUE) 

### cost computation

adults <- ghs_svy %>%
  survey_tally(ad18to60yr) %>%
  pull(n)
cost<- as.numeric(big) * adults * 12 
cost

### hunger graph - for server

hungry <-  ghs %>%
  mutate(income_big = totmhinc + big * ad18to60yr, 
         hungry_child = as.factor(FSD_Hung_Child),
         hungry_adult = as.factor(FSD_Hung_Adult)) %>%
  { ifelse(income_big > poverty585 & hungry_child !=2, 
           mutate(hungry_child = 2), . ) } %>%
  { ifelse(income_big > poverty585 & hungry_adult !=2, 
           mutate(hungry_adult = 2), . ) }
  
  
  

levels(hungry$hungry_adult) # check levels
           
  == c("Always","Often", "Seldom", "Sometimes", "Never")) 
         
 
  select(poverty350, poverty585, poverty840, poverty1268, uqnr, house_wgt) %>%
  pivot_longer(cols = starts_with("poverty"), 
               names_to = "poverty_line",
               values_to = "poor")  %>%
  filter(poor == TRUE) 

lines <- c("poverty350", "poverty585", "poverty840", "poverty1268") # for ordering in ggplot graph

hungry <- ggplot(poverty_inc,
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
poverty_inc_bar



### gini computation

weights <- ghs %>%
  pull(house_wgt)
income_big <- ghs %>%
  mutate(income_big = totmhinc + big * ad18to60yr) %>%
  pull(income_big)

inequality <- round(gini(income_big, weights), 2)  
inequality

