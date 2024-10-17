class Timer {
    int startTime;           // Variable to track the start time
    String elapsedTime = "00:00"; // String to store the formatted elapsed time
    boolean isRunning = false; // Variable to check if timer started

    Timer() {
        // Timer constructor
    }

    // Start the timer and set the initial time
    void startTimer() {
        startTime = millis(); // Record the start time
        isRunning = true;
    }

    // Stop the timer
    void stopTimer() {
        isRunning = false;
    }

    // Draw the timer on the screen, showing elapsed time in MM:SS format
    void drawTimer() {
        if (timer.isRunning) {
            int currentTime = millis() - startTime; // Calculate elapsed time
            elapsedTime = formatTime(currentTime);  // Format the time into MM:SS
        }
        textSize(40);
        fill(255);
        text(elapsedTime, 900, 45); // Display the elapsed time
    }

    // Format the elapsed time into MM:SS format
    String formatTime(int milliseconds) {
        int seconds = (milliseconds / 1000) % 60;
        int minutes = (milliseconds / 60000);
        return nf(minutes, 2) + ":" + nf(seconds, 2);
    }
    
    int getElapsedTime() {
        if (isRunning) {
            int currentTime = millis();  // Get the current time in milliseconds
            return (currentTime - startTime) / 1000;  // Return elapsed time in seconds
        } 
        return 0;  // If timer is not running, return 0
    }
    
    boolean getIsRunning() {
      return isRunning;
    }
}
