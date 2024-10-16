void setup() {
  // Initialize
  Serial.begin(115200);

  // Setup ECG Monitor
  pinMode(10, INPUT); // Setup for leads off detection LO +
  pinMode(11, INPUT); // Setup for leads off detection LO -
}

void loop() {
  if ((digitalRead(10) == 1)||(digitalRead(11) == 1)) {
    // Ignore it
    //Serial.println('!');
  } else {
    // send the value of analog input 0:
    Serial.println("ECG:" + String(analogRead(A0)) + "s");
  }
  Serial.println("FSR:" + String(analogRead(A1)) + "s");
  //Wait for a bit to keep serial data from saturating
  delay(10);
}
