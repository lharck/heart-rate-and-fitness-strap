color BG_COLOR_DEFAULT = color(220);

float maxHeartRate = 220 - 24;
int[] zones = {60, 70, 80, 90, 100};
float[] timeInEachZone = {0,0,0,0,0};
String[] zoneNames = {"Very Light", "Light", "Moderate", "Hard", "Maximum"};
String currentState = "AskingForAge";
String currentScene = "MainScene"; 

color[] zoneColors = {
    color(173, 173, 173), // grey 
    color(0, 0, 255), // blue 
    color(0, 255, 0), // green
    color(255,255,0), // yellow
    color(255, 0, 0)  // red
};

int getUserZone(float heartRatePercent){
    for(int i = 0; i < zones.length; i++){
        if (heartRatePercent <= zones[i]){
            return i;
        }
    }
    
    return -1;
}
