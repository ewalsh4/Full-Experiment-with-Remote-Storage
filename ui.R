library(shinyjs)

source('helpers.R')
shinyUI(fluidPage(
  
## some general notes, when building an experiment this way there are issues with calling the same shit in 
  ## different divs, i.e. you tried a fuckload of times to just do the same plots as before but then ran into issues
  ## until you created just duplicate plots for the reference instructions etc. 
  ## this might be an issue later on in the experiment 
  
  
## this is the section that gets rid of the extra elements in the slider such as the number counter over the top,
  tags$head(tags$style(HTML('.irs-from, .irs-to, .irs-min, .irs-max, .irs-single, .irs-grid-text {visibility: hidden !important;
                            }'))),
  useShinyjs(),
  div(
    id = "login_page",
    titlePanel("Welcome to the experiment!"),
    br(),
    sidebarLayout(
      
      sidebarPanel(
        h2("Login"),
        p("Welcome to today's experiment. Please enter the username and password that were provided in the qualtrics survey."),
        hidden(
          div(
            id = "login_error",
            span("Your user name or password is invalid. Please check for typos and try again.", style = "color:red")
          )
        )
      ),
      
      mainPanel(
        textInput("user", "User", ""),
        textInput("password", "Password", ""),
        actionButton("login", "Login", class = "btn-primary")
      )
    )
  ),
  
  hidden(
    div( id = "instructions",
         column(5, h3("Please read the instructions presented below"),
                br(),
         p("The survey will begin with a calibration exercise. You will be asked to match dot density to a series of red circles.  On the right, you will see an example of the red circle.  Use this red circle as your reference point."),
         br(),
         
         p("For each question, the circle will be either DARKER than the circle on this page or LIGHTER than the circle on this page."),
          p( "If the circle is DARKER than the one on this page, include MORE dots in the density plot."),  
          p("If the circle is LIGHTER than the one on this page, include FEWER dots in the density plot."),
         br(),
         actionButton("confirm", label = "Ok, I got it... let's start")
         ),
         
        column(7, 
               h3("REFERENCE COLOR:"),
               plotOutput("refCOL",width="100%", height="300px"),
               h3("SAMPLE DOT PLOT:"),
         plotOutput("refDist",width="100%", height="300px")
         
      
    )
  )
  ),
  
  
  hidden(
    div(
      id = "slide_error",
      span("Please use the slider to answer the question.", style = "color:red")
    )
  ),

  
  
  
  
  hidden(
    div(
      id = "form",
      ##titlePanel(textOutput("num")),
      fluidRow(
        column(5,
               h3(textOutput("num")),
               wellPanel(
                 tags$h5("If the red circle is DARKER than the reference image, include MORE dots in the circle below."),
                 
                 tags$h5("If the red circle is LIGHTER than the reference image, include FEWER dots in the circle below.
                       "),
                 sliderInput("slide", 
                             "Use the slider to set the number of dots in the plot to the color of the circle below.", 
                          ticks = T,
                             min = 0, 
                             max = 500, 
                             value = 0)
               ),
               actionButton("submit","submit")
              ## br(),
              ## plotOutput("colPlot", width="100%", height="300px")
               
        ),
    # Show a plot of the generated distribution
        column(7,
h3(textOutput("colorNum")),
                plotOutput("colPlot", width="100%", height="300px"),
h3("Your Response:"),
               plotOutput("distPlot", width="100%", height="300px")


               
               
               
               )
               )
  )),
  

  
  
  
  hidden(
    div(
      id = "end",
      titlePanel("Thank you!"),
      
      sidebarLayout(
        
        sidebarPanel(
          p("You have reached the end of the experiment. Thank you for your participation."),
          h4("Please return to Qualtrics"),
          textOutput("round")
        ),
        
        mainPanel(
          h4("Please return to the Qualtrics Survey and enter the code below: "),
          br(),
          h3("kj5jv39c", align= "center")
        )
      ))),
    
  
  hidden(
    div( id = "instructions2",
         fluidRow(
           column(5, 
                 
         h3("Now you will be asked to do the opposite"),
         br(),
         p("You will now control the color of the circle and be asked to match the color to a series of density plots.  On the right, you will see an example of the red circle.  Use this red circle as your reference point."),
         
         p("For each question, the plot will either be MORE dense or LESS dense than the plot on this page.  If the plot is MORE DENSE than the one on this page, make the red circle DARKER.  If the plot is LESS DENSE than the one on this page, make the red circle LIGHTER."),
         actionButton("confirm2", label = "Ok, I got it...")
         ),
         column(7,
                h3("REFERENCE DOT PLOT:"),
         plotOutput("refDist2",width="100%", height="300px"),
         h3("SAMPLE COLOR:"),
         plotOutput("refCOL2",width="100%", height="300px")
         
    )
           ))),
  
  hidden(
    div( id = "ends",
             ##titlePanel(textOutput("num2")), 
             fluidRow(
               column(5,
                      h3(textOutput("num2")),
                      wellPanel(tags$h5("Match the color of the red circle to the density of the dot plot.
                              "),
                                tags$h5("If the dots are MORE dense than the reference image, make the red circle DARKER."),
                                
                                tags$h5("If the dots are LESS dense than the reference image, make the red circle LIGHTER.
                                        "),
                        sliderInput("slide2",
                                    "Use the slider to set the color of the red plot to the density of the dot plot.",
                                    ticks = T,
                                    min = .1,
                                    max = 1,
                                    value = .1,
                                    step = .002)
                      ),
                      actionButton("submit2","submit")
#                       br(),
#                       plotOutput("colPlot2", width="100%", height="300px")

               ),



               # Show a plot of the generated distribution
               column(7,
#                       tags$h5("Match the color of the red circle to the density of the dot plot.
#                               "),
#                       tags$h5("If the dots are MORE dense than the reference image, make the red circle DARKER."),
# 
#                       tags$h5("If the dots are LESS dense than the reference image, make the red circle LIGHTER.
#                               "),
                      ##imageOutput("bars", width="100%", height="100%"),
#                       br(),
# 
# 
#                       tags$h5("Set the color of the red circle:
#                               "),
h3(textOutput("colorNum2")),
                      plotOutput("distPlot2",width="100%", height="300px"),
h3("Your Response:"),
plotOutput("colPlot2", width="100%", height="300px")
                      )
               )
           ))
    )
  )

