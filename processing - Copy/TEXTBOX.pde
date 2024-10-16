public class TEXTBOX {
    public int X = 0, Y = 0, H = 35, W = 200;
    public int TEXTSIZE = 24;
   
    // Updated COLORS for consistency with MainScene/AgeScene
    public color Background = color(220, 220, 220);  // Light gray for unselected
    public color Foreground = color(32, 92, 122);    // Dark blue for text
    public color BackgroundSelected = color(200, 200, 200);  // Slightly darker when selected
    public color Border = color(32, 92, 122);        // Dark blue border to match MainScene elements
   
    public boolean BorderEnable = true;  // Border enabled for better visual consistency
    public int BorderWeight = 2;         // Thicker border for clarity
   
    public String Text = "";
    public int TextLength = 0;

    private boolean selected = false;

    TEXTBOX() {
        // Default constructor
    }
   
    TEXTBOX(int x, int y, int w, int h) {
        X = x; Y = y; W = w; H = h;
    }

    // Method to draw the textbox
    void DRAW() {
        if (selected) {
            fill(BackgroundSelected);
        } else {
            fill(Background);
        }
      
        if (BorderEnable) {
            strokeWeight(BorderWeight);
            stroke(Border);
        } else {
            noStroke();
        }

        // Draw the rectangle for the textbox
        rect(X, Y, W, H);

        // Draw the text inside the textbox
        fill(Foreground);  // Consistent color for text
        textSize(TEXTSIZE);
        textAlign(LEFT, CENTER);  // Align text to the left and center vertically
        text(Text, X + 10, Y + H / 2);  // Add padding for better alignment
    }

    // Method to handle key press for entering text
    boolean KEYPRESSED(char KEY, int KEYCODE) {
        if (selected) {
            if (KEYCODE == (int)BACKSPACE) {
                BACKSPACE();
            } else if (KEYCODE == 32) {
                addText(' ');  // Add space
            } else if (KEYCODE == (int)ENTER) {
                return true;  // Return true on Enter key press
            } else {
                boolean isKeyCapitalLetter = (KEY >= 'A' && KEY <= 'Z');
                boolean isKeySmallLetter = (KEY >= 'a' && KEY <= 'z');
                boolean isKeyNumber = (KEY >= '0' && KEY <= '9');
        
                if (isKeyCapitalLetter || isKeySmallLetter || isKeyNumber) {
                    addText(KEY);  // Add alphanumeric characters
                }
            }
        }
        return false;
    }

    // Method to add text to the textbox
    private void addText(char text) {
        if (textWidth(Text + text) < W - 20) {  // Subtract padding for better alignment
            Text += text;
            TextLength++;
        }
    }

    // Method to handle backspace
    private void BACKSPACE() {
        if (TextLength - 1 >= 0) {
            Text = Text.substring(0, TextLength - 1);
            TextLength--;
        }
    }

    // Helper method to check if mouse is over the textbox
    private boolean overBox(int x, int y) {
        return (x >= X && x <= X + W && y >= Y && y <= Y + H);
    }

    // Method to handle mouse press
    void PRESSED(int x, int y) {
        selected = overBox(x, y);
    }
}
