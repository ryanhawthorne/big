# ui
# code outside of the server function (here) will only be run once per session

library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(ggplot2)

big_options <- c(0, 350, 585, 840, 1268)


ui <- fluidPage(
  headerPanel('Impact of basic income grants options on poverty, inequality and hunger in South Africa'),
  sidebarPanel(
    selectInput("big",
                h3("Choose a BIG"),
                big_options,
                selected = 0),
    div("Rands per month per person aged 18-59 years old."),
    
    h3("Impact on inequality"),
    textOutput("text_inequality"),
    
    h3(textOutput("inequality_result")),
    
    div("A reasonable Gini co-efficient is between 0.25 (such as in Sweden, Norway and Finland) and 0.35 (Mauritius, South Korea, United Kingdom.)"),
    
    h3("Cost"),
    
    textOutput("text_cost"),
    
    h3(textOutput("cost")),
    
    div("The cost is calculated by multiplying the number of adults aged 18-59 years old, approximately 34.1m people, by the BIG selected above 
        and multiplying this by 12 to obtain an annual cost. Note that part of this amount is likely to return to the fiscus via VAT, company income tax, 
        and payroll taxes. Government collects approximately 25% of output in taxes in South Africa, suggesting approximately 25% of the cost of the BIG 
        will be recovered through taxes.")
    ),
  
  mainPanel(
    h3("Households below the Statistics South Africa poverty lines"),
    plotOutput("bar_poverty"),
    div("The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis. 
        The BIG is multiplied by the number of adults aged 18-59 in each household, and then this is added to the monthly household income, and the number of households under each poverty line are counted.", style = "color:gray"),
    h3("Number of households below the food poverty line (R585 per person) reporting hunger"),
    plotOutput("bar_hunger"),
    div("The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis. 
        The BIG is multiplied by the number of adults aged 18-59 in each household, and then this is added to the monthly household income. 
        The number of households reporting hunger that are below the food poverty line are then counted. Note that the number of households reporting 
        hunger is closer to 2.5m, as households up to approximately R12,000 per month in income still report some degree of hunger.", style = "color:gray"),
    
    
  )
)


  
