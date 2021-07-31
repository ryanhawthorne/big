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
    selectInput("suburb",
                "Choose suburb:",
                suburbs,
                multiple = TRUE,
                selected = suburbs), 
    selectInput("gender",
                "Choose gender:",
                genders,
                multiple = TRUE,
                selected = genders),
    sliderInput("range",
                label = "Choose an age range:",
                min = 0,
                max = 100,
                value = c(0,100)),
    selectInput("lwv",
                "Choose whether lives, works or visits suburb:",
                lwvs,
                multiple = TRUE,
                selected = lwvs),
    selectInput("var",
                "Choose a variable",
                clean_questions,
                selected = "satisfaction")),
  
  mainPanel(
    textOutput("text_crime"),
    plotOutput("bar_crime"),
    textOutput("text_var"),
    plotOutput("bar_variable")
    
  ))


  
