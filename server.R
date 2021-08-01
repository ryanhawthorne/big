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

ghs <- readRDS("ghs")
weights <- ghs %>%
  pull(house_wgt)
ghs_svy <- ghs %>%
  select(uqnr, house_wgt,totmhinc, FSD_Hung_Adult,FSD_Hung_Child,hholdsz,LAB_SALARY_hh,ad60plusyr_hh,chld17yr_hh,ad18to60yr) %>%
  as_survey_design(weights = house_wgt)
adults <- ghs_svy %>%
  survey_tally(ad18to60yr) %>%
  pull(n)


server = function(input, output) {
  
poverty <- reactive({
    
  poverty <-  ghs %>%
    mutate(income_big = totmhinc + as.numeric(input$big) * ad18to60yr) %>%
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


inequality <- reactive({ 
  
  income_big <- ghs %>%
    mutate(income_big = totmhinc + as.numeric(input$big) * ad18to60yr) %>%
    pull(income_big)
  inequality <- round(gini(income_big, weights), 2)  

  })

cost <- reactive({ 

    cost = as.numeric(input$big) * adults * 12 

    })

output$text_poverty <- renderText("Households below the poverty line") 
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
         x = "Poverty line (Rands per person per month in household)") +
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
        
  })

output$text_inequality <- renderText("The resulting Gini co-efficient in South Africa is:")
output$inequality_result <- renderText(inequality())

output$text_cost <- renderText("The cost of the selected BIG (in Rands per year) is:")
output$cost <- renderUI(cost()) 
}