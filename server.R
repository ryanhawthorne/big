# server
# every time someone runs a render function, it runs, so minimum code

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

server = function(input, output) {
  
  cpf <- read.csv("cpf.csv")
  crime_sep <- read.csv("crime_sep.csv")
  
  
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
  
  crime_suburb <- reactive({
    
    crime_sep %>%
      filter(suburb %in% input$suburb,
             gender %in% input$gender,
             age %in% (input$range[1]:input$range[2]),
             crime != "") %>%
      group_by(crime) %>%
      tally() %>%
      arrange(-n) %>%
      mutate(crime = fct_reorder(crime, -n)) %>%
      ungroup()
  })

  survey_variable <- reactive({
    
     varname <- input$var
     cpf %>%
       filter(suburb %in% input$suburb,
              gender %in% input$gender,
              age %in% (input$range[1]:input$range[2]),
              input$var != "") %>%
       group_by_at(input$var) %>%
       tally() %>%
       arrange(-n) %>%
       # mutate(input$var = fct_reorder(.[[input$var]], -n)) %>%
       ungroup()
   })
  
  output$text_crime <- renderText("Crimes experienced by victims") 
  output$bar_crime <- renderPlot({

    ggplot(crime_suburb(), aes(x = crime, y = n)) +
      geom_bar(stat="identity") +
      coord_flip() +
      ylab("Number of incidents") + 
      xlab("")
    
  })
 
  output$text_var <- renderText(names(clean_questions)[clean_questions == input$var]) 
  output$bar_variable <- renderPlot({

    ggplot(survey_variable(), aes(x = get(input$var), y = n)) +
      geom_bar(stat="identity") +
      coord_flip() +
      ylab("") +
      xlab("")
  })


}