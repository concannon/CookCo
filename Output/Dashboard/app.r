#

pkgs <- c("shinydashboard", "tidyr", "DT",
          "tidyverse", "here", "DescTools", "skimr",
          "lubridate", "sjmisc", "tictoc", "purrr",
          "xtable", "ggalt", "knitr", "kableExtra", "janitor",
          "scales", "Cairo", "dplyr", "feather")

options(scipen=1000)
#Report: https://www.cookcountystatesattorney.org/sites/default/files/files/documents/ccsao_2017_data_report_180220.pdf


lapply(pkgs, require, character.only = T)


file <- here::here("data", "dataset.feather")
df <- read_feather(file)


header <-   dashboardHeader(title="Cook County State's Attorney",
                            titleWidth=300)

sidebar <-  dashboardSidebar(
  width=300,
  sidebarMenu(
    menuItem("Dashboard",tabName="dashboard", icon = icon("chart-line")),
    menuItem("Filters",tabName="filters", icon = icon("users"), startExpanded = T,
              sliderInput("filter_year", "Year", min=2012, max=2018, value = c(2012, 2018)),
              selectizeInput("filter_event", "Case Type",choices = levels(df$EVENT), multiple = T)
  )))



#DescTools::Desc(df$EVENT)

body <-   dashboardBody(
  tabItems(
    tabItem(tabName="dashboard",
            fluidRow(
              column(6, plotOutput("plot1")),
              column(6, plotOutput("plot2"))
                    ),
            fluidRow(
              column(6, plotOutput("plot3")),
              column(6, plotOutput("plot4"))
            )
    
    )
  )
)


shinyApp(
  ui = dashboardPage(header, sidebar, body, skin = "green"),
  server = function(input, output,session) {
    
    # Data
    
    dataset <- reactive({ df })
    
    dataset_filtered <- reactive({ 
      dataset() %>% 
        filter(arrest_year >= input$filter_year[1],
               arrest_year <= input$filter_year[2])})
    
    
    
    output$plot1 <- renderPlot({
      qplot(mtcars$mpg)
    })
    
    output$plot2 <- renderPlot({
      qplot(mtcars$cyl)
    })
    
    
    output$plot3 <- renderPlot({
      dataset_filtered() %>% 
        group_by(arrest_year) %>% 
        summarise(number = n()) %>% 
        ggplot(aes(arrest_year, number, group = 1))+geom_line()
    })
    
    
  })

