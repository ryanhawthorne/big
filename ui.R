# ui
# code outside of the server function (here) will only be run once per session

library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(ggplot2)

big_options <- c(350, 586, 840, 1268)

ui <- fluidPage(
  headerPanel('General Household Survey 2019'),
  sidebarPanel(
    selectInput("big",
                "Choose BIG option:",
                big_options,
                multiple = FALSE,
                selected = big_options), 
                )),
  
  mainPanel(
    textOutput("text_crime"),
    plotOutput("bar_crime"),
    textOutput("text_var"),
    plotOutput("bar_variable")
    
  ))


  
