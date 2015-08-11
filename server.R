library(shiny)
library(devtools)
devtools::load_all("../FARg")

shinyServer(function(input, output) {

              #               move_step <- reactive({
              #                 input$b1
              #                 cat("b1")
              #                 cat(input$b1)
              #                 return(input$b1)
              #               })

              output$step <- reactive({
                cat(move_step())
                move_step()
              })

              read_data <- reactive({
                  inFile <- input$file1
                  if (is.null(inFile))
                    return()
                  read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
              })

              output$contents <- renderTable({
                # input$file1 will be NULL initially. After the user selects and uploads a 
                # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
                # columns. The 'datapath' column will contain the local filenames where the 
                # data can be found.
                head(read_data(), n = input$obs)
              })

              output$summary <- renderPrint({
                summary(read_data())
              })
              
              output$fit_plot <- renderPlot({
                if(is.null(input$b2))return()
                if(input$b2 == 0) return()
                input$b2
                isolate(plot(fit_input()(read_data())))
              })

              output$select_method <- renderUI({
                if(is.null(read_data())) return()
                list(selectInput("fit_method", "Choose a fitting method:", 
                                 choices = c("Gaussian", "GEV", "GPD")),
                     uiOutput("threshold"),
                     br(),
                     actionButton("b2", "Fit Model")
                     )
              })

              output$threshold <- renderUI({
                if(input$fit_method == "GPD"){
                    sliderInput("threshold", "Select GPD threshold", min=0, max=1, value=0.9, step=0.005)
                }
                else return()
              })

              # Return the requested dataset
              fit_input <- reactive({
                if(is.null(read_data()))
                   return()
                switch(input$fit_method,
                       "Gaussian" = gauss_fit,
                       "GEV" = gev_fit,
                       "GPD" = function(x)gpd_fit(x, qthreshold=input$threshold)
                       )
              })

              output$select_ic <- renderUI({
                if(is.null(input$b2)) return()
                if(input$b2 == 0) return()
                ydat <- read_data()
                y_fit <- fit_input()(ydat)
                list(
                     selectInput("ic_method", "Choose a method for CI",
                     choices = c("Profile", "Bootstrap")),
                     sliderInput("xp", "Select Event Threhsold", min=min(ydat$y), max=max(ydat$y), value=median(ydat$y)),
                     sliderInput("t0t1", "Select Starting and Ending Dates", min=min(ydat$year), max=max(ydat$year), step=1,value=range(ydat$year)),
                     actionButton("b3", "Compute CI")
                     )
              })

              ic_input <- reactive({
                switch(input$ic_method,
                       "Profile" = prof_ic,
                       "Bootstrap" = function(xp, t0, t1, y_fit, ci_p=0.95)boot_ic(xp, t0, t1, y_fit, ci_p=ci_p ,under_threshold=TRUE)
                       )
              })
              
              output$compute_ic <- renderPrint({
                if(is.null(input$b3))return()
                if(input$b3 == 0) return()
                input$b3
                isolate({
                  ydat <- read_data()
                  ic_func <- ic_input()
                  y_fit <- fit_input()(ydat)
                  log <- capture.output({
                    ic_fit <- ic_func(xp=input$xp, t0=input$t0t1[1], t1=input$t0t1[2], y_fit=y_fit)
                  })
                  return(ic_fit)
                })
              })
})

