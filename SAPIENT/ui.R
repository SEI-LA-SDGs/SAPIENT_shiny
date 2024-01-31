#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


# Define UI for application that draws a histogram
fluidPage(
      htmlTemplate("tool.html",
                   btn_load_PDFs = fileInput("PDFs",
                                             label = "Select PDFs to analyse",
                                             multiple = TRUE,
                                             accept = ".pdf"),
                   PDFs_list = tableOutput("documentsTable"),
                   prevPlotBtn = actionButton(
                       "prevPlotBtn", 
                       "", 
                       icon = icon("fa-chevron-left", "fa-solid"),
                       class = "plotBtn"
                       ),
                   nextPlotBtn = actionButton(
                       "nextPlotBtn", 
                       "",
                       icon = icon("fa-chevron-right", "fa-solid"),
                       class = "plotBtn"
                   ),
                   downloadPlotsBtn = actionButton(
                       "downloadPlotsBtn",
                       "Download plots",
                       icon = icon("fa-download", "fa-solid"),
                       class = "download_plots_btn"
                   )
      )
    # # Application title
    # titlePanel("SAPIENT"),
    # 
    # # Sidebar with a slider input for number of bins
    # sidebarLayout(
    #     sidebarPanel(
    #         fileInput("PDFs",
    #                   label =  "Upload files",
    #                   multiple = TRUE,
    #                   accept = ".pdf"),
    #         
    #     ),
    #     
    #     
    #     mainPanel(
    #         tableOutput("documentsTable"),
    #         
    #         actionButton("startMapping", "Start mapping"),
    #         tableOutput("extractedTexts"),
    #         plotOutput("plotOutput"),
    #         fixedRow(actionButton("prevPlotBtn", "Previous Plot"),
    #                  actionButton("nextPlotBtn", "Next Plot"))
    #      
    #     )
    #     
    #     
    #     
    #     # # Show a plot of the generated distribution
    #     # mainPanel(
    #     #     plotOutput("distPlot")
    #     # )
    # )
)
