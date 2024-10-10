int CALIBRATION_TIME = 3;
class AgeScene {
    UIButton nextButton; // Button to proceed to the next scene
    TEXTBOX ageTextBox;  // Textbox for age input
    int enteredAge = -1; // Variable to store the entered age
    float startRecordingTimestamp;
    
    AgeScene() {  
        // Initialize the "Next" button and the text box for age input
        nextButton = new UIButton(325, 400, 120, 60, "Next");
        ageTextBox = new TEXTBOX(400, 250, 120, 60); // Textbox with specified position and size
    }

    void draw() {
        background(220);
        fill(255);
        fill(32, 92, 122);
        textSize(40);
        
        if(currentState == "AskingForAge" ) {
            text("Enter your age:", 270, 275);
            ageTextBox.DRAW();
            nextButton.draw();
        } 
        else if(currentState == "CalcHeartRate") {
            float timePassed = (millis() - startRecordingTimestamp)/1000;
            println(timePassed);
            if(timePassed < CALIBRATION_TIME){
                text("Calculating Your Resting Heart Rate...\nTime till complete: " + (int)(CALIBRATION_TIME-timePassed) + "\nCurrent Value: " + avgHeartRate, 350, 275);  
            }
            else if(timePassed >= CALIBRATION_TIME && timePassed <= (CALIBRATION_TIME+5)){
                text("Your resting heart rate: " + avgHeartRate, 350, 275);  
                restingHeartRate = avgHeartRate;
            }
            else if(timePassed >= CALIBRATION_TIME){
                currentScene = "MainScene";
            }
        }
    }

    void mousePressed() {
        if (currentScene == "AgeScene") {
            ageTextBox.PRESSED(mouseX, mouseY);

            if (nextButton.isClicked(mouseX, mouseY)) {
                // Validate if age has been entered and is numeric
                if (ageTextBox.Text.length() > 0 && isNumeric(ageTextBox.Text)) {
                    enteredAge = int(ageTextBox.Text); // Store the entered age
                    maxHeartRate = 220 - enteredAge; // Update maxHeartRate
                    //println("Age entered: " + enteredAge + ", Max Heart Rate: " + maxHeartRate); 
                    currentState = "CalcHeartRate";
                    startRecordingTimestamp = millis();
                    
                } else {
                    println("Please enter a valid age.");
                }
            }
        }
    }

    void keyPressed() {
        // Handle typing input in the text box
        ageTextBox.KEYPRESSED(key, keyCode);
    }

    // Utility function to check if a string is numeric
    boolean isNumeric(String str) {
        try {
            int num = int(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
