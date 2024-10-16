class UIButton {
    float xPos;
    float yPos;
    float xSize;
    float ySize;
    String text;
    boolean disabled;
    int buttonColor;
    int hoverColor;
    int textColor;
    float cornerRadius;
    boolean shadow;

    UIButton(float initXPos, float initYPos, float initXSize, float initYSize, String buttonText) {  
        this(initXPos, initYPos, initXSize, initYSize, buttonText, color(255)); // Default white button
    }

    UIButton(float initXPos, float initYPos, float initXSize, float initYSize, String buttonText, int initButtonColor) {  
        xPos = initXPos;
        yPos = initYPos;
        xSize = initXSize;
        ySize = initYSize;
        text = buttonText;
        buttonColor = initButtonColor;
        hoverColor = lerpColor(buttonColor, color(200), 0.5);  // Lighter hover color by default
        textColor = color(0);  // Default black text color
        cornerRadius = 10;  // Default rounded corners
        shadow = false;  // Default no shadow
        disabled = false;
    }

    void setDisabled(boolean isDisabled) {
        disabled = isDisabled;
    }

    void setHoverColor(int newHoverColor) {
        hoverColor = newHoverColor;
    }

    void setTextColor(int newTextColor) {
        textColor = newTextColor;
    }

    void setRoundedCorners(float newCornerRadius) {
        cornerRadius = newCornerRadius;
    }

    void setShadow(boolean hasShadow) {
        shadow = hasShadow;
    }

    void draw() {
        if (disabled) {
            fill(150);  // Gray color if button is disabled
        } else if (isHovered(mouseX, mouseY)) {
            fill(hoverColor);  // Hover color
        } else {
            fill(buttonColor);  // Normal button color
        }

        if (shadow && !disabled) {
            // Draw shadow effect if enabled
            fill(0, 50);  // Slightly transparent shadow
            rect(xPos + 5, yPos + 5, xSize, ySize, cornerRadius);  // Offset for shadow
        }

        fill(buttonColor);
        rect(xPos, yPos, xSize, ySize, cornerRadius);  // Draw button

        fill(textColor);  // Set text color
        textSize(20);
        textAlign(CENTER, CENTER);
        text(text, xPos + xSize / 2, yPos + ySize / 2);  // Center text on button
    }

    boolean isClicked(float mouseX, float mouseY) {
        if (!disabled && mouseX > xPos && mouseX < xPos + xSize && mouseY > yPos && mouseY < yPos + ySize) {
            return true;
        }
        return false;
    }

    boolean isHovered(float mouseX, float mouseY) {
        return mouseX > xPos && mouseX < xPos + xSize && mouseY > yPos && mouseY < yPos + ySize;
    }
}
