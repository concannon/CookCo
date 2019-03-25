# library(shinydashboard)
# library(leaflet)
# library(dplyr)
# library(httr); set_config(use_proxy(url='10.229.55.48',port=9191,username='linuxit',password='LIdany12'))
# library(ggplot2)
# library(ggmap)
# library(RColorBrewer)
# library(tidyr)
# library(reshape2)
# library(DT)
# library(stringr)



pkgs <- c("shinydashboard", "tidyr", "DT",
          "tidyverse", "here", "DescTools", "skimr",
          "lubridate", "sjmisc", "tictoc", "purrr",
          "xtable", "ggalt", "knitr", "kableExtra", "janitor",
          "scales", "Cairo", "dplyr", "feather")

options(scipen=1000)
#Report: https://www.cookcountystatesattorney.org/sites/default/files/files/documents/ccsao_2017_data_report_180220.pdf


lapply(pkgs, require, character.only = T)

#install.packages('ggmap')

#load("/srv/shiny-server/Programs/Program workspace.RData")


# Nathan's edits
#setwd("P:/Bureau Data/PLANNING/Data Requests/2016.05.05 - Diversion Imogen/Programs")



header <-   dashboardHeader(title='Program Providers, v1.0',
                            titleWidth=300)

sidebar <-  dashboardSidebar(
  width=300,
  sidebarMenu(
    menuItem("Map",tabName='Map'),
    menuItem('Table',tabName='List')
  ))


body <-   dashboardBody(
  tabItems(
    tabItem(tabName='Map',
            fluidRow(
              #leafletOutput('map',height=800,width="100%")
              textInput("ada","ADA",""),
              actionButton("submit","Submit")
            )
    ),
    tabItem(tabName='List',
            fluidRow(
              dataTableOutput('table')
              
            )
    )
  )
)


shinyApp(
  ui = dashboardPage(header, sidebar, body),
  server = function(input, output,session) {
    
    
    
    
    
    
    
    # Create filtered map
    #output$map <- renderLeaflet(
    #   map <- leaflet() %>%
    #     addProviderTiles("CartoDB.Positron") %>%
    #     #addTiles("http://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png") %>%
    #     setView(-73.974,40.771,zoom=11) 
    #   
    # )
    # 
    # 
    # 
    # # Add geocoded address when clicked ON FULL MAP
    # observeEvent(input$button_click_count,{
    #   v <- geocode_origin()
    #   print(v)
    #   leafletProxy('map') %>%
    #     addCircleMarkers(lng=v$lon,lat=v$lat,color="red",radius=20) %>%
    #     setView(lng=v$lon,lat=v$lat,zoom=12)
    # }) 
    
    # Table   
    output$table <- renderDataTable({ mtcars},
                                    options=list(dom = 'Bfrtip',pageLength=10,scrollX=TRUE,
                                                 buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
    
  })

