class StatsScene extends PApplet {
    PImage logo;
   
    void settings() {
        size(400, 400); 
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
        
        
        String title = "Statistics Overview";
        fill(255,255,255);
        textSize(.1 * height);
        textAlign(CENTER, CENTER);
        text(title, width / 2, height/16);  
        
        
        fill(0);
        textSize(20);
        text("Current Heart Rate: " + currentHeartRate, width / 2, height / 4);  // Example stat
        text("Max Heart Rate: " + maxHeartRate, width / 2, height / 4 + 30);  // Example stat
        text("Avg Heart Rate: " + restingRespirationRate, width / 2, height / 4 + 60);
        text("Resting Respiration Rate: " + restingRespirationRate, width / 2, height / 4 + 90);
        // Add more stats here as needed
    }
    
   
}
