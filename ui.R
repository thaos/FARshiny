library(shiny)
shinyUI(
        pageWithSidebar(
                        headerPanel("FAR Analysis"),
                        sidebarPanel(
                                     fileInput('file1', 'Choose CSV File',
                                               accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                                     uiOutput("data_options"),
                                     uiOutput("b1"),
                                     br(),
                                     uiOutput("fit_buttons"),
                                     br(),
                                     uiOutput("select_ic")
                                     ),
                        mainPanel(
                                  verbatimTextOutput("compute_ic")
                                  uiOutput("print_data"),
                                  plotOutput("data_plot1"),
                                  plotOutput("fit_plot"),
                                  plotOutput("data_plot2"),
                                  )
                        )
        )

