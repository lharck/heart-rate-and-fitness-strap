int CALIBRATION_TIME = 3;

class AgeScene {
    UIButton nextButton; 
    TEXTBOX ageTextBox;  
    int enteredAge = -1; 
    float startRecordingTimestamp;

    PImage logo;  
    String title = "Health Tracker";  

    AgeScene() {  
        nextButton = new UIButton(0.35 * width, 0.65 * height, 0.15 * width, 0.07 * height, "Next"); 
        ageTextBox = new TEXTBOX((int)(0.45 * width), (int)(0.435 * height), (int)(0.2 * width), 35);  

        logo = loadImage("logo.png");
        if (logo == null) {
            println("Logo failed to load");
        }
    }

    void draw() {
        background(245);
        fill(32, 92, 122);
        rect(0, 0, width, .1 * height);
        println("Drawing AgeScene");

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
            println(timePassed);

            if (timePassed < CALIBRATION_TIME) {
                fill(32, 92, 122);
                textSize(30);
                textAlign(CENTER, CENTER);
                text("Calculating Your Resting Heart Rate...\nTime till complete: " + (int)(CALIBRATION_TIME - timePassed) +
                     "\nCurrent Value: " + avgHeartRate, .5 * width, .5 * height);  
            }
            else if (timePassed >= CALIBRATION_TIME && timePassed <= (CALIBRATION_TIME + 5)) {
                fill(32, 92, 122);
                textSize(30);
                textAlign(CENTER, CENTER);
                text("Your resting heart rate: " + avgHeartRate, .5 * width, .5 * height);  
                restingHeartRate = avgHeartRate;
            }
            else if (timePassed >= CALIBRATION_TIME + 5) {
                currentScene = "MainScene";
            }
        }
    }

    void mousePressed() {
        if (currentScene == "AgeScene") {
            ageTextBox.PRESSED(mouseX, mouseY);

            if (nextButton.isClicked(mouseX, mouseY)) {
                if (ageTextBox.Text.length() > 0 && isNumeric(ageTextBox.Text)) {
                    enteredAge = int(ageTextBox.Text);
                    maxHeartRate = 220 - enteredAge; 
                    currentState = "CalcHeartRate";   
                    startRecordingTimestamp = millis(); 
                } else {
                    println("Please enter a valid age."); 
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
