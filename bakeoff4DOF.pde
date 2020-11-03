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
boolean top_right = false;
boolean bottom_left = false;
boolean is_good = false;
int mx = mouseX - width/2;
int my = mouseY - height/2;
// anchors
// top right anchor
float anchorTRX = logoZ/2.0 + logoX;
float anchorTRY = -logoZ/2.0 + logoY;
// bottom left anchor
float anchorBLX = -logoZ/2.0 + logoX;
float anchorBLY = logoZ/2.0 + logoY;
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
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}

boolean closeD(float x, float y){
 return dist(x, y, logoX, logoY)<inchToPix(.05f); 
}

boolean closeZ(float z){
 return abs(z - logoZ)<inchToPix(.05f); 
}

boolean closeR(float rotation){
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
    if (trialIndex==i){
      //if(closeD(d.x, d.y))
      //  stroke(0, 255, 0, 255);
      //else
      //  stroke(255, 0, 0, 255);
      //rect(0, 0, 50, 50);
      if(closeD(d.x, d.y) && closeR(d.rotation) && closeZ(d.z))
        stroke(0, 255, 0, 192);
      else
        stroke(255, 0, 0, 192); //set color to semi translucent
    }
    else
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
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  // draw corner buttons
  if(top_right)
    fill(0, 255, 0, 255);
  else
    fill(255, 255, 255, 192);
  ellipse(logoZ/2.0, -logoZ/2.0, 10, 10);
  if(bottom_left)
    fill(0, 255, 0, 255);
  else
    fill(0, 0, 0, 192);
  ellipse(-logoZ / 2.0, logoZ / 2.0, 10, 10);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  goodlogic();
  //scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

void goodlogic(){
  if(top_right){
    float anchorX = anchorBLX;
    float anchorY = anchorBLY;
    float angle = (float)Math.atan2(my - anchorY, mx - anchorX);
    logoRotation = degrees(angle) + 45;
    logoZ = dist(mx, my, anchorX, anchorY) / ((float)Math.sqrt(2));
    logoX = 0.5*(float)Math.cos(angle) * dist(mx, my, anchorX, anchorY) + anchorX;
    logoY = 0.5*(float)Math.sin(angle) * dist(mx, my, anchorX, anchorY) + anchorY; 
  }
  else if(bottom_left){
    float anchorX = anchorTRX;
    float anchorY = anchorTRY;
    float angle = (float)Math.atan2(my - anchorY, mx - anchorX);
    logoRotation = degrees(angle) + 45+180;
    logoZ = dist(mx, my, anchorX, anchorY) / ((float)Math.sqrt(2));
    logoX = 0.5*(float)Math.cos(angle) * dist(mx, my, anchorX, anchorY) + anchorX;
    logoY = 0.5*(float)Math.sin(angle) * dist(mx, my, anchorX, anchorY) + anchorY; 
  }
  // debug stuffs
  //System.out.println("Rot:" + logoRotation);
  //System.out.println("X:" + logoX + " Y:" + logoY);
  //System.out.println("Z:" + logoZ);
  // always check because why not
  //is_good = checkForSuccess();
}

boolean within_range(float x, float y, float x2, float y2, float range){
 return (x > x2 - range && x < x2 + range && y > y2 - range && y < y2 + range); 
}


void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  if(mouseButton==LEFT){
    float hold_range = 0.2*logoZ;
    // rotation translations to keep with everything else
    float theta =  radians(logoRotation);
    float TRX = ((float)Math.cos(theta) * (logoZ / 2.0) - (float)Math.sin(theta)*(-logoZ / 2.0) + logoX);
    float TRY = ((float)Math.sin(theta) * (logoZ / 2.0) + (float)Math.cos(theta)*(-logoZ / 2.0) + logoY);
    float BLX = ((float)Math.cos(theta) * (-logoZ / 2.0) - (float)Math.sin(theta)*(logoZ / 2.0) + logoX);
    float BLY = ((float)Math.sin(theta) * (-logoZ / 2.0) + (float)Math.cos(theta)*(logoZ / 2.0) + logoY);
    //ellipse(TRX, TRY, 10, 10);
    if(within_range(mx, my, TRX, TRY, hold_range)){
      top_right = true;
      bottom_left = false;
    }
    else{
      top_right = false;
      // bottom left
      if(within_range(mx, my, BLX, BLY, hold_range)){
        bottom_left = true;
        top_right = false;
      }
      else{
        bottom_left = false;
      }
    }
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
  if(top_right){
    anchorTRX=mx;
    anchorTRY=my;
  }
  top_right = false;
  if(bottom_left){
    anchorBLX=mx;
    anchorBLY=my;
  }
  bottom_left = false;
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.05f); //has to be within +-0.05"  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

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
