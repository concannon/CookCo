
source("app_setup.r")

header <-   dashboardHeader(title="Cook County States Attorney",
                            titleWidth=300)

# Sidebar ---------------------------------------------------------------------
sidebar <-  dashboardSidebar(
  width=300,
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Filters", tabName = "dashboard", icon = icon("filter"),
             startExpanded = T,
             sliderInput(inputId = "year", label = "Arrest Year",
                           min = 2012, max = 2018, value = c(2012,2018)),
             selectizeInput(inputId = "charge", label = "Top Charge",
                            choices=c("All", sort(unique(df$`Offense_Category`))),
                            options = list(placeholder = "All"),
                            multiple = T)
    )
  ))

# Body ------------------------------------------------------------------------
body <-   dashboardBody(
  
  
  fluidRow(
      valueBoxOutput("defendants_selected")
     ,valueBoxOutput("mean_age")
     , valueBoxOutput("male")
  ),
  tabBox(
    title = "",
    id = "tabset1", height = "100", width=12,
    tabPanel("Plots", "",
             fluidRow(
                column(6, plotlyOutput("plot_defendants")),
                column(6, plotlyOutput("plot_disp"))
             ),
             fluidRow(
                column(6,plotlyOutput("plot_chg")),
                column(6,plotlyOutput("plot_sen"))
             )
    ),
    tabPanel("Table","",
             fluidRow(
               dataTableOutput("data_table")
             )
    )
  )
)

# Server ----------------------------------------------------------------------
shinyApp(
  ui = dashboardPage(header, sidebar, body, skin = "green"),
  server = function(input, output,session) {
    
    # Dataset ---------------------------------------------------------------  
    dataset <- reactive({df})
    
    dataset_filtered <- reactive({
      dataset() %>% 
      {if (is.null(input$year)) . 
        else filter(.,`arrest_year` >= input$year[1],
                      `arrest_year` <= input$year[2])} %>% 
      {if (is.null(input$charge)) .
        else filter(., Offense_Category %in% input$charge)}
    })
    
    observe({
      if("All" %in% input$branch){
        updateSelectizeInput(session = getDefaultReactiveDomain(),
                             "branch", 
                             choices = c("All", sort(unique(df$`Home Branch`))),
                             options = list(placeholder = "All"))
      }
    })
    
    # Value Boxes ----------------------------------------------------------
    
    output$defendants_selected <- renderValueBox({
      
      defendants <- nrow(dataset_filtered())
      percent <- round((defendants/overall_n)*100,2)
      
      valueBox(
        prettyNum(defendants, big.mark = ","), paste0("Defendants Selected", " (", percent, "% of total )"),
        icon = icon("percent"), color = "purple"
      )
    })
    
    output$mean_age <- renderValueBox({
      valueBox(
        round(mean(dataset_filtered()$`AGE_AT_INCIDENT`, na.rm = T),1), "Average Age",
        icon = icon("users"), color = "green"
      )
    })
    
    output$male <- renderValueBox({
      valueBox(
        round(nrow( dataset_filtered()[!is.na(dataset_filtered()$`SENTENCE_TYPE`),])
              / nrow(dataset_filtered())*100,1)
        , "Percent Sentenced",
        icon = icon("line-chart"), color = "yellow"
      )
    })
    
    # Plots -------------------------------------------------------------------
    
    # Defendant Count
    output$plot_defendants <- renderPlotly({
      
      p1 <- dataset_filtered() %>% 
        group_by(arrest_year) %>% 
        summarise(Defendants = n()) %>% 
        ggplot(aes(arrest_year, Defendants))+
        geom_bar(stat = "identity")+
        theme_minimal()+
        theme(legend.position = "none")+
        scale_y_continuous()+
        labs(title = "Defendants by Year",
             y = "# of Defendants",
             x = "Arrest Year") 
      
      ggplotly(p1, tooltip = c("y", "label"))
    })
    
    # Dispositions
    output$plot_disp <- renderPlotly({
      
      p2<- dataset_filtered() %>% 
        filter(disposed.x == 1) %>% 
        group_by(Disposition = disp) %>% 
        summarise(Defendants = n()) %>% 
        mutate(Percent = Defendants/sum(Defendants)) %>% 
        ggplot(aes(reorder(Disposition, Percent), Percent))+
        geom_bar(stat = "identity")+
        coord_flip()+
        theme_minimal()+
        
        theme(legend.position = "none")+
        scale_y_continuous(labels = scales::percent)+
        labs(title = "Disposition",
             y = "Percent of Defendants",
             x = "Disposition") 
      
      ggplotly(p2, tooltip = c("y", "label"))
    
    })
    
    # Common Charges
    output$plot_chg <- renderPlotly({
      
      p3 <- dataset_filtered() %>% 
        group_by(`Category` = Offense_Category) %>% 
        summarise(Defendants = n()) %>% 
        mutate(Percent = Defendants/sum(Defendants)) %>% 
        top_n(n = 15, wt = Percent) %>% 
        ggplot(aes(reorder(Category, Percent), Percent))+
        geom_bar(stat = "identity")+
        coord_flip()+
        theme_minimal()+
        theme(legend.position = "none")+
        scale_y_continuous(labels = scales::percent)+
        labs(title = "Most Common Charges",
             y = "Percent of Defendants",
             x = "Offense Category") 
      
      ggplotly(p3, tooltip = c("y", "label"))
      
    })
    
    # Sentences
    output$plot_sen <- renderPlotly({
      
      p4 <- dataset_filtered() %>% 
        filter(!is.na(SENTENCE_TYPE)) %>% 
        group_by(Sentence = SENTENCE_TYPE) %>% 
        summarise(Defendants = n()) %>% 
        mutate(Percent = Defendants/sum(Defendants)) %>% 
        ggplot(aes(reorder(Sentence, Percent), Percent))+
        geom_bar(stat = "identity")+
        coord_flip()+
        theme_minimal()+
        
        theme(legend.position = "none")+
        scale_y_continuous(labels = scales::percent)+
        labs(title = "Sentences",
             y = "Percent of Defendants",
             x = "Sentence") 
      
      ggplotly(p4, tooltip = c("y", "label"))
      
    })
    
    # Data Export ----------------------------------------------------------   
    output$data_table <- renderDataTable({ 
      dataset_filtered() %>% 
        head(100)
    },
    #caption = "Selected Defendant List (n=100)",
    options = list(dom = 'Bfrtip',pageLength=10,scrollX=TRUE,
                   buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
    
  })
