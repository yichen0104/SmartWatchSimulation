import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 3 + (int)random(3); //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far

int lastLetterChangeTime; // Timestamp of the last letter change
int letterEntryTimeout = 1000; // 1.0 seconds in milliseconds


// TODO: you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
// You can use this website to compute the PPI: https://www.sven.de/dpi/
// Manually the resolution for your display, and the screen size, and calculate
// Especially for retina displays -- Don't just rely on online search!
final int DPIofYourDeviceScreen = 166; // default: 127
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

class CustomButton {
  float x, y, width, height;
  color buttonColor;
  String label;
  float textSize;
  boolean isPressed = false; // track press state

  CustomButton(float x, float y, float width, float height, color buttonColor, String label, float textSize) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.buttonColor = buttonColor;
    this.label = label;
    this.textSize = textSize;
  }

  void display() {
    // Set the border color and weight
    stroke(255); // White color for the border
    strokeWeight(1); // Set the border width
    
    if (isPressed) {
      fill(50); // Darken the button color when pressed
    } else {
      fill(buttonColor);
    }
    rect(x, y, width, height);
    fill(255); // Text color
    textSize(textSize);
    textAlign(CENTER, CENTER);
    text(label, x + width/2, y + height/2);
    textSize(24);
    noStroke();
  }

  boolean isClicked(float mouseX, float mouseY) {
    return mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height;
  }
}

// Declare buttons
//CustomButton[] placeholderButtons = new CustomButton[8];
CustomButton spaceButton, backspaceButton;
//CustomButton redButton;
//CustomButton greenButton;
CustomButton ABCButton, DEFButton, GHIButton, JKLButton, MNOButton, PQRSButton, TUVButton, WXYZButton;

// Declare global variables to track button clicking state
int lastClickTime = 0;
int clickCount = 0;
String lastClickedLabel = "";
// allow auto entry boolean flag
boolean allowAutoEntry = true;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial Unicode MS", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  lastLetterChangeTime = -1;  // Initialize the timer, -1 means no button click yet
  
  float buttonSize = sizeOfInputArea / 4;
  //redButton = new CustomButton(width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea/2 + buttonSize, buttonSize, buttonSize, color(255, 0, 0), "PREV", 12);
  //greenButton = new CustomButton(width/2 - sizeOfInputArea/2 + buttonSize, height/2 - sizeOfInputArea/2 + buttonSize, buttonSize, buttonSize, color(0, 255, 0), "NEXT", 12);
  /*String[] labels = {"abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"};
  for (int i = 0; i < 8; i++) {
    int row = 1 + i / 4;
    int col = i % 4;
    placeholderButtons[i] = new CustomButton(width/2 - sizeOfInputArea/2 + col * buttonSize, height/2 - sizeOfInputArea/2 + row * buttonSize, buttonSize, buttonSize, color(128), labels[i], 12);
  }*/

  // SPACE button covering grid[3][0] and grid[3][1]
  spaceButton = new CustomButton(width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea/2 + 3 * buttonSize, 2 * buttonSize, buttonSize, color(128), "SPACE", 12);

  // Backspace button covering grid[3][2] and grid[3][3]
  backspaceButton = new CustomButton(width/2 - sizeOfInputArea/2 + 2 * buttonSize, height/2 - sizeOfInputArea/2 + 3 * buttonSize, 2 * buttonSize, buttonSize, color(128), "⌫", 12);
  
  ABCButton = new CustomButton(width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea/2 + buttonSize, buttonSize, buttonSize, color(128), "abc", 12);
  DEFButton = new CustomButton(width/2 - sizeOfInputArea/2 + buttonSize, height/2 - sizeOfInputArea/2 + buttonSize, buttonSize, buttonSize, color(128), "def", 12);
  GHIButton = new CustomButton(width/2 - sizeOfInputArea/2 + buttonSize * 2, height/2 - sizeOfInputArea/2 + buttonSize, buttonSize, buttonSize, color(128), "ghi", 12);
  JKLButton = new CustomButton(width/2 - sizeOfInputArea/2 + buttonSize * 3, height/2 - sizeOfInputArea/2 + buttonSize, buttonSize, buttonSize, color(128), "jkl", 12);
  MNOButton = new CustomButton(width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea/2 + buttonSize * 2, buttonSize, buttonSize, color(128), "mno", 12);
  PQRSButton = new CustomButton(width/2 - sizeOfInputArea/2 + buttonSize, height/2 - sizeOfInputArea/2 + buttonSize * 2, buttonSize, buttonSize, color(128), "pqrs", 12);
  TUVButton = new CustomButton(width/2 - sizeOfInputArea/2 + buttonSize * 2, height/2 - sizeOfInputArea/2 + buttonSize * 2, buttonSize, buttonSize, color(128), "tuv", 12);
  WXYZButton = new CustomButton(width/2 - sizeOfInputArea/2 + buttonSize * 3, height/2 - sizeOfInputArea/2 + buttonSize * 2, buttonSize, buttonSize, color(128), "wxyz", 12);
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 
    
    //draw hint text
    textSize(16);
    text("Please press any key n times to input the nth letter it contains.\n"+
    "Wait for 1 second for the letter to automatically enter.\n"+
    "You can also press the background letter display to immediately enter the letter.", 30, 730);
    textSize(24);

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

    //my draw code
    // Refactored button drawing with labels
    // Adjust size and position
    // Button size based on the smartwatch screen size
    // Display buttons
    /*for (CustomButton button : placeholderButtons) {
      button.display();
    }*/
    
  
    spaceButton.display();
    backspaceButton.display();
    
    ABCButton.display();
    DEFButton.display();
    GHIButton.display();
    JKLButton.display();
    MNOButton.display();
    PQRSButton.display();
    TUVButton.display();
    WXYZButton.display();

    textAlign(CENTER, CENTER);
    fill(200);
    text("" + currentLetter, width/2, height/2 - sizeOfInputArea/2 + sizeOfInputArea/8);

    if (!allowAutoEntry && millis() - lastLetterChangeTime > 200) {
      allowAutoEntry = true;
    }
    checkForAutomaticEntry(); // Check for automatic letter entry

  }
}

// Draw a single button on the screen
void drawButton(float x, float y, float w, float h, color c, String label) {
    fill(c);
    rect(x, y, w, h);
    fill(255);
    textSize(10);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
    textSize(24);
}

// Handle auto letter entry
void checkForAutomaticEntry() {
  
  if (lastLetterChangeTime != -1 && millis() - lastLetterChangeTime > letterEntryTimeout) {
    // Check that the current letter is valid for automatic entry
    if (currentLetter == '`') {
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    } else {
      if (currentLetter == '_'){
        //currentTyped += ' ';
      } else {
        currentTyped += currentLetter;
      }
    }
    // Reset the timer and lastLetterChangeTime
    lastLetterChangeTime = -1;
  }
}

// Reset timer
void resetTimer() {
  lastLetterChangeTime = millis();
}


//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

// Handle multi-letter key input
void handleButtonMultiClick(CustomButton button, String label) {
  if (button.isClicked(mouseX, mouseY)) {
    int currentTime = millis();
    if (!lastClickedLabel.equals(label) || currentTime - lastClickTime > 1000) {
      clickCount = 0;
      lastClickedLabel = label;
    }

    lastClickTime = currentTime;
    clickCount = (clickCount % label.length()) + 1;
    currentLetter = label.charAt(clickCount - 1);

    // Update lastLetterChangeTime and reset allowAutoEntry
    lastLetterChangeTime = millis();
    allowAutoEntry = false;
  }
}

// Handle backspace key input, override all other keys
void handleBackspace() {
  if (currentTyped.length() > 0) {
    // Remove the last character from currentTyped
    currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
    currentLetter = '_';
  }
  // Reset the last letter change time to prevent immediate automatic entry of a new letter
  lastLetterChangeTime = millis();
  allowAutoEntry = false;
}

// Handle space key input, override all other keys
void handleSpace() {
  currentTyped += " ";
  currentLetter = '_';
  // Reset the last letter change time to prevent immediate automatic entry of a new letter
  lastLetterChangeTime = millis();
  allowAutoEntry = false;
}

// Helper func to process button pressed state
void updateButtonPressState(CustomButton button) {
  if (button.isClicked(mouseX, mouseY)) {
    button.isPressed = true;
  }
}
//my terrible implementation you can entirely replace
void mousePressed()
{
  // Check if the left (Prev) button is clicked
  /*if (redButton.isClicked(mouseX, mouseY)) {
    // Red button logic
    handlePrevButton();
  }
  if (greenButton.isClicked(mouseX, mouseY)) {
    // Green button logic
    handleNextButton();
  }*/
  //checkButtonClick(ABCButton, "abc");
  // Handle button press color change
  updateButtonPressState(ABCButton);
  updateButtonPressState(DEFButton);
  updateButtonPressState(GHIButton);
  updateButtonPressState(JKLButton);
  updateButtonPressState(MNOButton);
  updateButtonPressState(PQRSButton);
  updateButtonPressState(TUVButton);
  updateButtonPressState(WXYZButton);
  updateButtonPressState(spaceButton);
  updateButtonPressState(backspaceButton);
  // Handle letter input events
  handleButtonMultiClick(ABCButton, "abc");
  handleButtonMultiClick(DEFButton, "def");
  handleButtonMultiClick(GHIButton, "ghi");
  handleButtonMultiClick(JKLButton, "jkl");
  handleButtonMultiClick(MNOButton, "mno");
  handleButtonMultiClick(PQRSButton, "pqrs");
  handleButtonMultiClick(TUVButton, "tuv");
  handleButtonMultiClick(WXYZButton, "wxyz");
  //handleButtonMultiClick(spaceButton, "_");

  if (spaceButton.isClicked(mouseX, mouseY)) {
    //println("Clicked: SPACE");
    // Add SPACE logic
    handleSpace();
  }

  if (backspaceButton.isClicked(mouseX, mouseY)) {
    //println("Clicked: ⌫");
    // Add backspace logic
    handleBackspace();
  }

  // Adjust this to check for clicks in the top 1/4 area of sizeOfInputArea
  if (didMouseClick(width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/4)) {
    // Logic for when the top 1/4 area is clicked
    if (currentLetter == '_') {
      //currentTyped += " ";
    } else if (currentLetter == '`' && currentTyped.length() > 0) {
      currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
    } else if (currentLetter != '`') {
      currentTyped += currentLetter;
    }
    currentLetter = '_';
    // Reset the last letter change time to prevent immediate automatic entry of a new letter
    lastLetterChangeTime = millis();
    allowAutoEntry = false;
  }

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


void mouseReleased() {
  ABCButton.isPressed = false;
  DEFButton.isPressed = false;
  GHIButton.isPressed = false;
  JKLButton.isPressed = false;
  MNOButton.isPressed = false;
  PQRSButton.isPressed = false;
  TUVButton.isPressed = false;
  WXYZButton.isPressed = false;
  spaceButton.isPressed = false;
  backspaceButton.isPressed = false;
}

boolean didMouseClickForPrev() {
  return didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2);
}

boolean didMouseClickForNext() {
  return didMouseClick(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2);
}
void handleLetterInput() {
  // Existing logic for letter input
  // ...
  resetTimer(); // Reset the timer for automatic entry
}

void handlePrevButton() {
  // Decrement the current letter and wrap around if necessary
  currentLetter--;
  if (currentLetter < '_') currentLetter = 'z';
  // Update the timer for automatic entry
  lastLetterChangeTime = millis();
}

void handleNextButton() {
  // Increment the current letter and wrap around if necessary
  currentLetter++;
  if (currentLetter > 'z') currentLetter = '_';
  // Update the timer for automatic entry
  lastLetterChangeTime = millis();
}
void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}


//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
