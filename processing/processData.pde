Serial myPort;
IntDict sensorData;
FloatList ecgValues;
FloatList fsrValues;

String lineString = "";
Boolean startedReading = true;
int currentHeartRate = 60;
int currentRespiratoryRate = 50;
int restingHeartRate = 60;
int restingRespiratoryRate = 50;
float respiratoryToleranceMin = 50.0f;

int[] respiratoryRateZoneTotals = { 50, 50, 50, 50, 50 };
int[] respiratoryRateZoneSamples = { 1, 1, 1, 1, 1 };

float heartbeatDifferentialThreshold = 300.0;
int minIndicesUntilNextHeartBeat = 15;

Boolean DEBUG_MODE = false;

int lastInhaleStartTime = -1;
int lastExhaleStartTime = -1;

boolean isInhaling = false;
boolean isExhaling = false;

float inhalationDuration = 0;
float exhalationDuration = 0;

float previousFSRReading = 0;
int threshold = 10;

void setupData() {
  DEBUG_MODE = Serial.list().length <= 0;

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

int getRespiratoryRate() {
  try {
    if (fsrValues.size() == 0) {
      return currentRespiratoryRate;
    }
    
    float prevReading = fsrValues.get(max(0, fsrValues.size() - 500));
    IntList indicesOfBreaths = new IntList();
    for (int i = max(1, fsrValues.size() - 499); i < fsrValues.size(); ++i) {
      float currReading = fsrValues.get(i);
      if (prevReading <= respiratoryToleranceMin && currReading >= respiratoryToleranceMin) {
        indicesOfBreaths.append(i);
      }
      prevReading = currReading;
    }
    
    int totalIndicesBetweenEachBreath = 0;
    int totalGapsBetweenBreaths = 0;

    if (indicesOfBreaths.size() < 2) {
      return currentRespiratoryRate;
    }

    float lastVal = indicesOfBreaths.get(0);
    float currVal = 0.0f;
    for (int i = 1; i < indicesOfBreaths.size(); ++i) {
      currVal = indicesOfBreaths.get(i);
      totalIndicesBetweenEachBreath += (currVal - lastVal);
      lastVal = currVal;
      totalGapsBetweenBreaths++;
    }

    float secondsBetweenBreaths = ((float)totalIndicesBetweenEachBreath/(float)totalGapsBetweenBreaths)/100.0f;

    return (int)(60.0f / secondsBetweenBreaths);
  } catch (Exception e) {
    return currentRespiratoryRate;
  }
}

int getHeartRate() {
  try {
    // Process data in ecg values by looking at the last 3 seconds (300 samples)
    // a rate of change of over 100 plus is detected
    // if a rate of change of over -100 is detected in the next 12 samples, with a total climb of over 300, then a drop of 300, we consider it a valid heartbeat, otherwise ignore it

    if (ecgValues.size() == 0) {
      return currentHeartRate;
    }

    float totalECGValuesInInterval = 0.0f;
    int numECGValuesInInterval = 0;

    for (int i = max(0, ecgValues.size() - 300); i < ecgValues.size(); ++i) {
      totalECGValuesInInterval += ecgValues.get(i);
      numECGValuesInInterval++;
    }

    float avg = totalECGValuesInInterval / numECGValuesInInterval;
    IntList indicesOfHeartBeats = new IntList();

    for (int i = max(0, ecgValues.size() - 300); i < ecgValues.size(); ++i) {
      if (ecgValues.get(i) - avg >= heartbeatDifferentialThreshold) {
        indicesOfHeartBeats.append(i);
        i += minIndicesUntilNextHeartBeat;
      }
    }

    int totalIndicesBetweenEachRWave = 0;
    int totalGapsBetweenRWaves = 0;

    if (indicesOfHeartBeats.size() < 2) {
      return currentHeartRate;
    }

    float lastVal = indicesOfHeartBeats.get(0);
    float currVal = 0.0f;
    for (int i = 1; i < indicesOfHeartBeats.size(); ++i) {
      currVal = indicesOfHeartBeats.get(i);
      totalIndicesBetweenEachRWave += (currVal - lastVal);
      lastVal = currVal;
      totalGapsBetweenRWaves++;
    }

    float secondsBetweenBeats = ((float)totalIndicesBetweenEachRWave/(float)totalGapsBetweenRWaves)/100.0f;

    if (DEBUG_MODE) {
      return (int)(60.0f / secondsBetweenBeats) / 3;
    } else {
      return (int)(60.0f / secondsBetweenBeats);
    }
  }
  catch (Exception e) {
    return currentHeartRate;
  }
}

float getECGReading() {
  float ecgv = -1;

  if (DEBUG_MODE) {
    ecgv = (int)random(0, maxECGReading);

    ecgv = constrain(random(1023), 0, maxFSRReading);
    ecgValues.append(ecgv);
  } else if (sensorData.hasKey("ECG")) {
    ecgv = sensorData.get("ECG");

    // if we lose the heart rate, use the previous cached value, if it exists
    if (ecgv <= 0) {
      if (ecgValues.size()>=1) {
        ecgv = ecgValues.get(ecgValues.size()-1);
      }
    } else {
      ecgValues.append(ecgv);
    }
  }

  return ecgv;
}

boolean isMidBreath = false;
float getFSRReading() {
  float fsrv = -1;

  if (DEBUG_MODE) {
    int v = (int)random(0, 100);
    if (v == 0) {
      isMidBreath = !isMidBreath;
    }

    if (isMidBreath) {
      fsrv = (int)random(0, maxFSRReading);
    } else {
      fsrv = 0;
    }
    fsrValues.append(fsrv);
  } else if (sensorData.hasKey("FSR")) {
    fsrv = sensorData.get("FSR");

    // if we lose the heart rate, use the previous cached value, if it exists
    if (fsrv <= 0) {
      if (fsrValues.size()>=1) {
        fsrv = fsrValues.get(fsrValues.size()-1);
      }
    } else {
      fsrValues.append(fsrv);
    }
  }

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

  //println("Current zone: ", currentZone, heartRatePercent);
  timeInEachZone[userZoneIdx]+=10;
  respiratoryRateZoneSamples[userZoneIdx] += 1;
  respiratoryRateZoneTotals[userZoneIdx] += currentRespiratoryRate;
  
  maxTimeInEachZone = max(timeInEachZone[userZoneIdx], maxTimeInEachZone);
}

void dataLoop() {
  if (!DEBUG_MODE) {
    readSerial();
  }

  //println();
  currentHeartRate = getHeartRate();
  currentRespiratoryRate = getRespiratoryRate();
  updateTimeInZone();

  float currentFSRReading = getFSRReading();
  float fsrDelta = currentFSRReading - previousFSRReading;

  if (fsrDelta > threshold && !isInhaling) {
    isInhaling = true;
    isExhaling = false;
    lastInhaleStartTime = millis();
    if (lastExhaleStartTime != -1) {
      exhalationDuration = (lastInhaleStartTime - lastExhaleStartTime) / 1000.0;
    }
  }

  if (fsrDelta < -threshold && !isExhaling) {
    isExhaling = true;
    isInhaling = false;
    lastExhaleStartTime = millis();
    if (lastInhaleStartTime != -1) {
      inhalationDuration = (lastExhaleStartTime - lastInhaleStartTime) / 1000.0;
    }
  }

  previousFSRReading = currentFSRReading;
}
