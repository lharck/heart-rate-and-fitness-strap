Timer timer;  

class MainScene {
    
    UIButton debugButton;
    UIButton fitnessButton;
    UIButton stopButton;
    UIButton calmVsStressButton;   // Combined Calm vs Stress Mode Button
    boolean isCalmVsStressMode = false;
    
    // For tracking heart rate changes
    int calmVsStressStartTime = -1;
    int currentHeartRate = -1;  // Variable to store real-time heart rate
    
    MainScene() {
        fitnessButton = new UIButton(90, 30, 120, 40, "Fitness Mode");
        stopButton = new UIButton(480, 30, 100, 40, "Stop");
        calmVsStressButton = new UIButton(220, 30, 200, 40, "Calm vs Stress Mode");
        stopButton.setDisabled(true); // Stop button initially disabled
        debugButton = new UIButton(width * .5, 30, 120, 40, "Debug Mode");
        debugButton.text = "Debug: "  + DEBUG_MODE;

        timer = new Timer(); // Initialize the Timer class

        setupGraph();
        setupBarChart();
    }

    void showHeartRate() {
        if (!sensorData.hasKey("Heartrate")) { return; }
        currentHeartRate = sensorData.get("Heartrate");  // Get the real-time heart rate
        
        textSize(25);
        fill(255,0,0);  
        text(currentHeartRate, .125 * width, .480 * height);  // Display real-time heart rate
    }

    void draw() {
        background(220);
        fill(32, 92, 122);
        rect(0, 0, width, .1 * height);
        drawTitle();
        drawBarChart();
        drawGraph();
        timer.drawTimer();  // Display timer using the Timer class
        fitnessButton.draw();   // Draw Start button
        stopButton.draw();    // Draw Stop button
        calmVsStressButton.draw(); // Draw Calm vs Stress Mode button
        debugButton.draw();
        showHeartRate();  // Display real-time heart rate

        if (isCalmVsStressMode) {
            checkCalmVsStressMode();  // Continuously check the Calm vs Stress mode
        }
    }

    void mousePressed() {
        // Start fitness mode
        if (fitnessButton.isClicked(mouseX, mouseY)) {
            startFitnessMode();
        }
        
        // Stop modes
        if (stopButton.isClicked(mouseX, mouseY)) {
            stopModes();
        }
        
        // Start Calm vs Stress Mode
        if (calmVsStressButton.isClicked(mouseX, mouseY)) {
            startCalmVsStressMode();
        }
        
       if (debugButton.isClicked(mouseX, mouseY)) {
            DEBUG_MODE = !DEBUG_MODE;
            debugButton.text = "Debug: "  + DEBUG_MODE;
        }
    }

    void drawTitle() {
        String title1 = "Heart Rate Monitor";
        fill(32, 92, 122);
        textSize(30);
        text(title1, (width - textWidth(title1)) / 2, .480 * height);
        String title2 = "Exercise Zones";
        fill(32, 92, 122);
        textSize(30);
        text(title2, (width - textWidth(title2)) / 2, .125 * height);
    }
    
    // Method to handle fitness mode
    void startFitnessMode() {
        timer.startTimer();  // Track time
        fitnessButton.setDisabled(true);
        stopButton.setDisabled(false);
        calmVsStressButton.setDisabled(false);
        isCalmVsStressMode = false;  // Ensure Calm vs Stress mode is off
    }
    
    // Method to handle Calm vs Stress mode
    void startCalmVsStressMode() {
        restartData();
        isCalmVsStressMode = true;
        calmVsStressStartTime = millis();  // Record start time
        timer.startTimer();  // Track time
        calmVsStressButton.setDisabled(true);
        stopButton.setDisabled(false);
        fitnessButton.setDisabled(false);
    }

    // Method to stop all modes
    void stopModes() {
        //restartData();
        timer.stopTimer();
        stopButton.setDisabled(true);
        fitnessButton.setDisabled(false);
        calmVsStressButton.setDisabled(false);
        isCalmVsStressMode = false;
    }

    // Check Calm vs Stress mode after 60 seconds
    void checkCalmVsStressMode() {
        if (millis() - calmVsStressStartTime >= 60000) {  // 60 seconds have passed
            if (sensorData.hasKey("Heartrate")) {
                currentHeartRate = sensorData.get("Heartrate");
                float averageHeartRate = getAverageHeartRate();
            
                // Use the age entered from AgeScene
                int age = ageScene.enteredAge;  // Dynamically get the age from AgeScene
            
                // Get min and max heart rate for the user's age group
                int[] heartRateRange = getHeartRateRangeForAge(age);
                int minHeartRate = heartRateRange[0];
                int maxHeartRate = heartRateRange[1];
            
                // Check if the heart rate is in the calm range or the stress range
                if (currentHeartRate < averageHeartRate) {
                    // User is calm
                    fill(0, 255, 0);
                    textSize(25);
                    text("You are calm", .7 * width, .480 * height);
                } else if (currentHeartRate > maxHeartRate || currentHeartRate < minHeartRate) {
                    // User is stressed (if above max threshold or below min threshold)
                    fill(255, 0, 0);
                    textSize(25);
                    text("You are stressed", .7 * width, .480 * height);
                }
            }
        }
    }

    // Function to get heart rate range (min and max) based on age group
    int[] getHeartRateRangeForAge(int age) {
        if (age >= 20 && age <= 30) return new int[] {100, 170};  // 20-30 years: 100-170 bpm
        if (age >= 30 && age <= 40) return new int[] {95, 162};   // 30-40 years: 95-162 bpm
        if (age >= 40 && age <= 50) return new int[] {90, 153};   // 40-50 years: 90-153 bpm
        if (age >= 50 && age <= 60) return new int[] {85, 145};   // 50-60 years: 85-145 bpm
        if (age >= 60 && age <= 70) return new int[] {80, 136};   // 60-70 years: 80-136 bpm
        return new int[] {75, 128};                               // 70+ years: 75-128 bpm
    }
}
