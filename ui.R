# ui
# code outside of the server function (here) will only be run once per session

library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(ggplot2)

big_options <- c(0, 350, 585, 840, 1268)


ui <- fluidPage(
  headerPanel('Impact of basic income grant options on poverty, inequality, hunger and government expenditure in South Africa'),
  sidebarPanel(
    selectInput("big",
                h3("Choose a BIG"),
                big_options,
                selected = 0),
    div("Rands per month per person aged 18-59 years old."),
    
    h3("Impact on inequality"),

    h3(textOutput("inequality_result"), style = "color:#FF6666"),
    
    div("A reasonable Gini co-efficient is between 0.25 (such as in Sweden, Norway and Finland) and 0.35 (Mauritius, South Korea, United Kingdom.)"),
    
    h3("Cost"),
    
    div("Cost of the BIG in Rands per year:"),
    
    h3(textOutput("cost"), style = "color:#FF6666"),
    
    div("Cost as a percentage of government expenditure in 2021/22 (R2.02tn):"),
    
    h3(textOutput("expenditure"), style = "color:#FF6666"),
    
    div("The cost is calculated by multiplying the number of adults aged 18-59 years old, approximately 34.1m people, by the BIG selected above 
        and multiplying this by 12 to obtain an annual cost. Note that part of this amount is likely to return to the fiscus via VAT, company income tax, 
        and payroll taxes. Government collects approximately 26% of GDP in taxes in South Africa, suggesting a significant proportion of the cost of the BIG 
        will be recovered through taxes, since the BIG income would likely be spent on goods and services that attract VAT and are supplied by companies paying 
        income taxes and employing individuals paying income taxes.")
    ),
  
  mainPanel(
    h3("Households below the poverty line"),
    plotOutput("bar_poverty"),
    div("The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis. 
        The BIG is multiplied by the number of adults aged 18-59 in each household, and then this is added to the household's reported monthly household income.
        The number of households under each Statistics South Africa poverty line and an additional R350 per person per month 
        (the Covid-19 social relief of distress grant) poverty line are counted.", style = "color:gray"),
    h3("Households below the food poverty line reporting hunger"),
    plotOutput("bar_hunger"),
    div("The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis. 
        The BIG is multiplied by the number of adults aged 18-59 in each household, and then this is added to the monthly household income. 
        The number of households reporting hunger that are below the food poverty line (R585 per person per month, multiplied by the number of people 
        in the household) are then counted. A household that has an income, after adding the BIG, that is higher than R585 multiplied by the number of 
        household members is assumed to no longer be hungry. Note that the number of households reporting hunger is closer to 2.5m, 
        as households up to approximately R12,000 per month in income still report some degree of hunger, and so the number if hungry households, even after
        the BIG, is likely significantly under-estimated.", style = "color:gray"),
    
    
  )
)


  
