Serial myPort;
IntDict sensorData;
FloatList ecgValues;
FloatList fsrValues;

String lineString = "";
Boolean startedReading = true;
int currentHeartRate = 60;
int restingHeartRate = 60;
int restingRespirationRate = -1;

float heartbeatDifferentialThreshold = 300.0;
int minIndicesUntilNextHeartBeat = 15;

Boolean DEBUG_MODE = false;

void setupData() {
    println(Serial.list());

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
  // Process data in ecg values by looking at the last 3 seconds (300 samples)
  // a rate of change of over 100 plus is detected
  // if a rate of change of over -100 is detected in the next 12 samples, with a total climb of over 300, then a drop of 300, we consider it a valid heartbeat, otherwise ignore it

  if (ecgValues.size() == 0) {
    println("No ECG values found, defaulting HR to 60");
    return 60;
  }
  
  float totalECGValuesInInterval = 0.0f;
  int numECGValuesInInterval = 0;
  
  for (int i = max(0, ecgValues.size() - 300); i < ecgValues.size(); ++i) {
    totalECGValuesInInterval += ecgValues.get(i);
    numECGValuesInInterval++;
  }
  
  float avg = totalECGValuesInInterval / numECGValuesInInterval;
  IntList indicesOfHeartBeats = new IntList();
  println("Average heart reading is " + avg);
  
  for (int i = max(0, ecgValues.size() - 300); i < ecgValues.size(); ++i) {
    if (ecgValues.get(i) - avg >= heartbeatDifferentialThreshold) {
      println("Heart beat at position " + i + " of " + ecgValues.get(i) + " is above threshold, skipping 150 ms");
      indicesOfHeartBeats.append(i);
      i += minIndicesUntilNextHeartBeat;
    }
  }
  
  int totalIndicesBetweenEachRWave = 0;
  int totalGapsBetweenRWaves = 0;
  
  if (indicesOfHeartBeats.size() < 2) {
    println("Guaranteed R Waves less than 2, defaulting HR to 60");
    return 60;
  }
  
  float lastVal = indicesOfHeartBeats.get(0);
  float currVal = 0.0f;
  for (int i = 1; i < indicesOfHeartBeats.size(); ++i) {
    currVal = indicesOfHeartBeats.get(i);
    println("Gap: " + (currVal - lastVal));
    totalIndicesBetweenEachRWave += (currVal - lastVal);
    lastVal = currVal;
    totalGapsBetweenRWaves++;
  }
  println("Avg samples between beats: " + ((float)totalIndicesBetweenEachRWave/(float)totalGapsBetweenRWaves));
  
  float secondsBetweenBeats = ((float)totalIndicesBetweenEachRWave/(float)totalGapsBetweenRWaves)/100.0f;
  
  println("Seconds between beats: " + secondsBetweenBeats);

  return (int)(60.0f / secondsBetweenBeats);
  
  
  //float lastReading = ecgValues.get(max(0, ecgValues.size() - 300));
  //float currReading = 0.0f;
  //float delta = 0.0f;
  //IntList indicesOfPotentialRWaveStarts = new IntList();
  //IntList offLimitsIndices = new IntList();
  //FloatList potentialRWaveStartsPreviousReadings = new FloatList();
  //IntList indicesOfGuaranteedRWaves = new IntList();
  //float startingValue, maxDiffFromStart;
  //boolean isValid = true;

  //int i, j, k, indDiff;

  //for (i = max(1, ecgValues.size() - 299); i < ecgValues.size(); ++i) {
  //  currReading = ecgValues.get(i);
  //  delta = currReading - lastReading;

  //  if (delta >= 50.0) {
  //    // potential r wave start
  //    indicesOfPotentialRWaveStarts.append(i);
  //    potentialRWaveStartsPreviousReadings.append(lastReading);
  //    println("Potential heart beat");
  //  } else if (delta <= -50.0) {
  //    for (j = 0; j < indicesOfPotentialRWaveStarts.size(); ++j) {
  //      indDiff = i - indicesOfPotentialRWaveStarts.get(j);
  //      if (indDiff > 6 && indDiff < 14) {
  //        // potential r wave end
  //        startingValue = potentialRWaveStartsPreviousReadings.get(j);
  //        maxDiffFromStart = 0.0f;
          
  //        isValid = true;
  //        for (k = indicesOfPotentialRWaveStarts.get(j); k < i; ++k) {
  //          if (offLimitsIndices.hasValue(k)) {
  //            isValid = false;
  //          }
  //          maxDiffFromStart = max(maxDiffFromStart, startingValue - ecgValues.get(k));
  //        }
  //        if (maxDiffFromStart >= 300.0f && isValid) {
  //          // We definitely found a peak
  //          for (k = indicesOfPotentialRWaveStarts.get(j); k < i; ++k) {
  //            offLimitsIndices.append(k);
  //          }
  //          indicesOfGuaranteedRWaves.append(j);
  //          indicesOfPotentialRWaveStarts.remove(j);
  //          potentialRWaveStartsPreviousReadings.remove(j);
  //        } else {
  //          indicesOfPotentialRWaveStarts.remove(j);
  //          potentialRWaveStartsPreviousReadings.remove(j);
  //          --j;
  //        }
  //      } else if (indDiff >= 14) {
  //        indicesOfPotentialRWaveStarts.remove(j);
  //        potentialRWaveStartsPreviousReadings.remove(j);
  //        --j;
  //      }
  //    }
  //  }

  //  lastReading = currReading;
  //}
  
  //if (indicesOfGuaranteedRWaves.size() < 2) {
  //  println("Guaranteed R Waves less than 2, defaulting HR to 60");
  //  return 60;
  //}
  
  //int totalIndicesBetweenEachRWave = 0;
  //int totalGapsBetweenRWaves = 0;
  //float lastVal = indicesOfGuaranteedRWaves.get(0);
  //float currVal = 0.0f;
  //for (i = 1; i < indicesOfGuaranteedRWaves.size(); ++i) {
  //  currVal = indicesOfGuaranteedRWaves.get(i);
  //  totalIndicesBetweenEachRWave += currVal - lastVal;
  //  totalGapsBetweenRWaves++;
  //}
  
  //float secondsBetweenBeats = ((float)totalIndicesBetweenEachRWave/(float)totalGapsBetweenRWaves)/100.0f;

  //return (int)(60.0f / secondsBetweenBeats);
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
      if (ecgValues.size()>=1) {
        ecgv = ecgValues.get(ecgValues.size()-1);
      }
    }
    else {
      ecgValues.append(ecgv);
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
  timeInEachZone[userZoneIdx]+=10;
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
