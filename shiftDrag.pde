import java.util.ArrayList;
import java.util.Collections;
import java.util.*;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = width/2.0;
float logoY = height/2.0;
float logoZ = 50f;
float logoRotation = 0;
boolean holding = false;
boolean rotating = false;
boolean is_good = false;
int mx = mouseX - width/2;
int my = mouseY - height/2;
float xShift = 0;
float yShift = 0;
float angleShift = 0;
float sizeShift = 0;



private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  ellipseMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(-width/2+border, width/2-border); //set a random x with some padding
    d.y = random(-height/2+border, height/2-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    //println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}

boolean closeD(float x, float y) {
  return dist(x, y, logoX, logoY)<inchToPix(.05f);
}

boolean closeZ(float z) {
  return abs(z - logoZ)<inchToPix(.05f);
}

boolean closeR(float rotation) {
  return calculateDifferenceBetweenAngles(rotation, logoRotation)<=5;
}

void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();
  mx = mouseX - width/2;
  my = mouseY - height/2;


  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }
  //===========DRAW CURSOR=================
  float hold_range = logoZ/2.0;
  if (mx > logoX - hold_range && mx < logoX + hold_range && my > logoY - hold_range && my < logoY + hold_range) {
    cursor(MOVE);
  }
  else{
    cursor(ARROW);
  }
  
  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Destination d = destinations.get(i);
    translate(d.x, d.y); //center the drawing coordinates to the center of the screen
    rotate(radians(d.rotation));
    noFill();
    strokeWeight(3f);
    if (trialIndex==i) {
      if (closeD(d.x, d.y))
        stroke(0, 255, 0, 255);
      else
        stroke(255, 0, 0, 255);
      rect(0, 0, 50, 50);
      if (closeR(d.rotation) && closeZ(d.z))
        stroke(0, 255, 0, 192);
      else
        stroke(255, 0, 0, 192); //set color to semi translucent
    } else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(logoX, logoY);
  rotate(radians(logoRotation));
  noStroke();
  /* 
  float tdist = dist(mx, my, logoX, logoY);
   float testX = tdist*cos(logoRotation);
   float testY = tdist*sin(logoRotation);
   
   if (testX<logoZ && testY< logoZ) {
   scolor = color(255, 0, 0);    
   } else {
   scolor = color(60, 60, 192, 192);
   }
   */
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  goodlogic();
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

void goodlogic() {
  //Destination d = destinations.get(trialIndex);  
  ellipse(logoX + width/2, logoY + height/2, 10, 10);
  if (holding) {
    logoX = mx-xShift;
    logoY = my-yShift;
  } else if (rotating) {
    logoRotation = degrees((float)Math.atan2(my - logoY, mx - logoX)) + 45.0 - angleShift;
    logoZ = dist(mx, my, logoX, logoY)-sizeShift;
  }
  // always check because why not
  //is_good = checkForSuccess();
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  float hold_range = logoZ/2.0;
  if (mx > logoX - hold_range && mx < logoX + hold_range && my > logoY - hold_range && my < logoY + hold_range) {
    holding = true;
    xShift = mx-logoX;
    yShift = my-logoY;
  } else {
    holding = false;
    hold_range *= 50;
    xShift = 0;
    yShift = 0;
    if (mx > logoX - hold_range && mx < logoX + hold_range && my > logoY - hold_range && my < logoY + hold_range) {
      rotating = true;
      sizeShift = dist(mx, my, logoX, logoY)-logoZ;
      angleShift = degrees((float)Math.atan2(my - logoY, mx - logoX)) + 45.0 - logoRotation;
    } else {
      rotating = false;
      sizeShift = 0;
      angleShift = 0;
    }
  }
}

void checkBounds() {
  float testX = logoZ*cos(logoRotation)+logoX;
  float testY = logoZ*sin(logoRotation)+ logoY;
  if (testX >logoX-logoZ && testX < logoX+logoZ && testY> logoY -logoZ && testY<logoY+logoZ) {
    holding=true;
  }
}
void mouseReleased()
{
  //check to see if user clicked with the right mouse button
  if (mouseButton==RIGHT)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  holding = false;
  rotating = false;
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.05f); //has to be within +-0.05"  

  //println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  //println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  //println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  //println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
