#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define server logic required to draw a histogram
function(input, output, session) {
    transform_documentsTable <- function(dtable) {
        sPDFs <- dtable[,1:2]
        sPDFs$size <- paste0(round(sPDFs$size / 1000000, digits = 2), " Mb")
        
        colnames(sPDFs) <- c("Name", "Size")
        
        return(sPDFs)
    }
    
    ###
    plotData <- list(
        ggplot() + geom_line(aes(1:10, 1:10)) + ggtitle("A"),
        ggplot() + geom_line(aes(1:10, 11:20)) + ggtitle("B"),
        ggplot() + geom_line(aes(1:10, 21:30)) + ggtitle("C")
    )
    
    plotNames <- list(
        "PlotA.png",
        "PlotB.png",
        "PlotC.png"
    )
    
    currentPlotIndex <- reactiveVal(1)
    
    # Function to handle next and previous button clicks
    observeEvent(input$nextPlotBtn, {
        currentPlotIndex((currentPlotIndex() %% length(plotData)) + 1)
    })
    
    observeEvent(input$prevPlotBtn, {
        currentPlotIndex(ifelse(currentPlotIndex() == 1, 
                                length(plotData), 
                                currentPlotIndex() - 1))
    })
    
    observeEvent(input$downloadPlotsBtn, {
        folder <- utils::choose.dir()
        if(length(folder) != 0) { # if not cancelled
            ggsave(file.path(folder, "PlotA.png"), 
                   plot = plotData[[1]])
            ggsave(file.path(folder, "PlotB.png"), 
                   plot = plotData[[2]])
            ggsave(file.path(folder, "PlotC.png"), 
                   plot = plotData[[3]])
        }
    })
    
    # Render the plot
    output$plotOutput <- renderPlot({
        plotData[[currentPlotIndex()]]
    })
    ####
    
    output$documentsTable <- renderTable({
        if(!is.null(input$PDFs)) return(transform_documentsTable(input$PDFs))
        },
        width = "100%")
    
    output$extractedTexts <- renderTable({
        if((input$startMapping > 0) & (!is.null(input$PDFs))) {
            return(
                tidify(extract(input$PDFs[,4], input$PDFs[,1])))
            }
        },
        width = "90%")
  
    # output$distPlot <- renderPlot({
    # 
    #     # generate bins based on input$bins from ui.R
    #     x    <- faithful[, 2]
    #     bins <- seq(min(x), max(x), length.out = input$bins + 1)
    # 
    #     # draw the histogram with the specified number of bins
    #     hist(x, breaks = bins, col = 'darkgray', border = 'white',
    #          xlab = 'Waiting time to next eruption (in mins)',
    #          main = 'Histogram of waiting times')
    # 
    # })
    

}
