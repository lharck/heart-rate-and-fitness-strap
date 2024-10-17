import processing.serial.*;
import org.gicentre.utils.stat.*;

MainScene mainScene;
AgeScene ageScene;

int lastTime = millis();
int timeOfLastUpdate = 0;

int lastTime = millis();
int timeOfLastUpdate = 0;

// Scene management
void setup() {
    size(1000, 900);
    setupData();
    mainScene = new MainScene();
    ageScene = new AgeScene();
}

void draw() {
    // Switch between scenes
    if (currentScene == "MainScene") {
        mainScene.draw();
    } else if (currentScene == "AgeScene") {
        ageScene.draw();
    }
    
    int currTime = millis();
    int timeDiff = currTime - timeOfLastUpdate;
    while (timeDiff >= 10) {
        updateGraph();
        dataLoop();
        timeDiff -= 10;
    }
    timeOfLastUpdate = currTime;
}

// Ensure you only handle mouse clicks in the current scene
void mousePressed() {
    if (currentScene == "AgeScene") {
        ageScene.mousePressed();
    } else if (currentScene == "MainScene") {
        mainScene.mousePressed();
    }
}

void keyPressed() {
    if (currentScene == "AgeScene") {
        ageScene.keyPressed();
    }
}
