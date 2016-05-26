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
            span("Your user name is invalid. Please check for typos and try again.", style = "color:red")
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
         p("This panel will show the reference bar, the reference circle and the instructions for the respondents"),
         actionButton("confirm", label = "Ok, I got it... let's start")
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
                             "Use the slider to set the number of dots in the plot to the length of the bar.", 
                             ticks = F,
                             min = 1, 
                             max = 500, 
                             value = 0)
               ),
               actionButton("submit","submit")
        ),
        
        
        # Show a plot of the generated distribution
        column(7,
               tags$h5("If the bar below is LONGER than the reference bar, include MORE dots in the circle.
                       "),
               tags$h5("If the bar below is SHORTER than the reference bar, include FEWER dots in the circle.
                       "),
               imageOutput("bars", width="100%", height="100%"),
               br(),
               
               
               tags$h5("Set the number of dots in the circle:
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
      )
    )
  )
  )
)
