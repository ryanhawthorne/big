# ui
# code outside of the server function (here) will only be run once per session

library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(ggplot2)

big_options <- c(0, 350, 585, 840, 1268)


ui <- fluidPage(
  headerPanel('Households below the poverty line in South Africa for different basic income grants'),
  sidebarPanel(
    selectInput("big",
                "Choose basic income grant (Rands per month per person aged 18-60):",
                big_options,
                selected = 0),
    textOutput("text_inequality"),
    textOutput("inequality_result"),
    div("A reasonable Gini co-efficient is around 0.35, similar to South Korea or the United Kingdom."),
    textOutput("text_cost"),
    textOutput("cost")
    ),
  
  mainPanel(
    textOutput("text_poverty"),
    plotOutput("bar_poverty"),
    div("The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis. 
        The BIG is multiplied by the number of adults aged 18-60 in each household, and then this is added to the monthly household income.", style = "color:gray"),

  )
)


  
