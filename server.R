library(shiny)
library(devtools)
library(quantreg)
devtools::load_all("../FARg")

shinyServer(function(input, output) {

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

              output$b1 <- renderUI({
                if(!data_loaded()) return()
                actionButton("b1", "Plot Data")
              })

              output$fit_buttons <- renderUI({
                if(is.null(input$b1)) return()
                if(input$b1 == 0) return()
                list(
                     selectInput("fit_method", "Choose a fitting method:", 
                            choices = c("Gaussian", "GEV", "GPD")),
                     uiOutput("threshold"),
                     br(),
                     actionButton("b2", "Fit Model")
                     )
              })
              output$threshold <- renderUI({
                if(is.null(input$fit_method)) return()
                if(input$fit_method == "GPD"){
                  sliderInput("threshold", "Select GPD threshold", min=0, max=1, value=0.9, step=0.005)
                }
                else return()
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

              plot_data <- reactive({
                if(is.null(input$b1)) return()
                if(input$b1 == 0) return()
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
                    print("j'suis")
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
                print("fitting model")
                fit_input()(read_data())
              })
              # 
              output$fit_plot <- renderPlot({
                print("plotting fitted model")
                input$b2
                isolate({plot(fit_model())})
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
                       "Bootstrap" = boot_ic 
                       )
              })

              output$compute_ic <- renderPrint({
                if(is.null(input$b3))return()
                if(input$b3 == 0) return()
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


