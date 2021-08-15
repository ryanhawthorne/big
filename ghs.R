library(foreign)
library(dplyr)
library(ggplot2)
library(survey)
library(srvyr)
library(forcats)
library(reldist)
library(scales)
library(tidyr)

ghs_raw_hh <- read.csv("zaf-statssa-ghs-2019-household-v1.csv")
ghs_raw_pers <- read.csv("zaf-statssa-ghs-2019-person-v1.csv")

ghs_hh <- ghs_raw_hh %>%
  select(uqnr, house_wgt,totmhinc, FIN_EXP,FSD_WORRIED,FSD_SKIPPED, FSD_HUNGRY,FSD_RANOUT,FIN_INC_pen,FIN_PEN, FIN_INC_buss,FIN_INC_agric,FIN_INC_oth,FIN_INC_MAIN,FIN_EXP,
         FSD_Hung_Adult,FSD_Hung_Child,hholdsz,LAB_SALARY_hh,ad60plusyr_hh,chld17yr_hh) %>%
  mutate(ad18to59yr = hholdsz - ad60plusyr_hh - chld17yr_hh) %>%
  mutate(bin10 = cut_number(totmhinc, 10, dig.lab = 5),
         poverty350 = totmhinc < hholdsz * 350,
         poverty585 = totmhinc < hholdsz * 585,
         poverty840 = totmhinc < hholdsz * 840,
         poverty1268 = totmhinc < hholdsz * 1268)

ghs_pers <- ghs_raw_pers %>%
  select(uqnr)
  
saveRDS(ghs, file = "ghs")

ghs_svy <- ghs %>%
  as_survey_design(weights = house_wgt) 



### some descriptives 

ghs_raw %>%
  summarise(mean = mean(hholdsz))

ghs_svy %>%
  group_by(FIN_INC_pen) %>%
  summarize(n = survey_total()) %>%
  ungroup

str(ghs_svy$variables)

ghs_svy %>%
  filter(FIN_PEN != "Not applicable") %>%
  group_by(FIN_PEN) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(FIN_INC_buss) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(FIN_INC_agric) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(FIN_INC_oth) %>%
  summarize(n = survey_total())

ghs_svy %>%
  group_by(FIN_INC_MAIN) %>%
  summarize(n = survey_total())

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
            mean_ad18to59yr = survey_mean(ad18to59yr),
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

ghs_svy %>%
  group_by(FSD_RANOUT) %>%
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

big <- 350
poverty_inc <-  ghs %>%
  mutate(income_big = totmhinc + big * ad18to59yr) %>%
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
  theme(axis.text.x = element_text(size = 10,
                                   colour = "Black")) +
  scale_y_continuous(labels = comma,
                     limits = c(0,9000000)) +
  geom_text(stat='count', 
            aes(label=scales::comma(..count..)),
            vjust = -1,
            size = 3.5) 
poverty_inc_bar


### poverty using expenditure

poverty_exp <-  ghs %>%
  mutate(exp_big = FIN_EXP + big * ad18to59yr) %>%
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

adults_ghs <- ghs_svy %>%
  survey_tally(ad18to59yr) %>%
  pull(n)
adults_iej <- 34100000
cost<- as.numeric(big) * adults_iej * 12 
cost


expenditure_total <- 2020400000000
expenditure = scales::percent(as.numeric(cost) / as.numeric(expenditure_total)) 
expenditure

### hunger graph - for server
big <- 350
hungry <- ghs %>%
  mutate(income_big = totmhinc + big * ad18to59yr) %>%
  mutate(food_skipped = FSD_SKIPPED == "Yes",
         food_ranout = FSD_RANOUT == "Yes",
         food_adult = FSD_Hung_Adult == "Always" | FSD_Hung_Adult ==  "Often" | FSD_Hung_Adult == "Sometimes" | FSD_Hung_Adult =="Seldom", 
         food_child = FSD_Hung_Child == "Always" | FSD_Hung_Child == "Often" | FSD_Hung_Child == "Sometimes" | FSD_Hung_Child == "Seldom") %>%
  mutate(food_skipped = ifelse(income_big > hholdsz * 585  & food_skipped == TRUE, FALSE,food_skipped), # + 12000
           food_ranout = ifelse(income_big > hholdsz * 585  & food_ranout == TRUE, FALSE,food_ranout),  # + 12000
           food_adult = ifelse(income_big > hholdsz * 585  & food_adult == TRUE, FALSE, food_adult), # + 12000
           food_child = ifelse(income_big > hholdsz * 585  & food_child == TRUE, FALSE,food_child)) %>% # + 12000
  select(food_skipped, food_ranout, food_adult, food_child, uqnr, house_wgt) %>%
  pivot_longer(cols = starts_with("food"), 
               names_to = "food_indicator",
               values_to = "hungry") %>%
  filter(hungry == TRUE) 

hungry_list <- c("food_ranout","food_skipped", "food_adult","food_child")

hungry_bar <- ggplot(hungry,
                          aes(x = food_indicator,
                              weight = house_wgt)) +
  geom_bar(fill = "#FF6666") +
  theme(text = element_text(size = 10),
        axis.text.y = element_text(size = 10,
                                   colour = "Black"),
        axis.title.x = element_text(size = 10,
                                    colour = "Black"),
        axis.title.y = element_text(size = 10,
                                    colour = "Black")) +
  labs(y = "Number of households",
       x = "") +
  scale_x_discrete(limits = hungry_list,
                   labels = c("food_ranout" = "Food ran out", "food_skipped" = "Skipped a meal", "food_adult" = "Hungry adult", "food_child" = "Hungry child")) +
  theme(axis.text.x = element_text(angle = 45,
                                   size = 10,
                                   colour = "Black")) +
  scale_y_continuous(labels = comma,
                     limits = c(0,1300000)) +
  geom_text(stat='count', 
            aes(label=scales::comma(..count..)),
            vjust = -1,
            size = 3.5) 
hungry_bar


### gini computation

weights <- ghs %>%
  pull(house_wgt)
income_big <- ghs %>%
  mutate(income_big = totmhinc + big * ad18to59yr) %>%
  pull(income_big)

inequality <- round(gini(income_big, weights), 2)  
inequality

