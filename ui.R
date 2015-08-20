library(shiny)
shinyUI(
        pageWithSidebar(
                        headerPanel("FAR Analysis"),
                        sidebarPanel(
                                     #                                      conditionalPanel(
                                     #                                                       "$('li.active a').first().html()==='Data'",
                                                      fileInput('file1', 'Choose CSV File',
                                                                accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                                                      checkboxInput('header', 'Header', TRUE),
                                                      radioButtons('sep', 'Separator',
                                                                   c(Comma=',',
                                                                     Semicolon=';',
                                                                     Space=" ",
                                                                     Tab='\t'),
                                                                   'Comma'),
                                                      radioButtons('quote', 'Quote',
                                                                   c(None='',
                                                                     'Double Quote'='"',
                                                                     'Single Quote'="'"),
                                                                   'Double Quote'),
                                                      numericInput("obs", "Number of observations to view:", 10),
                                                      #                                                       ),
                                                      #                                      conditionalPanel(
                                                      #                                                       "$('li.active a').first().html()==='Model Fit'",
                                                      selectInput("fit_method", "Choose a fitting method:", 
                                                                         choices = c("Gaussian", "GEV", "GPD")),
                                                      uiOutput("threshold"),
                                                      br(),
                                                      actionButton("b2", "Fit Model"),
                                                      #                                                       ),
                                                      #                                      conditionalPanel(
                                                      #                                                       "$('li.active a').first().html()==='FAR Estimation'",
                                                      uiOutput("select_ic")
                                                      #                                                       )
                                     ),
                        mainPanel(
                                  #                                   tabsetPanel(
                                  #                                               tabPanel("Data", 
                                                       verbatimTextOutput("summary"), 
                                                       tableOutput("contents"),
                                                       #                                                        ),
                                                       #                                               tabPanel("Model Fit", 
                                                       plotOutput("data_plot1"),
                                                       plotOutput("fit_plot"),
                                                       #                                                        ),
                                                       #                                               tabPanel("FAR Estimation", 
                                                       plotOutput("data_plot2"),
                                                       verbatimTextOutput("compute_ic")
                                                       )
                        #                                               )
                        #                                   )
                        )
        )
                                                                    
