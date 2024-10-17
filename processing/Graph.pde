XYChart ecgChart;
FloatList ecgChartX;
FloatList ecgChartY;

XYChart respirationChart;
FloatList respirationChartX;
FloatList respirationChartY;
int MAX_VALUES = 100;
float x = 0;
int y = 0;

float beatStartTime = -99999;

void setupGraph() {
  ecgChart = new XYChart(this);
  ecgChartX = new FloatList();
  ecgChartY = new FloatList();

  respirationChart = new XYChart(this);
  respirationChartX = new FloatList();
  respirationChartY = new FloatList();

  ecgChart.showXAxis(true);
  ecgChart.showYAxis(true);
  ecgChart.setMaxY(maxECGReading);
  ecgChart.setMinY(0);
  ecgChart.setMinX(x);
  ecgChart.setXAxisLabel("time (s)");
  ecgChart.setYAxisLabel("signal strength (V)");

  respirationChart.showXAxis(true);
  respirationChart.showYAxis(true);
  respirationChart.setMaxY(maxFSRReading);
  respirationChart.setMinY(0);
  respirationChart.setMinX(x);
  respirationChart.setXAxisLabel("time (s)");
  respirationChart.setYAxisLabel("sensor force (g)");

  // Symbol colors
  ecgChart.setPointSize(5);
  ecgChart.setLineWidth(2);
  ecgChart.setPointColour(color(255, 0, 0));
  ecgChart.setLineColour(color(255, 0, 0));

  respirationChart.setPointSize(5);
  respirationChart.setLineWidth(2);
  respirationChart.setPointColour(color(0, 0, 0));
  respirationChart.setLineColour(color(0, 0, 0));
}

void drawRespiration() {
  float posX = 0.50*width, posY = .22*height, sizeX = .45 * width, sizeY = .3*height;
  float rectX = .95*posX, rectY=.9*posY, rectSizeX = sizeX + 40, rectSizeY=sizeY+60;

  fill(255, 255, 255);
  rect(rectX, rectY, rectSizeX, rectSizeY, 20);

  String title2 = "Respiration Monitor";
  fill(32, 92, 122);
  textSize(25);
  textAlign(CENTER, CENTER);
  text(title2, .725*width, .225 * height);
  textSize(12);
  respirationChart.draw(posX, posY, sizeX, sizeY);
}

void drawECG() {
  float posX = 0.10*width, posY = .65*height, sizeX = .875 * width, sizeY = .3*height;
  float rectX = .5*posX, rectY=.9*posY, rectSizeX = sizeX + 40, rectSizeY=sizeY+80;

  fill(255, 255, 255);
  rect(rectX, rectY, rectSizeX, rectSizeY, 20);

  String title1 = "ECG Monitor";
  fill(32, 92, 122);
  textSize(25);
  textAlign(CENTER, CENTER);
  text(title1, width / 5, .625 * height);
  textSize(12);
  ecgChart.draw(posX, posY, sizeX, sizeY);
}

float currMaxFSRSample = 0.0f;

void findCurrMaxFSRSample() {
  currMaxFSRSample = 0.0f;
  for (int i = 0; i < respirationChartY.size(); ++i) {
    currMaxFSRSample = max(currMaxFSRSample, respirationChartY.get(i));
  }
}

void drawGraph() {
  if (timer.isRunning) {
    float ecgReading = getECGReading();
    float fsrReading = getFSRReading();

    // println(fsrReading);
    if(fsrReading == 0){
      float timeBetween = millis()-beatStartTime;
      println("Time between: " + timeBetween/1000.0);
      beatStartTime = millis();
    }

    //float heartRatePercent = (heartRate/maxHeartRate)*100;
    //int userZoneIdx = getUserZone(heartRatePercent);

    x+=1;

    ecgChartY.append(ecgReading);
    ecgChartX.append(x/100.0);

    if (ecgChartX.size() > MAX_VALUES) {
      ecgChartY.remove(0);
      ecgChartX.remove(0);
    }

    respirationChartY.append(fsrReading);
    respirationChartX.append(x/100.0);

    if (respirationChartX.size() > MAX_VALUES) {
      respirationChartY.remove(0);
      respirationChartX.remove(0);
    }

    //color chosenColor = color(255,255,255);

    //if (userZoneIdx != -1){
    //    chosenColor = zoneColors[userZoneIdx];
    //}

    //ecgChart.setPointColour(chosenColor);
    //ecgChart.setLineColour(chosenColor);

    ecgChart.setData(ecgChartX.toArray(), ecgChartY.toArray());
    respirationChart.setData(respirationChartX.toArray(), respirationChartY.toArray());
  }

  ecgChart.setMinX(max((x-MAX_VALUES+1) / 100.0, 0));
  ecgChart.setMaxX(max(x/100.0, MAX_VALUES/100.0));

  respirationChart.setMinX(max((x-MAX_VALUES+1) / 100.0, 0));
  respirationChart.setMaxX(max(x/100.0, MAX_VALUES/100.0));
  
  findCurrMaxFSRSample();
  respirationChart.setMaxY(max(250.0, currMaxFSRSample));

  textSize(20);

  drawECG();
  drawRespiration();
}
