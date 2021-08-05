# server
# every time someone runs a render function, it runs, so minimum code

library(dplyr)
library(shiny)
library(tidyr)
library(ggplot2)
require(scales)
library(reldist)
library(srvyr)



lines <- c("poverty350", "poverty585", "poverty840", "poverty1268") # for ordering in ggplot graph
hungry_list <- c("food_ranout","food_skipped", "food_adult","food_child")


ghs <- readRDS("ghs")
weights <- ghs %>%
  pull(house_wgt)
ghs_svy <- ghs %>%
  select(uqnr, house_wgt,totmhinc, FSD_Hung_Adult,FSD_Hung_Child,hholdsz,LAB_SALARY_hh,ad60plusyr_hh,chld17yr_hh,ad18to59yr) %>%
  as_survey_design(weights = house_wgt)
adults <- 34100000 # iej source
expenditure_total <- 2020400000000

server = function(input, output) {
  
poverty <- reactive({
    
  poverty <-  ghs %>%
    mutate(income_big = totmhinc + as.numeric(input$big) * ad18to59yr) %>%
    mutate(poverty350 = income_big < hholdsz * 350,
           poverty585 = income_big < hholdsz * 585,
           poverty840 = income_big < hholdsz * 840,
           poverty1268 = income_big < hholdsz * 1268) %>%
    select(poverty350, poverty585, poverty840, poverty1268, uqnr, house_wgt) %>%
    pivot_longer(cols = starts_with("poverty"), 
                 names_to = "poverty_line",
                 values_to = "poor") %>%
    filter(poor == TRUE)
  })

hungry <- reactive({
  hungry <- ghs %>%
    mutate(income_big = totmhinc + as.numeric(input$big) * ad18to59yr) %>%
    mutate(food_skipped = FSD_SKIPPED == "Yes",
           food_ranout = FSD_RANOUT == "Yes",
           food_adult = FSD_Hung_Adult == "Always" | FSD_Hung_Adult ==  "Often" | FSD_Hung_Adult == "Sometimes" | FSD_Hung_Adult =="Seldom", 
           food_child = FSD_Hung_Child == "Always" | FSD_Hung_Child == "Often" | FSD_Hung_Child == "Sometimes" | FSD_Hung_Child == "Seldom") %>%
    mutate(food_skipped = ifelse(income_big > hholdsz * 585  & food_skipped == TRUE, FALSE,food_skipped), # + 12000
           food_ranout = ifelse(income_big > hholdsz *  585 & food_ranout == TRUE, FALSE,food_ranout),  # + 12000
           food_adult = ifelse(income_big > hholdsz * 585  & food_adult == TRUE, FALSE, food_adult), # + 12000
           food_child = ifelse(income_big > hholdsz * 585  & food_child == TRUE, FALSE,food_child)) %>% # + 12000
    select(food_skipped, food_ranout, food_adult, food_child, uqnr, house_wgt) %>%
    pivot_longer(cols = starts_with("food"), 
                 names_to = "food_indicator",
                 values_to = "hungry") %>%
    filter(hungry == TRUE) 
  
  })

inequality <- reactive({ 
  
  income_big <- ghs %>%
    mutate(income_big = totmhinc + as.numeric(input$big) * ad18to59yr) %>%
    pull(income_big)
  inequality <- round(gini(income_big, weights), 2)  

  })

cost <- reactive({ 
    
    cost = scales::comma(as.numeric(input$big) * adults * 12) 

    })

expenditure <- reactive({ 
  
  expenditure = scales::percent((as.numeric(input$big) * adults * 12) / as.numeric(expenditure_total)) 
  
})

output$bar_poverty <- renderPlot({

  ggplot(poverty(),
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
         x = "Poverty line (Rands per person per month in each household)") +
    scale_x_discrete(limits = lines,
                     labels = c("poverty350" = "R350", "poverty585" = "R585", "poverty840" = "R840", "poverty1268" = "R1268")) +
    theme(axis.text.x = element_text(angle = 90,
                                     size = 10,
                                     colour = "Black")) +
    scale_y_continuous(labels = comma,
                       limits = c(0,9000000)) +
    geom_text(stat='count', 
              aes(label=scales::comma(..count..)),
              vjust = -1,
              size = 3.5) 
        
  })

output$bar_hunger <- renderPlot({
  ggplot(hungry(),
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
    labs(y = "Number of households below the food poverty line (R585/person/month)",
         x = "") +
    scale_x_discrete(limits = hungry_list,
                     labels = c("food_ranout" = "Food ran out", "food_skipped" = "Skipped a meal", "food_adult" = "Hungry adult", "food_child" = "Hungry child")) +
    theme(axis.text.x = element_text(angle = 90,
                                     size = 10,
                                     colour = "Black")) +
    scale_y_continuous(labels = comma,
                       limits = c(0,1300000)) +
    geom_text(stat='count', 
              aes(label=scales::comma(..count..)),
              vjust = -1,
              size = 3.5) 
  
  })

output$inequality_result <- renderText(inequality())

output$cost <- renderText(cost()) 

output$expenditure <- renderText(expenditure())
}