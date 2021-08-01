# ui
# code outside of the server function (here) will only be run once per session

library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(ggplot2)

big_options <- c(0, 350, 585, 840, 1268)


ui <- fluidPage(
  headerPanel('Households below the poverty line in South Africa for different BIG options'),
  sidebarPanel(
    selectInput("big",
                "Choose BIG option:",
                big_options,
                selected = 0)),
  
  mainPanel(
    textOutput("text_poverty"),
    plotOutput("bar_poverty"),
    div("The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis.", style = "color:gray"),

  )
)


  
