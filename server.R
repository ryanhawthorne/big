# server
# every time someone runs a render function, it runs, so minimum code

library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(ggplot2)

server = function(input, output) {
  
ghs <- readRDS("ghs")

ghs_income <- reactive({
    
    ghs %>%
      select(totmhinc) %>%
      group_by(bin) %>%
      tally() %>%
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