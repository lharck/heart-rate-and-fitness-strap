int CALIBRATION_TIME = 10;

class AgeScene {
    UIButton nextButton; 
    TEXTBOX ageTextBox;  
    int enteredAge = -1; 
    float startRecordingTimestamp;

    PImage logo;  
    String title = "Health Tracker";  

    AgeScene() {  
        float nextButtonXSize = 0.15 * width;
        nextButton = new UIButton((0.5  * width)-(nextButtonXSize/2), 0.65 * height, nextButtonXSize, 0.07 * height, "Next"); 
        ageTextBox = new TEXTBOX((int)(0.45 * width), (int)(0.435 * height), (int)(0.2 * width), 35);  

        logo = loadImage("logo.png");
        if (logo == null) {
            println("Logo failed to load");
        }
    }

    void draw() {
        background(BG_COLOR_DEFAULT);
        fill(32, 92, 122);
        rect(0, 0, width, .1 * height);

        if (logo != null) {
            image(logo, .009 * width, .009 * height, .09 * width, .09 * height);
        } else {
            println("Logo is null, check file path");
        }

        fill(255, 255, 255);
        textSize(.06 * height);
        textAlign(CENTER, CENTER);
        text(title, .5 * width, .05 * height);

        if (currentState == "AskingForAge") {
            fill(32, 92, 122);
            textSize(40);
            textAlign(RIGHT, CENTER); 
            text("Enter your age:", 0.4 * width, 0.45 * height); 

            ageTextBox.DRAW();

            nextButton.draw();  
        } 
        else if (currentState == "CalcHeartRate") {
            float timePassed = (millis() - startRecordingTimestamp) / 1000;

            if (timePassed < CALIBRATION_TIME) {
                fill(32, 92, 122);
                textSize(30);
                textAlign(CENTER, CENTER);
                text("Calculating Your Vitals...\n"
                     + "\nResting Heart Rate: " + currentHeartRate
                     + "\nResting Respiratory Rate: " + currentRespiratoryRate
                     + "\n\nTime till complete: " + (int)(CALIBRATION_TIME - timePassed),
                     .5 * width, .5 * height);  
            }
            else if (timePassed >= CALIBRATION_TIME) {
                fill(32, 92, 122);
                textSize(30);
                textAlign(CENTER, CENTER);
                text(
                "Your resting heart rate: " + currentHeartRate
                + "\nYour resting respiratory rate: " + currentRespiratoryRate,
                .5 * width, .5 * height);  
                restingHeartRate = currentHeartRate;
                restingRespiratoryRate = currentRespiratoryRate;
                nextButton.draw();    
            }
        }
    }

    void clickedAgeButton(){
        if (ageTextBox.Text.length() > 0 && isNumeric(ageTextBox.Text)) {
            enteredAge = int(ageTextBox.Text);
            maxHeartRate = 220 - enteredAge; 
            currentState = "CalcHeartRate";   
            startRecordingTimestamp = millis(); 
        } else {
            println("Please enter a valid age."); 
        }
    }

    void clickedNextScene(){
        currentScene = "MainScene";
    }

    void mousePressed() {
        if (currentScene == "AgeScene") {
            ageTextBox.PRESSED(mouseX, mouseY);

            if (nextButton.isClicked(mouseX, mouseY)) {
                float timePassed = (millis() - startRecordingTimestamp) / 1000;

                if(timePassed >= CALIBRATION_TIME){
                    clickedNextScene();
                } 
                else {
                    clickedAgeButton();
                }
                
            }
        }
    }

    void keyPressed() {
        
        ageTextBox.KEYPRESSED(key, keyCode);
    }

    
    boolean isNumeric(String str) {
        try {
            int num = int(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
