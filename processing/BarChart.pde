BarChart barChart;

float maxTimeInEachZone = 0;
void setupBarChart(){  
  barChart = new BarChart(this);
     
  // Scaling
  barChart.setMinValue(0);
   
  // textFont(createFont("Arial Bold",10),10);
   
  barChart.showValueAxis(false);
  barChart.setData(timeInEachZone);
  barChart.setBarLabels(new String[] {"Very Light", "Light", "Moderate", "Hard", "Maximum"});
  barChart.showCategoryAxis(true);
  barChart.setBarColour(color(200,80,80,150));
  barChart.setBarGap(4);
  barChart.transposeAxes(true);
}

void drawBarChart(){
    float posX = 0.1*width, posY = .25*height, sizeX = .3 * width, sizeY = .3*height; 
    float rectX = .5*posX, rectY=.8*posY, rectSizeX=1.25*sizeX, rectSizeY=1.25*sizeY;
    
    if(!startedReading){return;}
    textSize(20);
    fill(255,255,255);
    rect(rectX, rectY, rectSizeX, rectSizeY,20);
    
    barChart.setMaxValue(maxTimeInEachZone);
    barChart.draw(posX, posY, sizeX, sizeY);
    
    String title = " Cardio Monitor";
    fill(32, 92, 122);
    textSize(25);
    text(title, rectX+(rectSizeX/2), rectY + (.075*rectSizeY));

}
