library(shiny)
require(digest)
require(dplyr)
require(ggplot2)
require(rdrop2)

source('helpers.R')
###############################################################
##other stuff you may be able to put into the 

circleFun <- function(center = c(0,0),diameter = .5, npoints = 100){
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
colorR   <- seq(0, 1, length.out = 500) ###new shit

stim1 <- data.frame(stim=seq(0.1, 1, length.out =10))
##adding the radomization
stim1 <- data.frame(stim=stim1[sample(nrow(stim1)),])
##second round of stimuli
stim2 <- data.frame(stim=seq(50,500, length.out = 10))
##adding the randomization
stim2 <- data.frame(stim=stim2[sample(nrow(stim2)),])


stim <- rbind(stim1,stim2)


##origin, diameter and points
cir <- circleFun(c(0,0),2,npoints = 500)
test <- cbind.data.frame(x, y, z,ycoor,zcoor, theta, cir, colorR)

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
      user_name <- nchar(input$user) > 0
      user_ok <- input$password==session_password
      
      # If credentials are valid push user into experiment
      if(user_ok && user_name){
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
    output$colorNum <- renderText(paste("Color Number", values$round))
    
    # output$bars <- renderImage({
    #   
    #   filename <- normalizePath(file.path('./www',                    paste('blue_bar_', values$round, '.png', sep='')))   
    #   list(src = filename)
    # }, deleteFile = FALSE)
    # 
    ##########################################################
    ########## PART IIIa: MAIN HANDLER #######################
    ##########################################################
    
    ## This is the main experiment handler
    # Observe the submit button, if clicked... FIRE
    
    observeEvent(input$submit, {
    if(input$slide==0){
      shinyjs::show("slide_error")
    }
   else {
     shinyjs::hide("slide_error")
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
        
        
        ##saveData(values$df)
        
        # Say good-bye
        hide(id = "form")
        show(id = "instructions2")
      }
   }
    })
    
    observeEvent(input$confirm2, {
      hide("instructions2")
      show("ends")
    })
    
    
    
    ########################################################all crap
    
    output$num2 <- renderText(paste("Question", values$round))
    output$colorNum2 <- renderText(paste("Density Plot", values$round))
    
    observeEvent(input$submit2, {
      if(input$slide2==.1){
        shinyjs::show("slide_error")
      }
      else {
        shinyjs::hide("slide_error")
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
        
        updateSliderInput(session, "slide2", value = .1,
                          min =.1, max = 1)
        
        
        # Has the user reached the end of the experiment?
        # If so then...
        if(values$round > n_guesses2){
          
          
          saveData(values$df)
          
          # Say good-bye
          hide(id = "ends")
          show(id = "end")
        }
      }
    })
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ############################################################################
    
    
    ## Utilities & functions
    
    # I take formData from Dean with minor changes.
    # When it is called, it creates a vector of data.
    # This will be a row added to values$df - one for each round.
    #
    # notice that you also need to subtract 1 for the stimulus value as well 
    # otherwise they will be off by 1 row
    # Gather all the form inputs (and add timestamp)
    #
    formData <- reactive({
      data <- sapply(fieldsAll, function(x) input[[x]])
      data <- c(round = values$round-1, data, timestamp = humanTime(), stim=stim[values$round-1,1])
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
 
output$colPlot <- renderPlot({
  p <- ggplot(test, aes(ycoor,zcoor))
  p + coord_fixed(ratio = 1) + geom_polygon(aes(xx, yy), fill=hsv(1,stim[values$round,1],1)) + scale_x_continuous(name="", breaks=NULL) +
    scale_y_continuous(name="", breaks=NULL) + theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      panel.background = element_rect("white"))
    })



########################### round 2 of the stimuli

output$distPlot2 <- renderPlot({
  p <- ggplot(test, aes(ycoor,zcoor))
  p + geom_point(data=subset(test, x < stim[values$round,1]), size=4) + coord_fixed(ratio = 1) + geom_path(aes(xx, yy)) + scale_x_continuous(name="", breaks=NULL) +
    scale_y_continuous(name="", breaks=NULL) + theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank())
})

output$colPlot2 <- renderPlot({
  p <- ggplot(test, aes(ycoor,zcoor))
  p + coord_fixed(ratio = 1) + geom_polygon(aes(xx, yy), fill=hsv(1,input$slide2,1)) + scale_x_continuous(name="", breaks=NULL) +
    scale_y_continuous(name="", breaks=NULL) + theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      panel.background = element_rect("white"))
      })
  


output$refCOL <- renderPlot({
  p <- ggplot(test, aes(ycoor,zcoor))
  p + coord_fixed(ratio = 1) + geom_polygon(aes(xx, yy), fill=hsv(1,.55,1)) + scale_x_continuous(name="", breaks=NULL) +
    scale_y_continuous(name="", breaks=NULL) + theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      panel.background = element_rect("white"))
})

output$refDist <- renderPlot({
  p <- ggplot(test, aes(ycoor,zcoor))
  p + geom_point(data=subset(test, x < 250), size=4) + coord_fixed(ratio = 1) + geom_path(aes(xx, yy)) + scale_x_continuous(name="", breaks=NULL) +
    scale_y_continuous(name="", breaks=NULL) + theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank())
})


output$refCOL2 <- renderPlot({
  p <- ggplot(test, aes(ycoor,zcoor))
  p + coord_fixed(ratio = 1) + geom_polygon(aes(xx, yy), fill=hsv(1,.55,1)) + scale_x_continuous(name="", breaks=NULL) +
    scale_y_continuous(name="", breaks=NULL) + theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      panel.background = element_rect("white"))
})

output$refDist2 <- renderPlot({
  p <- ggplot(test, aes(ycoor,zcoor))
  p + geom_point(data=subset(test, x < 250), size=4) + coord_fixed(ratio = 1) + geom_path(aes(xx, yy)) + scale_x_continuous(name="", breaks=NULL) +
    scale_y_continuous(name="", breaks=NULL) + theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank())
})
})





# This renders the table of choices made by a participant that is shown
# to them on the final screen

