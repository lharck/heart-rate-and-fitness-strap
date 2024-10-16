class StatsScene extends PApplet {

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
        fill(50, 50, 150);
        text("Statistics Overview", width / 2, height / 5);  
        
        
        fill(0);
        textSize(15);
        text("Current Heart Rate: " + currentHeartRate, width / 2, height / 2);  // Example stat
        text("Max Heart Rate: " + maxHeartRate, width / 2, height / 2 + 30);  // Example stat
        // Add more stats here as needed
    }
    
   
}
