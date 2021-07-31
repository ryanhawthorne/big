# ui
# code outside of the server function (here) will only be run once per session

library(janitor)
library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(stringr)
library(naniar)
library(ggplot2)
library(rlang)
library(forcats)

genders <- c("Female",
             "Male",
             "Other")
main_crimes <- c("Home burglary/theft", 
                 "Theft of motor vehicle", 
                 "Home robbery", 
                 "Robbery", 
                 "Hijacking of motor vehicle", 
                 "Business robbery", 
                 "Murder", 
                 "Sexual offence")
suburbs <- c("Craighall Park",
             "Dunkeld West",
             "Emmarentia",
             "Franklin Roosevelt Park",
             "Greenside",
             "Greenside East",
             "Parkhurst",
             "Parktown North",
             "Parktown West",
             "Parkview",
             "Westcliff")
lwvs <- c("Live in suburb (but do not work there)",
          "Live and work in suburb",
          "Work in suburb (but do not live there)",
          "Regularly visit suburb (but do not live or work there)")
clean_questions <-  c("Victim of crime" = "victim",
                      "Opened a case" = "open_case",
                      "Satisfaction with SAPS response" = "satisfaction_response",
                      "Experience with SAPS response" = "experience_response",
                      "Reasons for not opening a case" = "reasons_nocase",
                      "Victim support" = "victim_support",
                      "Source of victim support" = "support_source",
                      "Feel safe when it is dark" = "safe_dark",
                      "Feel safe during the day" = "safe_day",
                      "Protection" = "protection",
                      "Actions to protect" = "protection_action",
                      "No action to protect" = "protection_noaction",
                      "Protection advice" = "protection_advice",
                      "Action if see crime" = "see_crime",
                      "Frequency of gender crime" = "gender_crime",
                      "Shelter knowledge" = "shelter",
                      "SAPS visibility" = "visible",
                      "SAPS operations" = "police_operation",
                      "Trust in SAPS" = "trust",
                      "Priority crimes" = "priority_crimes",
                      "Priority activities" = "priority_activities",
                      "Satisfaction with SAPS" = "satisfaction",
                      "SAPS doing well" = "doing_well",
                      "SAPS problems" = "problems",
                      "CPF activities" = "cpf_activities",
                      "Actions to help" = "actions")




ui <- fluidPage(
  headerPanel('Parkview SAPS Community Policing Forum Survey'),
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


  
