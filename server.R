library(shiny)
require(digest)
require(dplyr)
require(ggplot2)
require(rdrop2)

source('helpers.R')
###############################################################
##other stuff you may be able to put into the 

circleFun <- function(center = c(0,0),diameter = 1, npoints = 100){
  r = diameter / 2
  tt <- seq(0,2*pi,length.out = npoints)
  xx <- center[1] + r * cos(tt)
  yy <- center[2] + r * sin(tt)
  return(data.frame(xx = xx, yy = yy))
}
x <- 1:500
y   <- runif(500,0,1)
z   <- runif(500,0,1)
theta <- runif(500,0,360)
ycoor <- y * cos(theta)
zcoor <- z * sin(theta)

##origin, diameter and points
cir <- circleFun(c(0,0),2,npoints = 500)
test <- cbind.data.frame(x, y, z,ycoor,zcoor, theta, cir)

###############################################################

shinyServer(
  function(input, output, session) {
    
    ##########################################################
    ########### PART I: LOGIN ################################
    ##########################################################
    
    # When the Login button is clicked, check whether user name is in list
    observeEvent(input$login, {
      
      # User-experience stuff
      shinyjs::disable("login")
      
      # Check whether user name is correct
      # Fix me: test against a session-specific password here, not username
      user_ok <- input$password==session_password
      
      # If credentials are valid push user into experiment
      if(user_ok){
        shinyjs::hide("login_page")
        shinyjs::show("instructions")
        
        # Save username to write into data file
        output$username <- renderText({input$user})
      } else {
        # If credentials are invalid throw error and prompt user to try again
        shinyjs::reset("login_page")
        shinyjs::show("login_error")
        shinyjs::enable("login")
      }
      
    })
    
    ##########################################################
    ########### PART II: INSTRUCTIONS ########################
    ##########################################################
    
    observeEvent(input$confirm, {
      hide("instructions")
      show("form")
    })
    
    ##########################################################
    ########### PART III: MAIN EXPERIMENT ####################
    ##########################################################
    
    ## Initialize reactive values
    # round is an iterator that counts how often 'submit' as been clicked.
    values <- reactiveValues(round = 1)
    # df will carry the responses submitted by the user
    values$df <- NULL
    
    output$num <- renderText(paste("Question", values$round))
    
    
    output$bars <- renderImage({
      
      filename <- normalizePath(file.path('./www',                    paste('blue_bar_', values$round, '.png', sep='')))   
      list(src = filename)
    }, deleteFile = FALSE)
    
    ##########################################################
    ########## PART IIIa: MAIN HANDLER #######################
    ##########################################################
    
    ## This is the main experiment handler
    # Observe the submit button, if clicked... FIRE
    
    
    
    observeEvent(input$submit, {
      
      # Increment the round by one
      isolate({
        values$round <- values$round +1
      })
      
      
      # Call function formData() (see below) to record submitted response
      newLine <- isolate(formData())
      
      # Write newLine into data frame df
      isolate({
        values$df <- rbind(values$df, newLine)
      })
      
      updateSliderInput(session, "slide", value = 0,
                        min =1, max = 500)
      
      
      # Has the user reached the end of the experiment?
      # If so then...
      if(values$round > n_guesses){
        
        
        saveData(values$df)
        
        # Say good-bye
        hide(id = "form")
        show(id = "end")
      }
    })
    
    ## Utilities & functions
    
    # I take formData from Dean with minor changes.
    # When it is called, it creates a vector of data.
    # This will be a row added to values$df - one for each round.
    #
    # Gather all the form inputs (and add timestamp)
    formData <- reactive({
      data <- sapply(fieldsAll, function(x) input[[x]])
      data <- c(round = values$round-1, data, timestamp = humanTime())
      data <- t(data)
      data
    })
    
    # Here is the ggplot for the circle that shows up in the main experiment.  It sets ycoor and zcoor as the x and y axis of the plot that is to be rendered.  It then subsets the data by the value of x.  All the x values less than the slider input are included in the plot.
    
    output$distPlot <- renderPlot({
      p <- ggplot(test, aes(ycoor,zcoor))
      p + geom_point(data=subset(test, x < input$slide), size=4) + coord_fixed(ratio = 1) + geom_path(aes(xx, yy)) + scale_x_continuous(name="", breaks=NULL) +
        scale_y_continuous(name="", breaks=NULL) + theme(
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank())
    })
  })


# This renders the table of choices made by a participant that is shown
# to them on the final screen