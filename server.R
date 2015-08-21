library(shiny)
library(devtools)
library(quantreg)
library(alabama)
devtools::load_all("FARg")

shinyServer(function(input, output) {
              values <- reactiveValues(stage=0)
              # Check which step we are on
              observe ({
                if(is.null(input$file1)) return()
                isolate({values$stage  <- 1})
              })

              observe({
                if(is.null(input$b1) || input$b1 == 0)
                  return()
                values$stage  <- 2
              })

              observe({
                if(is.null(input$b2) || input$b2 == 0)
                  return()
                if(!is.null(input$b1) || input$b1 >= 0)
                  values$stage  <- 3
              })

              # UI according to the step we are on
              output$data_options <- renderUI({
                if(values$stage > 1) return()
                list(
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
                     numericInput("obs", "Number of observations to view:", 10)
                     )
              })

              output$print_data <- renderUI({
                if(values$stage != 1) return()
                list(
                     verbatimTextOutput("summary"),
                     tableOutput("contents")
                     )
              })

              output$b1 <- renderUI({
                if(!data_loaded()) return()
                if(values$stage > 1) return()
                actionButton("b1", "OK - Next Step")
              })

              output$results <- renderUI({
                if(values$stage > 2)
                list(
                     verbatimTextOutput("compute_ic")
                     )
              })

              output$fit_buttons <- renderUI({
                if(values$stage >= 2)
                  list(
                       selectInput("fit_method", "Choose a fitting method:",
                                   choices = c("Gaussian", "GEV", "GPD")),
                       uiOutput("threshold"),
                       br(),
                       actionButton("b2", "Fit Model")
                       )
              })

              output$threshold <- renderUI({
                print("method choice")
                if(is.null(input$fit_method)) return()
                if(input$fit_method == "GPD"){
                  sliderInput("threshold", "Select GPD threshold", min=0, max=1, value=0.9, step=0.005)
                }
                else return()
              })

              output$select_ic <- renderUI({
                if(values$stage>= 3){
                  ydat <- read_data()
                  y_fit <- fit_input()(ydat)
                  list(
                       selectInput("ic_method", "Choose a method for CI",
                                   choices = c("Profile", "Bootstrap")),
                       sliderInput("xp", "Select Event Threhsold", min=min(ydat$y), max=max(ydat$y), value=median(ydat$y)),
                       sliderInput("t0t1", "Select Starting and Ending Dates", min=min(ydat$year), max=max(ydat$year), step=1,value=range(ydat$year)),
                       actionButton("b3", "Compute FAR")
                       )
                }
              })

              read_data <- reactive({
                inFile <- input$file1
                if (is.null(inFile))
                  return()
                cat("Loading Data \n")
                read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
              })

              data_loaded <- reactive({
                !is.null(read_data())
              })



              output$contents <- renderTable({
                # input$file1 will be NULL initially. After the user selects and uploads a
                # file, it will be a data frame with 'name', 'size', 'type', and 'datapath'
                # columns. The 'datapath' column will contain the local filenames where the
                # data can be found.
                if(is.null(input$file1)) return()
                head(read_data(), n = input$obs)
              })

              output$summary <- renderPrint({
                if(is.null(input$file1)) return(invisible())
                summary(read_data())
              })

              plot_data <- reactive({
                if(values$stage< 2) return()
                ydat <- read_data()
                ydat <- ydat[order(ydat$year),]
                plot(ydat$year, ydat$y, ylab="y", xlab="years")
                if(!is.null(input$fit_method)) {
                  if(input$fit_method == "GPD") {
                    lines(ydat$year, predict(quantreg::rq(y~mu_var, data=ydat, tau=input$threshold)), col="red", lwd=2)
                  }
                }
                if(!is.null(input$ic_method)) {
                  if(!is.null(input$ic_method)) {
                    abline(h=input$xp, col="blue", lwd=2)
                    abline(v=input$t0t1[1], col="blue", lwd=2)
                    abline(v=input$t0t1[2], col="blue", lwd=2)
                  }
                }
              })

              output$data_plot1 <- renderPlot({
                print("plotting data for fit")
                plot_data()
              }, width=600, height=400)

              #Return the requested dataset
              fit_input <- reactive({
                print("modifying fit method")
                if(is.null(input$fit_method)) return()
                switch(input$fit_method,
                       "Gaussian" = gauss_fit,
                       "GEV" = gev_fit,
                       "GPD" = function(x)gpd_fit(x, qthreshold=input$threshold)
                       )
              })

              fit_model  <- reactive({
                input$b2
                isolate({
                  print("fitting model")
                  fit_input()(read_data())
                })
              })
              #
              output$fit_plot <- renderPlot({
                print("plotting fitted model")
                print(paste("stage", values$stage))
                print(paste("b2", input$b2))
                if(is.null(input$b2)) return()
                if(values$stage < 2) return()
                if(input$b2 == 0 && values$stage < 3) return()
                plot(fit_model())
              }, width=900, height=600)


              ic_input <- reactive({
                switch(input$ic_method,
                       "Profile" = prof_ic,
                       "Bootstrap" = boot_ic
                       )
              })

              output$compute_ic <- renderPrint({
                if(is.null(input$b3))return(invisible())
                if(input$b3 == 0) return(invisible())
                input$b3
                isolate({
                  ydat <- read_data()
                  if( input$ic_method == "Bootstrap" & input$fit_method == "GPD")
                    ic_func <- function(xp, t0, t1, y_fit, ci_p=0.95) ic_input()(xp, t0, t1, y_fit, ci_p=ci_p ,under_threshold=TRUE)
                  else
                    ic_func <- ic_input()
                  y_fit <- fit_input()(ydat)
                  log <- capture.output({
                    ic_fit <- ic_func(xp=input$xp, t0=input$t0t1[1], t1=input$t0t1[2], y_fit=y_fit)
                  })
                  return(ic_fit)
                })
              })
              #

})


