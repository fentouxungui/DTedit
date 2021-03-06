##### Minimal DTedit example using reactive dataframe #####
library(shiny)
library(DTedit)

##### Create the Shiny server #####
server <- function(input, output) {

  data <- reactiveVal() # # 'data' will be a 'reactive' dataframe
  data(data.frame(Column1 = c("Apple", "Cherry", "Frozen"),
                  Column2 = c("Pie", "Tart", "Yoghurt"),
                  stringsAsFactors = FALSE))
  data_DT_gui <- dtedit(
    input, output,
    'dataspace',
    thedata = data,
    edit.cols = c("Column1", "Column2")
  )

  observe({
    data(isolate(as.data.frame(data_DT_gui$thedata, stringsasfactors = FALSE)))
    print(isolate(data()))
    print(paste("Edit count:", data_DT_gui$edit.count))
    # only reacts to change in $edit.count
  })

  observeEvent(input$data_scramble, {
    print("Scrambling...")
    temp <- data()
    if (nrow(temp)>0) {
      row <- sample(seq_len(nrow(temp)), 1)  # row
      col <- sample(1:2, 1)           # column
      temp[row, col] <- paste(sample(unlist(strsplit(temp[row, col], "")),
                                     nchar(temp[row, col])),
                              sep = '', collapse = '')
      data(temp) # adjusted dataframe 'automatically' read by DTedit
    }
  })

  output$items <- shiny::renderUI({
    shiny::tags$html(
      "Column 1: ",
      paste(data()$Column1, collapse = ", "),
      shiny::br(), shiny::br(),
      "Column 2: ",
      paste(data()$Column2, collapse = ", ")
    )
  })

  data_list <- list() # exported list for shinytest
  shiny::observeEvent(data_DT_gui$thedata, {
    data_list[[length(data_list) + 1]] <<- data_DT_gui$thedata
  })
  shiny::exportTestValues(data_list = {data_list})
}

##### Create the shiny UI ######
ui <- fluidPage(
  h3("DTedit using reactive dataframe"),
  wellPanel(p("Try the 'Scramble' button!")),
  uiOutput("dataspace"),
  actionButton("data_scramble", "Scramble an entry"),
  shiny::br(), shiny::br(),
  uiOutput("items")
)

if (interactive() || isTRUE(getOption("shiny.testmode")))
  shinyApp(ui = ui, server = server)
