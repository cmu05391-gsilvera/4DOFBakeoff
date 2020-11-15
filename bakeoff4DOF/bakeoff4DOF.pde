import java.util.ArrayList;
import java.util.Collections;
import java.util.*;
import java.util.Optional;

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


// Alt positioning
float topX = width/2.0;
float topY = height/2.0;
float botX = topX + logoZ;
float botY = topY + logoZ;
 

boolean holding = false;
boolean rotating = false;
boolean is_good = false;
int mx = mouseX - width/2;
int my = mouseY - height/2;

int clickIndex = 0;
float[][] clicks = new float[4][4];
int maxClick = 3;
boolean finalClick = false;

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
      if(closeD(d.x, d.y))
        stroke(0, 255, 0, 255);
      else
        stroke(255, 0, 0, 255);
      rect(0, 0, 50, 50);
      if(closeR(d.rotation) && closeZ(d.z))
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
  
  drawIndicator();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  //goodlogic();
  //scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

void gooderLogic() {
  if (clickIndex < 2) {
    print("adding click at index: ");
    println(clickIndex);
    float[] newClick = new float[2];
    newClick[0] = mouseX;
    newClick[1] = mouseY;
    clicks[clickIndex] = newClick;
    clickIndex++;
    if (clickIndex == maxClick) {
      newLogoPosFromClicks();
    }
  } else if (clickIndex == 2) {
    float v1X = clicks[0][0];
    float v1Y = clicks[0][1];
    float v2X = clicks[1][0];
    float v2Y = clicks[1][1];
    
    float dx = v1X - v2X;
    float dy = v1Y - v2Y;
    
    Optional<Float> slope = getSlope(v1X,v2X,v1Y,v2Y);
    float v3X; float v3Y;
    // Defined slope
    if (slope.isPresent()) {
      // Which side of the line are we on?
      float d = (mouseX - v1X)*(v2Y - v1Y) - (mouseY - v1Y)*(v2X - v1X);
      float dLeft = (mouseX - v1X - 1)*(v2Y - v1Y) - (mouseY - v1Y)*(v2X - v1X);
      println("d = ", d, "dLeft = ", dLeft);
      if (d > 0) {
        // We are on the left side of the line
        if (dLeft > 0) {
          v3X = v2X - dy;
          v3Y = v2Y + dx;
        // We are on the right side of the line
        } else {
          v3X = v2X + dy;
          v3Y = v2Y - dx;
        }
        
      } else {
        // We are on the left side of the line
        if (dLeft < 0) {
          v3X = v2X + dy;
          v3Y = v2Y - dx;
        // We are on the right side of the line
        } else {
          v3X = v2X + dy;
          v3Y = v2Y - dx;
        }
      }
    // Undefined slope
    } else {
      v3Y = v2Y;
      if (mouseX > v2X) v3X = v2X - dy;
      else v3X = v2X + dy;
    }
    float v4X = v3X + dx;
    float v4Y = v3Y + dy;
    
    clicks[2][0] = v3X; clicks[2][1] = v3Y;
    clicks[3][0] = v4X; clicks[3][1] = v4Y;
    
    setDetectionInfo();
    
    finalClick = true;
    clickIndex = 0;
  }
  
}

void drawIndicator() {
  
  switch (clickIndex) {
    case 1: {
      // Draw the point that we clicked
      int i = 0;
      float clickX = clicks[i][0];
      float clickY = clicks[i][1];
      fill(255,0,255);
      ellipse(clickX, clickY, 10, 10);
      // Draw a line from the point to the cursor
      strokeWeight(3);
      stroke(0,50,230);
      line(clickX,clickY, mouseX,mouseY);
      break;
    }
    case 2: {
      fill(0,0,255);
      strokeWeight(0);
      beginShape();
      float v1X = clicks[0][0];
      float v1Y = clicks[0][1];
      float v2X = clicks[1][0];
      float v2Y = clicks[1][1];
      float dx = v1X - v2X;
      float dy = v1Y - v2Y;
      println("dy = ", dy, "dx = ", dx);
      Optional<Float> slope = getSlope(v1X,v2X,v1Y,v2Y);
      float v3X; float v3Y;
      // Defined slope
      if (slope.isPresent()) {
        // Which side of the line are we on?
        float d = (mouseX - v1X)*(v2Y - v1Y) - (mouseY - v1Y)*(v2X - v1X);
        float dLeft = (mouseX - v1X - 1)*(v2Y - v1Y) - (mouseY - v1Y)*(v2X - v1X);
        println("d = ", d, "dLeft = ", dLeft);
        if (d > 0) {
          // We are on the left side of the line
          if (dLeft > 0) {
            v3X = v2X - dy;
            v3Y = v2Y + dx;
          // We are on the right side of the line
          } else {
            v3X = v2X + dy;
            v3Y = v2Y - dx;
          }
          
        } else {
          // We are on the left side of the line
          if (dLeft < 0) {
            v3X = v2X + dy;
            v3Y = v2Y - dx;
          // We are on the right side of the line
          } else {
            v3X = v2X + dy;
            v3Y = v2Y - dx;
          }
        }
      // Undefined slope
      } else {
        v3Y = v2Y;
        if (mouseX > v2X) v3X = v2X - dy;
        else v3X = v2X + dy;
      }
      float v4X = v3X + dx;
      float v4Y = v3Y + dy;
      vertex(v1X,v1Y);
      vertex(v2X,v2Y);
      vertex(v3X,v3Y);
      vertex(v4X,v4Y);
      endShape(CLOSE);
      break;
    }
    // If we haven't clicked yet, just show the old logo
    default: {
      fill(0,0,255,50);
      strokeWeight(0);
      //beginShape();
      //float v1X = clicks[0][0];
      //float v1Y = clicks[0][1];
      //float v2X = clicks[1][0];
      //float v2Y = clicks[1][1];
      //float v3X = clicks[2][0];
      //float v3Y = clicks[2][1];
      //float v4X = clicks[3][0];
      //float v4Y = clicks[3][1];
      //vertex(v1X,v1Y);
      //vertex(v2X,v2Y);
      //vertex(v3X,v3Y);
      //vertex(v4X,v4Y);
      //endShape(CLOSE);
      pushMatrix();
      translate(width/2, height/2); //center the drawing coordinates to the center of the screen
      translate(logoX, logoY);
      rotate(radians(logoRotation));
      noStroke();
      rect(0, 0, logoZ, logoZ);
      popMatrix();
      break;
    }

  }
  
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
  gooderLogic();
  
}


void mouseReleased()
{ 
  //check to see if user clicked with the right mouse button (cancel)
  if (mouseButton==RIGHT)
  {
    clickIndex = 0;
  }
  //check to see if user clicked with the right mouse button (cancel)
  if (finalClick && mouseButton==LEFT)
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
  
  finalClick = false;
}

void setDetectionInfo() {
  float v1X = clicks[0][0];
  float v1Y = clicks[0][1];
  float v2X = clicks[1][0];
  float v2Y = clicks[1][1];
  float v3X = clicks[2][0];
  float v3Y = clicks[2][1];
  
  float dx = v1X - v2X;
  float dy = v1Y - v2Y;
  
  //double cSquared = Math.pow(dx,2) + Math.pow(dy,2);
  
  logoZ = dist(v1X,v1Y,v2X,v2Y);
  
  Optional<Float> slopeOpt = getSlope(v1X,v3X,v1Y,v3Y);

  if (slopeOpt.isPresent()) {
    float slope = slopeOpt.get();
    float yInt1 = getYIntercept(slope,v1X,v1Y);
    if (slope == 0) {
      logoX = v1X + dx/2;
      logoY = v1Y;
    } else {
     float perpSlope = -1/slope;
     float yInt2 = getYIntercept(perpSlope,v2X,v2Y);
     logoX = (yInt2 - yInt1)/(slope - perpSlope);
     logoY = logoX*perpSlope + yInt2;
    }
   
  } else {
    logoX = v1X;
    logoY = v1Y + dy/2;
  }
  
  logoRotation = degrees((float)Math.atan2(v1Y - v2Y, v1X - v2X));
  
}

Optional<Float> getSlope(float x1, float x2, float y1, float y2) {
  float dy = (y2 - y1);
  float dx = (x2 - x1);
  if (dx == 0) {
    return Optional.empty();
  } else {
    return Optional.of(dy/dx);
  }
}

float getYIntercept(float slope, float x, float y) {
  return (y - (slope*x));
}

void newLogoPosFromClicks() {
  float[] click0 = clicks[0];
  topX = click0[0]; topY = click0[1];
  click0 = clicks[1];
  botX = click0[0]; botY = click0[1];
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
