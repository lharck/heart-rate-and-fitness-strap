class StatsScene extends PApplet {
    PImage logo;
   
    void settings() {
        size(400, 600); 
    }

    void setup() {
        background(245);  
        textAlign(CENTER, CENTER);
        textSize(20);
    }

    void draw() {
        background(245); 
        fill(32, 92, 122);
        rect(0, 0, width, .125 * height);
        
        textFont(createFont("Arial Bold",10),10);
        String title = "Statistics Overview";
        fill(255,255,255);
        textSize(.1 * width);
        textAlign(CENTER, CENTER);
        text(title, width / 2, height/16);  
        textFont(createFont("Arial",10),10);

        
        
        fill(0);
        textSize(20);
        text("Resting Heart Rate: " + restingHeartRate, width / 2, height / 4);  // Example stat
        text("Current Heart Rate: " + currentHeartRate, width / 2, height / 4 + 30);  // Example stat
        text("Max Heart Rate: " + maxHeartRate, width / 2, height / 4 + 60);  // Example stat
        text("Resting Respiration Rate: " + restingRespiratoryRate, width / 2, height / 4 + 90);
        text("Current Respiration Rate: " + currentRespiratoryRate, width / 2, height / 4 + 120);
        text("Inhalation Duration: " + inhalationDuration, width / 2, height / 4 + 150);
        text("Exhalation Duration: " + exhalationDuration, width / 2, height / 4 + 180);
        textFont(createFont("Arial Bold",20),20);
        text("Percent of Resting Respiratory Rates:", width / 2, height / 4 + 210);
        textFont(createFont("Arial",10),10);
        textSize(20);
        text("Very Light: " + nf((((float) respiratoryRateZoneTotals[0]/(float) respiratoryRateZoneSamples[0])/(float)restingRespiratoryRate)*100.0f,0,2) + "% Light: " + nf((((float) respiratoryRateZoneTotals[1]/(float) respiratoryRateZoneSamples[1])/(float)restingRespiratoryRate)*100.0f,0,2) + "%", width / 2, height / 4 + 240);
        text("Moderate: " + nf((((float) respiratoryRateZoneTotals[2]/(float) respiratoryRateZoneSamples[2])/(float)restingRespiratoryRate)*100.0f,0,2) + "% Hard: " + nf((((float) respiratoryRateZoneTotals[3]/(float) respiratoryRateZoneSamples[3])/(float)restingRespiratoryRate)*100.0f,0,2) + "%", width / 2, height / 4 + 270);
        text("Maximum: " + nf((((float) respiratoryRateZoneTotals[4]/(float) respiratoryRateZoneSamples[4])/(float)restingRespiratoryRate)*100.0f,0,2) + "%", width / 2, height / 4 + 300);
  
  }
}
