library(shiny)
shinyUI(
        pageWithSidebar(
                        headerPanel("CSV Viewer"),
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
                                                    br(),
                            uiOutput("plot_button"),
                                                      br(),
                                                      shiny::uiOutput("select_method"),
                                                      br(),
                                                      shiny::uiOutput("select_ic")
                                     ),
                        mainPanel(
                                  verbatimTextOutput("summary"),
                                  tableOutput("contents"),
                                  plotOutput("fit_plot"),
                                  verbatimTextOutput("compute_ic")
                                  )
                        )
        )

