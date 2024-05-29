#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DBI)
library(RSQLite)
library(DT)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Database visualization"),


        # Show a plot of the generated distribution
        mainPanel(
           dataTableOutput("databaseTable")
        )
)

server <- function(input, output, session) {

  # Print the current working directory for debugging
  print(paste("Current working directory:", getwd()))

  # Use absolute path for the database file
  db_path <- file.path(getwd(), "samples.db")
  print(paste("Database path:", db_path))

  # Connect to the SQLite database
  conn <- dbConnect(RSQLite::SQLite(), db_path)


  # Print tables for debugging
  print("Tables in the database:")
  print(dbListTables(conn))

  # Fetch data
  tables <- dbListTables(conn)
  if ("samples" %in% tables) {
    sample_data <- dbGetQuery(conn, "SELECT * FROM samples")
    print("Data fetched from 'samples' table:")
    print(sample_data)
  } else {
    sample_data <- data.frame(
      message = "Table 'samples' does not exist."
    )
  }

  output$databaseTable <- renderDataTable({
    datatable(sample_data)
  })

  onSessionEnded(function() {
    dbDisconnect(conn)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
