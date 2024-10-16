XYChart lineChart;
FloatList lineChartX;
FloatList lineChartY;
int MAX_VALUES = 100;
float x = 0;
int y = 0;

void setupGraph(){
  lineChart = new XYChart(this);
  lineChartX = new FloatList();
  lineChartY = new FloatList();
  
  lineChart.showXAxis(true); 
  lineChart.showYAxis(true); 
  lineChart.setMaxY(maxHeartRate);
  lineChart.setMinY(0);
  lineChart.setMinX(x);
  lineChart.setXAxisLabel("time");
  lineChart.setYAxisLabel("heart rate");
     
  // Symbol colors
  lineChart.setPointSize(5);
  lineChart.setLineWidth(2);
}

void drawRespiration() {
    float posX = 0.50*width, posY = .22*height, sizeX = .45 * width, sizeY = .3*height; 
    float rectX = .95*posX, rectY=.9*posY, rectSizeX = sizeX + 40, rectSizeY=sizeY+60;
    
    fill(255,255,255);
    rect(rectX, rectY, rectSizeX, rectSizeY,20);
    
    String title2 = "Respiration Monitor";
    fill(32, 92, 122);
    textSize(30);
    textAlign(CENTER, CENTER);
    text(title2, .725*width, .225 * height);
    
    lineChart.draw(posX, posY, sizeX, sizeY);
}

void drawECG(){
    float posX = 0.05*width, posY = .65*height, sizeX = .9 * width, sizeY = .3*height; 
    float rectX = .5*posX, rectY=.9*posY, rectSizeX = sizeX + 40, rectSizeY=sizeY+80;
    
    fill(255,255,255);
    rect(rectX, rectY, rectSizeX, rectSizeY,20);
    
    lineChart.draw(posX, posY, sizeX, sizeY);
  
    String title1 = "ECG Monitor";
    fill(32, 92, 122);
    textSize(30);
    textAlign(CENTER, CENTER);
    text(title1, width / 5, .625 * height);
}

void drawGraph(){    
    if(timer.isRunning) {
        int heartRate = getHeartRate();
        float heartRatePercent = (heartRate/maxHeartRate)*100;
        int userZoneIdx = getUserZone(heartRatePercent);
    
        x+=1;
        
        lineChartY.append(heartRate);
        lineChartX.append(x);
        
        if(lineChartY.size() > MAX_VALUES){
            lineChartY.remove(0);
            lineChartX.remove(0);
        }
        
         color chosenColor = color(255,255,255);
    
        if (userZoneIdx != -1){
            chosenColor = zoneColors[userZoneIdx];
        }
        
        lineChart.setPointColour(chosenColor);
        lineChart.setLineColour(chosenColor);

        lineChart.setData(lineChartX.toArray(), lineChartY.toArray());
    }
        
    lineChart.setMinX(max(x-MAX_VALUES+1, 0));
    lineChart.setMaxX(max(x, MAX_VALUES));
    
    textSize(20);
    
    drawECG();
    drawRespiration();
}
