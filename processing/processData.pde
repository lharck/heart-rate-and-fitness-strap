Serial myPort;
IntDict sensorData;
FloatList ecgValues;
FloatList fsrValues;

String lineString = "";
Boolean startedReading = true;
int currentHeartRate = 60;
int restingHeartRate = 60;

Boolean DEBUG_MODE = false;

void setupData() {
  if (!DEBUG_MODE) {
    String whichPort = Serial.list()[0];
    myPort = new Serial(this, whichPort, 115200);
  }

  sensorData = new IntDict();
  ecgValues = new FloatList();
  fsrValues = new FloatList();
}

void parseLine() {
  lineString = lineString.trim();

  if (lineString.equals("x")) {
    if (!startedReading) {
      startedReading = true;
      println("*******started reading sensor data*****");
    }
  } else {
    if (startedReading) {
      //println(lineString);
      int spaceIdx = lineString.indexOf(" ");
      if (spaceIdx < 0) {
        return;
      }
      String property = lineString.substring(0, spaceIdx-1);
      int value = int(lineString.substring(spaceIdx+1, lineString.length()));
      sensorData.set(property, value);
    }
  }
}

void readSerial() {
  while (myPort.available() > 0) {
    int byteRead = myPort.read();

    if (char(byteRead) == '\n') {
      parseLine();
      lineString = "";
    } else {
      lineString += (char(byteRead));
    }
  }
}

//float getAverageHeartRate() {
  //float sumOfValues = 0;
  //float valuesUsed = 0;

  //for(int i = max(0, heartRateValues.size() - 5); i < heartRateValues.size(); i++)
  //{
  //    float hrVal = heartRateValues.get(i);
  //    sumOfValues += hrVal;
  //    valuesUsed++;
  //}
  //return sumOfValues/valuesUsed;
  //return 60;
//}

int getHeartRate() {
  // Process data in evg values by looking at the last 3 seconds (300 samples)
  // a rate of change of over 100 plus is detected
  // if a rate of change of over -100 is detected in the next 12 samples, with a total climb of over 300, then a drop of 300, we consider it a valid heartbeat, otherwise ignore it
  return 60;
}

float getECGReading() {
  float ecgv = -1;

  if (DEBUG_MODE) {
    ecgv = (int)random(0, maxECGReading);

    if (ecgValues.size() >= 1) {
      ecgv = ecgValues.get(ecgValues.size()-1);
    }

    int sign = (int(random(2)) == 0) ? -1 : 1;
    ecgv += (sign*random(1, 2));
    ecgv = constrain(ecgv, 0, maxECGReading);
  } else if (sensorData.hasKey("ECG")) {
    ecgv = sensorData.get("ECG");

    // if we lose the heart rate, use the previous cached value, if it exists
    if (ecgv <= 0) {
      if (ecgValues.size()>=1)
        ecgv = ecgValues.get(ecgValues.size()-1);
    }
  }

  //println("Current heartrate: ", (int)hrv);
  return ecgv;
}

float getFSRReading() {
  float fsrv = -1;

  if (DEBUG_MODE) {
    fsrv = (int)random(0, maxFSRReading);

    if (fsrValues.size() >= 1) {
      fsrv = fsrValues.get(fsrValues.size()-1);
    }

    int sign = (int(random(2)) == 0) ? -1 : 1;
    fsrv += (sign*random(1, 2));
    fsrv = constrain(fsrv, 0, maxFSRReading);
  } else if (sensorData.hasKey("FSR")) {
    fsrv = sensorData.get("FSR");

    // if we lose the heart rate, use the previous cached value, if it exists
    if (fsrv <= 0) {
      if (fsrValues.size()>=1)
        fsrv = fsrValues.get(fsrValues.size()-1);
    }
  }

  //println("Current heartrate: ", (int)hrv);
  return fsrv;
}


void restartData() {
  for (int i = 0; i < 5; i++) {
    timeInEachZone[i] = 0;
  }


  respirationChartX.clear();
  respirationChartY.clear();
  
  ecgChartX.clear();
  ecgChartY.clear();
  
  x = 0;
  y = 0;
}

void updateTimeInZone() {
  if (!timer.isRunning) {
    return;
  }

  float heartRatePercent = (currentHeartRate/maxHeartRate)*100;
  int userZoneIdx = getUserZone(heartRatePercent);
  String currentZone = zoneNames[userZoneIdx];

  //println("Current zone: ", currentZone, heartRatePercent);
  timeInEachZone[userZoneIdx]+=1;
  maxTimeInEachZone = max(timeInEachZone[userZoneIdx], maxTimeInEachZone);
}

//void updateAvgHeartRate() {
//  float heartrate = getHeartRate();
//  heartRateValues.append(heartrate);
//  avgHeartRate = (int)(getAverageHeartRate());
//  //println("Average heartrate: ", avgHeartRate);
//}

void dataLoop() {
  if (!DEBUG_MODE) {
    readSerial();
  }

  //println();
  currentHeartRate = getHeartRate();
  updateTimeInZone();
}
