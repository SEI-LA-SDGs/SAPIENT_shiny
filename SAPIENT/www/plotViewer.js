Shiny.addCustomMessageHandler("updatePlots", function(plotsData) {
    renderPlots(plotsData);
  });
  
  function renderPlots(plotsData) {
    var plotPanel = $('#plot-panel');
  
    // Clear existing plots
    plotPanel.empty();
  
    // Append new plots
    plotsData.forEach(function (plot) {
      var plotContainer = $('<div>').addClass('plot-container');
      var img = $('<img>').addClass('plot').attr('src', plot.src).attr('alt', plot.alt);
      plotContainer.append(img);
      plotPanel.append(plotContainer);
    });
  }