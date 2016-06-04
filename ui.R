library(shinyjs)

source('helpers.R')
shinyUI(fluidPage(
  
  
## this is the section that gets rid of the extra elements in the slider such as the number counter over the top,
  tags$head(tags$style(HTML('.irs-from, .irs-to, .irs-min, .irs-max, .irs-single {visibility: hidden !important;
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
         h3("Please read the instructions presented below"),
         p("This panel will show a sample of the color plot and a sample of the density plot. Respondents will be instructed to match the density plot to the color plot for the next 10 questions."),
         actionButton("confirm", label = "Ok, I got it... let's start")
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
      titlePanel(textOutput("num")),
      fluidRow(
        column(5,
               wellPanel(
                 sliderInput("slide", 
                             "Use the slider to set the number of dots in the plot to the color of the circle below.", 
                             ticks = F,
                             min = 1, 
                             max = 500, 
                             value = 0)
               ),
               actionButton("submit","submit"),
               br(),
               plotOutput("colPlot")
               
        ),
    # Show a plot of the generated distribution
        column(7,
               tags$h5("Match the density of the plot below to the color of the red circle.
                       "),
               tags$h5("If the red circle is DARKER than the reference image, include MORE dots in the circle below."),
               
               tags$h5("If the red circle is LIGHTER than the reference image, include FEWER dots in the circle below.
                       "),
               ##imageOutput("bars", width="100%", height="100%"),
               br(),
               
               
               tags$h5("Set the density of the dots in the circle:
                       "),
               plotOutput("distPlot") 
               
               
               
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
         h3("Now you will be asked to do the opposite"),
         p("This panel will show a sample of the color plot and a sample of the density plot. Respondents will be instructed to match the color plot to the density plot for the next 10 questions."),
         actionButton("confirm2", label = "Ok, I got it...")
    )
  ),
  
  hidden(
    div( id = "ends",
             titlePanel(textOutput("num2")), 
             fluidRow(
               column(5,
                      wellPanel(
                        sliderInput("slide2",
                                    "Use the slider to set the color of the red plot to the density of the dot plot.",
                                    ticks = F,
                                    min = 0,
                                    max = 1,
                                    value = .5,
                                    step = .002)
                      ),
                      actionButton("submit2","submit"),
                      br(),
                      plotOutput("colPlot2")

               ),



               # Show a plot of the generated distribution
               column(7,
                      tags$h5("Match the color of the red circle to the density of the dot plot.
                              "),
                      tags$h5("If the dots are MORE dense than the reference image, make the red circle DARKER."),

                      tags$h5("If the dots are LESS dense than the reference image, make the red circle LIGHTER.
                              "),
                      ##imageOutput("bars", width="100%", height="100%"),
                      br(),


                      tags$h5("Set the color of the red circle:
                              "),
                      plotOutput("distPlot2")
                      )
               )
           ))
    )
  )

