Timer timer;

class MainScene {
    
    UIButton debugButton;
    UIButton fitnessButton;
    UIButton stopButton;
    UIButton meditationButton;
    UIButton stressButton;   
    boolean isCalmVsStressMode = false;
    
    float buttonSpacing = 10.0;
    PImage logo;
    
    
    int calmVsStressStartTime = -1;
    int currentHeartRate = -1;  // Variable to store real-time heart rate
    
    MainScene() {
        int btnHeights = 100;
        
        fitnessButton = new UIButton(.01 * width, btnHeights, .15 * width, .07 * height, "Fitness Mode", color(50, 205, 50));
        fitnessButton.setRoundedCorners(10);
        fitnessButton.setShadow(true);

        stressButton = new UIButton(fitnessButton.xPos + fitnessButton.xSize + buttonSpacing, btnHeights, .15 * width, .07 * height, "Stress Mode", color(255, 165, 0));
        stressButton.setRoundedCorners(10);
        stressButton.setShadow(true);

        meditationButton = new UIButton(stressButton.xPos + stressButton.xSize + buttonSpacing, btnHeights, .15 * width, .07 * height, "Meditation Mode", color(100, 149, 237));
        meditationButton.setRoundedCorners(10);
        meditationButton.setShadow(true);

        stopButton = new UIButton(meditationButton.xPos + meditationButton.xSize + buttonSpacing + 150, btnHeights , .15 * width, .07 * height, "Pause", color(255, 99, 71));
        stopButton.setDisabled(true);
        stopButton.setRoundedCorners(10);
        stopButton.setShadow(true);

        debugButton = new UIButton(stopButton.xPos + stopButton.xSize + buttonSpacing , btnHeights, .15 * width, .07 * height, "Debug: "  + DEBUG_MODE, color(70, 130, 180));
        debugButton.setDisabled(DEBUG_MODE); 
        debugButton.setRoundedCorners(10);
        debugButton.setShadow(true);
        
        timer = new Timer(); 

        logo = loadImage("logo.png");

        setupGraph();
        setupBarChart();
    }

    void showHeartRate() {
        if (!sensorData.hasKey("Heartrate")) { return; }
        currentHeartRate = sensorData.get("Heartrate");  
        
        textSize(25);
        fill(255, 0, 0);  
        textAlign(CENTER, CENTER);
        text(currentHeartRate, .5 * width, .25 * height);  
    }

    void draw() {

        background(BG_COLOR_DEFAULT);  
        fill(32, 92, 122);
        rect(0, 0, width, .1 * height);
        
        textFont(createFont("Arial Bold",10),10);
        drawTitles();
        textFont(createFont("Arial",10),10);

        drawGraph();
        drawBarChart();
        timer.drawTimer();  
        
        // Draw buttons
        fitnessButton.draw();   
        stopButton.draw();    
        stressButton.draw();
        meditationButton.draw();
        debugButton.draw();
        
        image(logo, .009 * width, .009 * height, .09 * width, .09 * height);  // Add logo with proportional size
        
        showHeartRate();  

        if (isCalmVsStressMode) {
            checkCalmVsStressMode();  
        }
    }

    void mousePressed() {
        if (fitnessButton.isClicked(mouseX, mouseY)) {
            startFitnessMode();
        }
        
        if (stopButton.isClicked(mouseX, mouseY)) {
            stopModes();
        }
        
        if (stressButton.isClicked(mouseX, mouseY)) {
            startCalmVsStressMode();
        }
        
       if (debugButton.isClicked(mouseX, mouseY)) {
            DEBUG_MODE = !DEBUG_MODE;
            debugButton.text = "Debug: "  + DEBUG_MODE;
        }
    }

    void drawTitles() {  
        String appName = "Health Tracker";
        fill(255, 255, 255);
        textSize(.06 * height);
        textAlign(CENTER, CENTER);
        text(appName, .5 * width,  .05 * height);
    }
    
    void drawValues() {
        fill(0);
        textSize(30);
        //text(title3, (width - textWidth(title2)) / 3.5, .275 * height);
    }

    void startFitnessMode() {
        timer.startTimer();  // Track time
        fitnessButton.setDisabled(true);
        stopButton.setDisabled(false);
        stressButton.setDisabled(false);
        isCalmVsStressMode = false;  // Ensure Calm vs Stress mode is off
    }
    
    void startCalmVsStressMode() {
        restartData();
        isCalmVsStressMode = true;
        calmVsStressStartTime = millis();  // Record start time
        timer.startTimer();  // Track time
        stressButton.setDisabled(true);
        stopButton.setDisabled(false);
        fitnessButton.setDisabled(false);
    }

    // Method to stop all modes
    void stopModes() {
        timer.stopTimer();
        stopButton.setDisabled(true);
        fitnessButton.setDisabled(false);
        stressButton.setDisabled(false);
        isCalmVsStressMode = false;
    }

    void checkCalmVsStressMode() {
        if (millis() - calmVsStressStartTime >= 60000) {  // 60 seconds have passed
            if (sensorData.hasKey("Heartrate")) {
                currentHeartRate = sensorData.get("Heartrate");
                float averageHeartRate = getAverageHeartRate();
            
                int age = ageScene.enteredAge;  // Dynamically get the age from AgeScene
                int[] heartRateRange = getHeartRateRangeForAge(age);
                int minHeartRate = heartRateRange[0];
                int maxHeartRate = heartRateRange[1];
            
                if (currentHeartRate < averageHeartRate) {
                    fill(0, 255, 0);  // Green for calm
                    textSize(25);
                    text("You are calm", .7 * width, .480 * height);
                } else if (currentHeartRate > maxHeartRate || currentHeartRate < minHeartRate) {
                    fill(255, 0, 0);  // Red for stressed
                    textSize(25);
                    text("You are stressed", .7 * width, .480 * height);
                }
            }
        }
    }

    int[] getHeartRateRangeForAge(int age) {
        if (age >= 20 && age <= 30) return new int[] {100, 170};  // 20-30 years: 100-170 bpm
        if (age >= 30 && age <= 40) return new int[] {95, 162};   // 30-40 years: 95-162 bpm
        if (age >= 40 && age <= 50) return new int[] {90, 153};   // 40-50 years: 90-153 bpm
        if (age >= 50 && age <= 60) return new int[] {85, 145};   // 50-60 years: 85-145 bpm
        if (age >= 60 && age <= 70) return new int[] {80, 136};   // 60-70 years: 80-136 bpm
        return new int[] {75, 128};                               // 70+ years: 75-128 bpm
    }
}
