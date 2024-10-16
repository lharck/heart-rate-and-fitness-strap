Timer timer;

class MainScene {

    UIButton debugButton;
    UIButton fitnessButton;
    UIButton stopButton;
    UIButton meditationButton;
    UIButton stressButton;
    UIButton statsButton;   
    boolean isStressMode = false;

    PImage logo;
    
    float buttonSpacing = 20;

    int stressStartTime = -1;
    int currentHeartRate = -1;  
    
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
        
        statsButton = new UIButton(meditationButton.xPos + meditationButton.xSize + buttonSpacing, btnHeights, .15 * width, .07 * height, "Stats", color(153, 102, 255));
        statsButton.setRoundedCorners(10);
        statsButton.setShadow(true);

        stopButton = new UIButton(statsButton.xPos + statsButton.xSize + buttonSpacing , btnHeights , .15 * width, .07 * height, "Pause", color(255, 99, 71));
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

    void draw() {
        background(245);  
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
        statsButton.draw();   // Draw Stats button
        
        image(logo, .009 * width, .009 * height, .09 * width, .09 * height);  // Add logo with proportional size
        
        //showHeartRate();  

        if (isStressMode) {
            checkStressMode();  
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
            startStressMode();
        }

        if (meditationButton.isClicked(mouseX, mouseY)) {
            startMeditationMode();
        }

        if (debugButton.isClicked(mouseX, mouseY)) {
            DEBUG_MODE = !DEBUG_MODE;
            debugButton.text = "Debug: "  + DEBUG_MODE;
        }

        if (statsButton.isClicked(mouseX, mouseY)) {
            // Open the new StatsScene in a new window
            PApplet.runSketch(new String[] {"StatsScene"}, new StatsScene());
            statsButton.setDisabled(true);
        }
    }

    void drawTitles() {  
        String appName = "Health Tracker";
        fill(255, 255, 255);
        textSize(.06 * height);
        textAlign(CENTER, CENTER);
        text(appName, .5 * width,  .05 * height);
    }
    
    void startFitnessMode() {
        timer.startTimer();  
        fitnessButton.setDisabled(true);
        stopButton.setDisabled(false);
        stressButton.setDisabled(false);
        meditationButton.setDisabled(false);
        isStressMode = false;  
    }
    
    void startStressMode() {
        restartData();
        isStressMode = true;
        stressStartTime = millis();  
        timer.startTimer();  
        stressButton.setDisabled(true);
        stopButton.setDisabled(false);
        fitnessButton.setDisabled(false);
        meditationButton.setDisabled(false);
    }
    
    void startMeditationMode() {
        timer.startTimer();  
        meditationButton.setDisabled(true);
        fitnessButton.setDisabled(false);
        stopButton.setDisabled(false);
        stressButton.setDisabled(false);
        isStressMode = false;  
    }

    void stopModes() {
        timer.stopTimer();
        stopButton.setDisabled(true);
        fitnessButton.setDisabled(false);
        stressButton.setDisabled(false);
        meditationButton.setDisabled(false);
        isStressMode = false;
    }

    void checkStressMode() {
        if (millis() - stressStartTime >= 60000) {  
            if (sensorData.hasKey("Heartrate")) {
                currentHeartRate = sensorData.get("Heartrate");
                float averageHeartRate = getAverageHeartRate();
            
                int age = ageScene.enteredAge;  
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
