library(shiny)
shinyUI(
        pageWithSidebar(
                        headerPanel("FAR Analysis"),
                        sidebarPanel(
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
                                                      uiOutput("b1"),
                                                      br(),
                                                      uiOutput("fit_buttons"),
                                                      br(),
                                                      uiOutput("select_ic")
                                     ),
                        mainPanel(
                                                       verbatimTextOutput("summary"), 
                                                       tableOutput("contents"),
                                                       plotOutput("data_plot1"),
                                                       plotOutput("fit_plot"),
                                                       plotOutput("data_plot2"),
                                                       verbatimTextOutput("compute_ic")
                                                       )
                        )
        )
                                                                    
