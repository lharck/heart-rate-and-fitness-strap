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

void drawGraph(){
    if(!startedReading){return;}
    
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
    lineChart.draw(0.05*width, .5*height, .9 * width, .45*height);
}
