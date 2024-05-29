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
library(httr)
library(jsonlite)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Database visualization"),
    # Tabs
    tabsetPanel(
      tabPanel("Data Table",
               mainPanel(
                 dataTableOutput("databaseTable")
               )
      ),
      tabPanel("Query with LLM",
               sidebarLayout(
                 sidebarPanel(
                   textInput("userQuestion", "Ask a question:", ""),
                   actionButton("submitQuestion", "Submit")
                 ),
                 mainPanel(
                   dataTableOutput("queryResult")
                 )
               )
      )
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
    # datatable(sample_data)
    datatable(sample_data, filter = "top")
  })

  onSessionEnded(function() {
    dbDisconnect(conn)
  })

  # Function to generate SQL query using Huggingface API
  generateSQLQuery <- function(question) {
    response <- POST(
      url = "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.3",
      add_headers(Authorization = paste("Bearer", Sys.getenv("HUGGINGFACE_API_KEY"))),
      body = toJSON(list(inputs = question)),
      encode = "json"
    )

    if (response$status_code == 200) {
      content <- fromJSON(content(response, "text", encoding = "UTF-8"))
      sql_query <- content$generated_text
      return(sql_query)
    } else {
      stop("Failed to generate SQL query from the Huggingface model.")
    }
  }

  # Observe event for the submit button
  observeEvent(input$submitQuestion, {
    question <- input$userQuestion

    # Generate the SQL query
    sql_query <- tryCatch({
      generateSQLQuery(question)
    }, error = function(e) {
      return(paste("Error:", e$message))
    })

    # Print the generated SQL query for debugging
    print(paste("Generated SQL query:", sql_query))

    # Execute the SQL query if it is valid
    query_result <- tryCatch({
      dbGetQuery(conn, sql_query)
    }, error = function(e) {
      data.frame(message = "Error executing query: ", error = e$message)
    })

    # Render the result
    output$queryResult <- renderDataTable({
      datatable(query_result)
    })
  })
}



# Run the application
shinyApp(ui = ui, server = server)
