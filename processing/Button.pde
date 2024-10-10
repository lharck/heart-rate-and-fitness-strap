class UIButton {
    float xPos;
    float yPos;
    float xSize;
    float ySize;
    String text;
    boolean disabled;

    UIButton(float initXPos, float initYPos, float initXSize, float initYSize, String buttonText) {  
        xPos = initXPos;
        yPos = initYPos;
        xSize = initXSize;
        ySize = initYSize;
        text = buttonText;
        disabled = false;
    }

    void setDisabled(boolean isDisabled) {
        disabled = isDisabled;
    }

    void draw() {
        fill(disabled ? 150 : 255); // Change color if disabled
        rect(xPos, yPos, xSize, ySize);
        fill(0);
        textSize(20);
        textAlign(CENTER, CENTER);
        text(text, xPos + xSize / 2, yPos + ySize / 2);
    }

    boolean isClicked(float mouseX, float mouseY) {
        if (!disabled && mouseX > xPos && mouseX < xPos + xSize && mouseY > yPos && mouseY < yPos + ySize) {
            return true;
        }
        return false;
    }
}
