Serial myPort;
IntDict sensorData;
FloatList heartRateValues;

String lineString = "";
int avgHeartRate = -1;
int restingHeartRate = -1;
Boolean startedReading = true;

Boolean DEBUG_MODE = true;

void setupData(){
    if(!DEBUG_MODE){
        String whichPort = Serial.list()[0];
        myPort = new Serial(this, whichPort, 115200);
    }
    
    sensorData = new IntDict();    
    heartRateValues = new FloatList();
}

void parseLine(){
    lineString = lineString.trim();
              
    if(lineString.equals("x")) {
        if(!startedReading){
           startedReading = true;
           println("*******started reading sensor data*****");
        }
    } 
    else {
        if(startedReading){
            //println(lineString);
            int spaceIdx = lineString.indexOf(" ");
            if(spaceIdx < 0){return;}
            String property = lineString.substring(0,spaceIdx-1);
            int value = int(lineString.substring(spaceIdx+1, lineString.length()));
            sensorData.set(property, value);
        }
    }
}

void readSerial(){    
    while (myPort.available() > 0) {
        int byteRead = myPort.read();
          
        if (char(byteRead) == '\n') {
            parseLine();
            lineString = ""; 
        } 
        else {
            lineString += (char(byteRead)); 
        }
    }
}

float getAverageHeartRate(){
    float sumOfValues = 0;
    float valuesUsed = 0;
    
    for(int i = max(0, heartRateValues.size() - 5); i < heartRateValues.size(); i++)
    {
        float hrVal = heartRateValues.get(i);
        sumOfValues += hrVal;
        valuesUsed++;
    }
    return sumOfValues/valuesUsed;    
}

int getHeartRate(){
    float hrv = -1;
    
    if(DEBUG_MODE){
        hrv = (int)random(100,maxHeartRate); 

        if (heartRateValues.size() >= 1){
            hrv = heartRateValues.get(heartRateValues.size()-1);
        }
       
       int sign = (int(random(2)) == 0) ? -1 : 1;
       hrv += (sign*random(1,20));
       hrv = constrain(hrv, 60, maxHeartRate);
    }
    else if(sensorData.hasKey("Heartrate")){
        hrv = sensorData.get("Heartrate");

         // if we lose the heart rate, use the previous cached value, if it exists
        if(hrv <= 0){
            if(heartRateValues.size()>=1)
                hrv = heartRateValues.get(heartRateValues.size()-1);
        }
    }
    
    //println("Current heartrate: ", (int)hrv);
    return (int)hrv;
}


void restartData(){
    for(int i = 0; i < 5; i++){
         timeInEachZone[i] = 0;   
     }
     
    lineChartX.clear();
    lineChartY.clear();
    x = 0;
    y = 0;
}

void updateTimeInZone(){
    if(!timer.isRunning) { return; }
    
    int heartRate = getHeartRate();
    float heartRatePercent = (heartRate/maxHeartRate)*100;
    int userZoneIdx = getUserZone(heartRatePercent);
    String currentZone = zoneNames[userZoneIdx];
    
    //println("Current zone: ", currentZone, heartRatePercent);
    timeInEachZone[userZoneIdx]+=1;
    maxTimeInEachZone = max(timeInEachZone[userZoneIdx], maxTimeInEachZone);

}

void updateAvgHeartRate() {
    float heartrate = getHeartRate();
    heartRateValues.append(heartrate);
    avgHeartRate = (int)(getAverageHeartRate());
    //println("Average heartrate: ", avgHeartRate);
}

void dataLoop(){
    if(!DEBUG_MODE){ 
        readSerial();
    }
 
    //println();
    updateTimeInZone();
    updateAvgHeartRate();
}
