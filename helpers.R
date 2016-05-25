# which fields get saved
fieldsAll <- c("user", "guess","slide")
token <- readRDS("droptoken.rds")

# this sets the folder where all of the reponses get saved
responsesDir <- file.path("responses")

# Password to login for this session
session_password <- "foo"

## setting the beginning of the question iterator 
n_rounds <- 1

## setting the max number of rounds 
n_guesses <- 10

# add an asterisk to an input label
labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

# CSS to use in the app
appCSS <- ".mandatory_star { color: red; }
.shiny-input-container { margin-top: 25px; } 
.shiny-progress .progress-text {
font-size: 18px;
top: 50% !important;
left: 50% !important;
margin-top: -100px !important;
margin-left: -250px !important}"

# Helper functions
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

saveData <- function(data) {
  fileName <- sprintf("%s_%s.csv",
                      as.integer(Sys.time()),
                      digest::digest(data))
  
  filePath <- file.path(tempdir(), fileName)
  
  write.csv(data, filePath, row.names = FALSE, quote = TRUE)
  # Upload the file to Dropbox
  drop_upload(filePath, dest = responsesDir, dtoken= token)
}


epochTime <- function() {
  as.integer(Sys.time())
}