library(shiny)
shinyUI(
        pageWithSidebar(
                        headerPanel("FAR Analysis"),
                        sidebarPanel(
                                     tags$head(tags$style(type="text/css", "
                                                          #loadmessage {
                                                          position: fixed;
                                                          top: 0px;
                                                          left: 0px;
                                                          width: 100%;
                                                          padding: 5px 0px 5px 0px;
                                                          text-align: center;
                                                          font-weight: bold;
                                                          font-size: 100%;
                                                          color: #000000;
                                                          background-color: #CCFF66;
                                                          z-index: 105;
}
")),
                                     fileInput('file1', 'Choose CSV File',
                                               accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                                     uiOutput("data_options"),
                                     uiOutput("b1"),
                                     br(),
                                     uiOutput("fit_buttons"),
                                     br(),
                                     uiOutput("select_ic"),
                                     conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                                                  tags$div("Loading...",id="loadmessage"))
                                     ),
                        mainPanel(align="center",
                                  uiOutput("results"),
                                  uiOutput("print_data"),
                                  plotOutput("data_plot1"),
                                  plotOutput("fit_plot"),
                                  plotOutput("data_plot2")
                                  )
                        )
        )

