# ui
# code outside of the server function (here) will only be run once per session

library(dplyr)
library(shiny)
library(kableExtra)
library(tidyr)
library(ggplot2)

big_options <- c(0, 350, 585, 840, 1268)


ui <- fluidPage(
  headerPanel('Impact of universal basic income guarantee options on poverty, inequality, hunger and government expenditure in South Africa'),
  sidebarPanel(
    selectInput("big",
                h3("Choose a BIG (Rands per month)"),
                big_options,
                selected = 0),
    div("To find out more about the BIG, see:",
        a(href = "https://www.iej.org.za/wp-content/uploads/2021/03/IEJ-policy-brief-UBIG_2.pdf",
          "Institute for Economic Justice policy brief.")),
    
    h3("Impact on inequality"),
    
    div("The resulting Gini coefficient (a measure of inequality, where 0 is highly equal and 1 is highly unequal) is:"),

    h3(textOutput("inequality_result"), style = "color:#FF6666"),
    
    div("A reasonable Gini co-efficient is between 0.25 (similar to that in Finland, Norway and Sweden) and 0.35 (close to the Gini in Mauritius, 
        South Korea, and the United Kingdom). The Gini is calculated using monthly household income from the Statistics South Africa 
        General Household Survey (GHS, see note below), adding the BIG multiplied by the number of household members aged 18-59."),
    
    h3("Cost"),
    
    div("Cost of the BIG (Rbn per year):"),
    
    h3(textOutput("cost"), style = "color:#FF6666"),
    
    div("Cost as a percentage of government expenditure in 2021/22 (R2 020bn):"),
    
    h3(textOutput("expenditure"), style = "color:#FF6666"),
    
    div("The cost is calculated by multiplying the number of adults aged 18-59 years old, approximately 34.1m people, 
      by the BIG selected above and multiplying this by 12 to obtain an annual cost. Note that part of this amount is 
      likely to return to the fiscus via VAT, company income tax, and payroll taxes. Government collects approximately 
      26% of GDP in taxes in South Africa, suggesting a significant proportion of the cost of the BIG 
        will be recovered through taxes, since the BIG income would likely be spent on goods and services that attract VAT 
        and are supplied by companies paying income taxes and employing individuals paying income taxes.")
    ),
  
  mainPanel(
    h3("Households below the poverty line"),
    plotOutput("bar_poverty"),
    div("Notes: The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis. 
        The BIG is multiplied by the number of adults aged 18-59 in each household, and then this is added to the household's reported 
        monthly household income (see note below). The number of households under each Statistics South Africa poverty line and an additional 
        R350 per person per month (the Covid-19 social relief of distress grant) poverty line are counted."),
    h3("Households below the food poverty line reporting hunger"),
    plotOutput("bar_hunger"),
    div("Notes: The Statistics South Africa General Household Survey 2019 (published in 2020) was used to compile this analysis. 
        The BIG is multiplied by the number of adults aged 18-59 in each household, and then this is added to the 
        monthly household income. The number of households reporting hunger that are below the food poverty line (R585 per person per 
        month, multiplied by the number of people in the household) are then counted. A household that has an income, after adding 
        the BIG, that is higher than R585 multiplied by the number of household members, we assume to no longer be hungry. Note that 
        the number of households reporting hunger is closer to 2.5m, as households up to approximately R12,000 per month in income 
        still report some degree of hunger, and so the number of hungry households, even after the BIG, is likely significantly 
        under-estimated."),
    style="margin-bottom:50px;"),
  
    h3("Approach to calculating household income"),
    div("The approach to computing monthly household income from the GHS used here is similar to", 
        a(href = "https://www.datafirst.uct.ac.za/training/resources",
          "the methodology developed by Dr Andrew Kerr (DataFirst, UCT)."),
        "This approach starts by summing income from grants, salaries/wages, remittances, and pensions. If this sum is less than household expenditure,
        the latter is used instead. In addition to Dr Kerr's approach, if this derived household income was still less than the 'totmhinc' variable derived by Statssa, the
        latter replaced the former. Further, if the resulting household income variable was less than the reported minimum monthly income required for the household
        to make ends meet, and the respondent reported that household income was more or less the same, higher or much higher than this requirement, the latter was used. 
        After these adjustments, there are still 207 201 households reporting zero income, of which 64 846 report salaries/wages/commission as their main source of income,
        and 22 922 report other sources such as (rental income, interest) as their main source, and 30 845 report income from a business as the main source. The number of households
        under each poverty line is therefore overestimated to a small degree."),
    
    h3("Author and acknowledgements"),
    
    div("This Shiny app was built by:",
        a(href = "https://acaciaeconomics.com/people/ryanhawthorne",
          "Dr Ryan Hawthorne, an economist at Acacia Economics."),
        "The source code is ",
        a(href = "https://github.com/ryanhawthorne/big",
          "available on Github."),
        "The app benefited greatly from comments by staff at the Institute for Economic Justice and at Acacia Economics, and drew from",
        a(href = "https://www.datafirst.uct.ac.za/training/resources",
          "the work of Dr Andrew Kerr (DataFirst, UCT) on household incomes in the Statssa GHS."), 
        "Remaining errors are my own."),
  
  h3("References"),  
  
  div("Institute for Economic Justice. (March 2021). 'Introducing a universal basic income guarantee for South Africa: towards income security for all'. Avaialble
      at: https://www.iej.org.za/wp-content/uploads/2021/03/IEJ-policy-brief-UBIG_2.pdf"),
  
  div("Kerr, A. (2021). Measuring earnings inequality in South Africa using household survey and administrative tax microdata (No. wp-2021-82). 
      World Institute for Development Economic Research (UNU-WIDER). Available at: https://sa-tied.wider.unu.edu/sites/default/files/SA-TIED-WP180.pdf"),
      
  div("Statistics South Africa. General Household Survey 2019 [dataset]. Version 1. Pretoria: Statistics SA [producer], 2019. Cape Town: DataFirst [distributor], 
      2019.",
      style="margin-bottom:50px;")
  
)


  
