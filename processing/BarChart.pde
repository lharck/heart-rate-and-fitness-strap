BarChart barChart;

float maxTimeInEachZone = 0;
void setupBarChart(){  
  barChart = new BarChart(this);
     
  // Scaling
  barChart.setMinValue(0);
   
  // Axis appearance
  //textFont(createFont("Serif",10),10);
   
  barChart.showValueAxis(false);
  barChart.setData(timeInEachZone);
  barChart.setBarLabels(new String[] {"Very Light", "Light", "Moderate", "Hard", "Maximum"});
  barChart.showCategoryAxis(true);
  barChart.setBarColour(color(200,80,80,150));
  barChart.setBarGap(4);
  barChart.transposeAxes(true);
}


void drawBarChart(){
    if(!startedReading){return;}
    textSize(20);

    barChart.setMaxValue(maxTimeInEachZone);
    barChart.draw(0.1*width, .15*height, .8 * width, .3*height);
}
