Timer timer;

class MainScene {

  UIButton debugButton;
  UIButton fitnessButton;
  UIButton stopButton;
  UIButton meditationButton;
  UIButton stressButton;
  UIButton statsButton;
  boolean isStressMode = false;
  boolean isUserStressed = false;
  boolean isMeditationMode = false;

  PImage logo;

  float buttonSpacing = 20;
  int stressStartTime = -1;

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

    stopButton = new UIButton(statsButton.xPos + statsButton.xSize + buttonSpacing, btnHeights, .15 * width, .07 * height, "Pause", color(255, 99, 71));
    stopButton.setDisabled(true);
    stopButton.setRoundedCorners(10);
    stopButton.setShadow(true);

    debugButton = new UIButton(stopButton.xPos + stopButton.xSize + buttonSpacing, btnHeights, .15 * width, .07 * height, "Debug: "  + DEBUG_MODE, color(70, 130, 180));
    debugButton.setDisabled(DEBUG_MODE);
    debugButton.setRoundedCorners(10);
    debugButton.setShadow(true);

    timer = new Timer();

    logo = loadImage("logo.png");

    setupGraph();
    setupBarChart();
  }

  void draw() {
    int bgColor;
    if (isUserStressed) {
      bgColor = color(235, 150, 84);
    } else {
      if (isStressMode) {
        bgColor = color(168, 211, 240);
      } else {
        bgColor = color(245, 245, 245);
      }
    }
    background(bgColor);
    fill(32, 92, 122);
    rect(0, 0, width, .1 * height);

    textFont(createFont("Arial Bold", 10), 10);
    drawTitles();
    textFont(createFont("Arial", 10), 10);

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

    if (isStressMode) {
      monitorStressResponse();
    }
    if (isMeditationMode) {
      monitorBreathingPattern();
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
      PApplet.runSketch(new String[] {"StatsScene"}, new StatsScene());
      statsButton.setDisabled(true);
    }
  }

  void drawTitles() {
    String appName = "Health Tracker";
    fill(255, 255, 255);
    textSize(.06 * height);
    textAlign(CENTER, CENTER);
    text(appName, .5 * width, .05 * height);
  }

  void startFitnessMode() {
    restartData();
    timer.startTimer();
    fitnessButton.setDisabled(true);
    stopButton.setDisabled(false);
    stressButton.setDisabled(false);
    meditationButton.setDisabled(false);
    isStressMode = false;
    isUserStressed = false;
    isMeditationMode = false;

    trackCardioZone();
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
    isUserStressed = false;
    isMeditationMode = false;

    monitorStressResponse();
  }

  void startMeditationMode() {
    restartData();
    timer.startTimer();
    meditationButton.setDisabled(true);
    fitnessButton.setDisabled(false);
    stopButton.setDisabled(false);
    stressButton.setDisabled(false);
    isStressMode = false;
    isMeditationMode = true;
    isUserStressed = false;

    monitorBreathingPattern();
  }

  void stopModes() {
    timer.stopTimer();
    stopButton.setDisabled(true);
    fitnessButton.setDisabled(false);
    stressButton.setDisabled(false);
    meditationButton.setDisabled(false);
    isStressMode = false;
    isMeditationMode = false;
    isUserStressed = false;
  }

  void trackCardioZone() {
    float heartRatePercent = (currentHeartRate / maxHeartRate) * 100;
    int zoneIndex = getUserZone(heartRatePercent);

    // Update cardio zone display and track the graph
    //updateCardioGraph();
    println("Tracking cardio zone in Fitness Mode...");
  }

  void monitorStressResponse() {
    println("Monitoring stress response...");

    if ((currentHeartRate > (restingHeartRate * 1.2)) && (currentRespiratoryRate > (restingRespiratoryRate * 1.2))) {
      println("User might be stressed.");
      isUserStressed = true;
    } else {
      println("User seems calm.");
      isUserStressed = false;
    }
  }

  // **Meditation Mode**: Monitor and display breathing pattern.
  void monitorBreathingPattern() {
    float temp = inhalationDuration * 3.0;
    if (temp >= exhalationDuration) {
      println("Incorrect breathing pattern during meditation.\nExhalation should be at least 3 times longer than inhalation");
      displayBreathingAlert();
    } else {
      println("Correct breathing pattern detected");
    }
  }

  // Helper method to display an alert for incorrect breathing pattern.
  void displayBreathingAlert() {
    fill(255,255,255);
    rect((width / 4), (height / 2), width/2, 60);
    fill(255, 0, 0);
    textSize(25);
    text("Correct your breathing pattern!", width / 2, (height / 2) + 30);
  }
}
