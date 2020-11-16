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
 
// Two corners stuff
boolean holding = false;
boolean rotating = false;
boolean is_good = false;

// Alt mouse to account for translations
int mx = mouseX - width/2;
int my = mouseY - height/2;

// Animation vars
float dPrev = 0;
float lineToSquareFrames = 0;
float lineToSquareMaxFrames = 15;
float collapseSquareFrames = 0;
float collapseSquareMaxFrames = 15;

// Storing clicks
int clickIndex = 0;
float[][] points = new float[4][4];
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
  
  //===========DRAW LOGO SQUARE=================
  drawIndicator();

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
      if(closeR(d.rotation) && closeZ(d.z) && closeD(d.x, d.y))
        stroke(0, 255, 0, 192);
      else
        stroke(255, 0, 0, 192); //set color to semi translucent
    }
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }
  drawIndicatorCorners();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  //goodlogic();
  //scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}
boolean within_range(float x, float y, float x2, float y2, float range){
  return (x > x2 - range && x < x2 + range && y > y2 - range && y < y2 + range); 
}
void drawIndicatorCorners(){
  // calculate corners from the center of the squares
  int thresh = 3;// pixels radius
  Destination d = destinations.get(trialIndex);
  float rot = d.rotation;
  float Z= d.z;
  float X = d.x;
  float Y = d.y;
  
  float theta =  radians(rot);
  float TRX = ((float)Math.cos(theta) * (Z / 2.0) - (float)Math.sin(theta)*(-Z / 2.0)) + X;
  float TRY = ((float)Math.sin(theta) * (Z / 2.0) + (float)Math.cos(theta)*(-Z / 2.0)) + Y;
  
  float BLX = ((float)Math.cos(theta) * (-Z / 2.0) - (float)Math.sin(theta)*(Z / 2.0)) + X;
  float BLY = ((float)Math.sin(theta) * (-Z / 2.0) + (float)Math.cos(theta)*(Z / 2.0)) + Y;
  
  float TLX = ((float)Math.cos(theta) * (Z / 2.0) - (float)Math.sin(theta)*(Z / 2.0)) + X;
  float TLY = ((float)Math.sin(theta) * (Z / 2.0) - (float)Math.cos(theta)*(-Z / 2.0)) + Y;
  
  float BRX = ((float)Math.cos(theta) * (-Z / 2.0) + (float)Math.sin(theta)*(Z / 2.0)) + X;
  float BRY = ((float)Math.sin(theta) * (-Z / 2.0) + (float)Math.cos(theta)*(-Z / 2.0)) + Y;
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(X, Y);
  rotate(theta);
  noStroke();
  // top right
  if(within_range(mx, my, TRX, TRY, thresh))
    fill(0, 255, 0, 255); 
  else
    fill(0, 0, 0, 255);
  ellipse(Z/2.0, -Z/2.0, 10, 10);
  // top left
  if(within_range(mx, my, TLX, TLY, thresh))
    fill(0, 255, 0, 255); 
  else
    fill(0, 0, 0, 255);
  ellipse(Z/2.0, Z/2.0, 10, 10); 
  // bottom right
  if(within_range(mx, my, BRX, BRY, thresh))
    fill(0, 255, 0, 255); 
  else
    fill(0, 0, 0, 255);
  ellipse(-Z/2.0, -Z/2.0, 10, 10); 
  // bottom left
  if(within_range(mx, my, BLX, BLY, thresh))
    fill(0, 255, 0, 255); 
  else
    fill(0, 0, 0, 255);
  ellipse(-Z/2.0, Z/2.0, 10, 10); 
  popMatrix();
}

void gooderLogic() {  
  
  // If we're drawing points/lines
  if (clickIndex < 2) {
    float[] newClick = new float[2];
    newClick[0] = mx;
    newClick[1] = my;
    points[clickIndex] = newClick;
    // Advance
    clickIndex++;
    
  // If we're dynamically drawing the square
  } else if (clickIndex == 2) {
    float v1X = points[0][0];
    float v1Y = points[0][1];
    float v2X = points[1][0];
    float v2Y = points[1][1];
    
    float dx = v1X - v2X;
    float dy = v1Y - v2Y;
    
    Optional<Float> slope = getSlope(v1X,v2X,v1Y,v2Y);
    float v3X; float v3Y;
    // Defined slope
    if (slope.isPresent()) {
      // Which side of the line are we on?
      float d = (mx - v1X)*(v2Y - v1Y) - (my - v1Y)*(v2X - v1X);
      float dLeft = (mx - v1X - 1)*(v2Y - v1Y) - (my - v1Y)*(v2X - v1X);
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
      if (mx > v2X) v3X = v2X - dy;
      else v3X = v2X + dy;
    }
    float v4X = v3X + dx;
    float v4Y = v3Y + dy;
    
    points[2][0] = v3X; points[2][1] = v3Y;
    points[3][0] = v4X; points[3][1] = v4Y;
    
    // Convert to point/length/rotation format
    setDetectionInfo();
    
    // Advance
    clickIndex++;
    
  // If we need to accept/reject the square
  
  } else if (clickIndex == 3) {
    // Reset the square
    clickIndex = 0;
    // If we clicked inside the square then advance
    if (containsWrapper(points, mouseX - width/2, mouseY - height/2)) {
      finalClick = true;
    }
    
    
  }
  
}

void drawIndicator() {
  
  switch (clickIndex) {
    // After one click draw a line from the first point to mx/my
    case 0: {
      fill(0,0,255,50);
      strokeWeight(0);
      pushMatrix();
      translate(width/2, height/2); //center the drawing coordinates to the center of the screen
      translate(mx, my);
      rotate(radians(logoRotation));
      noStroke();
      rect(0, 0, logoZ, logoZ);
      popMatrix();
      // Rest square collapse animation
      collapseSquareFrames = 0;
      break;
    }
    case 1: {
      if (collapseSquareFrames < collapseSquareMaxFrames - 1) {
        float collapseFactor = (collapseSquareFrames/collapseSquareMaxFrames);
        fill(0,0,255,50);
        strokeWeight(0);
        pushMatrix();
        translate(width/2, height/2); //center the drawing coordinates to the center of the screen
        translate(mx, my);
        rotate(radians(logoRotation));
        noStroke();
        rect(0, 0, logoZ - logoZ*collapseFactor, logoZ - logoZ*collapseFactor);
        popMatrix();
        collapseSquareFrames++;
      } else {
        // Get the point that we clicked
        int i = 0;
        float clickX = points[i][0];
        float clickY = points[i][1];
        //fill(255,0,255);
        //ellipse(clickX + width/2, clickY+height/2, 10, 10);
        // Draw a line from the point we clicked to the cursor
        strokeWeight(3);
        stroke(0,50,230);
        line(clickX+width/2,clickY+height/2, mouseX,mouseY);
        // Reset lineToSquare animation
        lineToSquareFrames = 0;
      }
      break;
    }
    // If we've clicked twice draw a moving square
    case 2: {
      float v1X = points[0][0];
      float v1Y = points[0][1];
      float v2X = points[1][0];
      float v2Y = points[1][1];
      float dx = v1X - v2X;
      float dy = v1Y - v2Y;
      float v3X; float v3Y;
        
      // Decide which side of the line we are on
      float d = (mx - v1X)*(v2Y - v1Y) - (my - v1Y)*(v2X - v1X);
      
      // If we just switched sides reset the animation
      if ((dPrev > 0 && d <= 0) || (dPrev <= 0 && d > 0)) {
        //lineToSquareFrames = 0;
        lineToSquareFrames = -lineToSquareFrames;
      }
      
      // Incremement but constrain the drawFactor
      lineToSquareFrames += 1; lineToSquareFrames = min(lineToSquareFrames, lineToSquareMaxFrames);
      
      float drawFactor = (lineToSquareFrames/lineToSquareMaxFrames);
      println("drawFactor = ", drawFactor);
      dPrev = d;
      float dLeft = (mx - v1X - 1)*(v2Y - v1Y) - (my - v1Y)*(v2X - v1X);
      
      // Set the draw factor - how much of the square we draw
      //float drawFactor = (lineToSquareFrames/lineToSquareMaxFrames);
      if (d > 0) {
        println("deez > 0");
        // We are on the left side of the line
        if (dLeft > 0) {
          println("we on that left side");
          v3X = v2X - dy*drawFactor;
          v3Y = v2Y + dx*drawFactor;
        // We are on the right side of the line
        } else {
          println("we on that right side");
          v3X = v2X + dy*drawFactor;
          v3Y = v2Y - dx*drawFactor;
        }
        
      } else {
        println("deez <= 0");
        // We are on the left side of the line
        if (dLeft < 0) {
          println("we on that right side");
          v3X = v2X + dy*drawFactor;
          v3Y = v2Y - dx*drawFactor;
        // We are on the right side of the line
        } else {
          println("we on that left side");
          v3X = v2X + dy*drawFactor;
          v3Y = v2Y - dx*drawFactor;
        }
      }
      
      // Set V4 based on V3
      float v4X = v3X + dx;
      float v4Y = v3Y + dy;
      
      // Draw Shape
      fill(0,0,255);
      strokeWeight(0);
      beginShape();
      vertex(v1X+width/2,v1Y+height/2);
      vertex(v2X+width/2,v2Y+height/2);
      vertex(v3X+width/2,v3Y+height/2);
      vertex(v4X+width/2,v4Y+height/2);
      endShape(CLOSE);
      break;
    }
    // If we've placed the square but still need to confirm TODO (this is dead code)
    case 3: {
      fill(0,0,255);
      strokeWeight(0);
      pushMatrix();
      translate(width/2, height/2); //center the drawing coordinates to the center of the screen
      translate(logoX, logoY);
      rotate(radians(logoRotation));
      noStroke();
      rect(0, 0, logoZ, logoZ);
      popMatrix();
      break;
    }
    
    // If we haven't clicked yet, collapse the old logo 
    default: {
      fill(0,0,255,50);
      strokeWeight(0);
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
  println("clickIndex = ", clickIndex);
  gooderLogic();
  
}


void mouseReleased()
{ 
  //check to see if the trial was advanced
  if (finalClick)
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
  float v1X = points[0][0];
  float v1Y = points[0][1];
  float v2X = points[1][0];
  float v2Y = points[1][1];
  float v3X = points[2][0];
  float v3Y = points[2][1];
  
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

// Bounds checking for rect accept/reject


class Point  
{ 
    int x; 
    int y; 

    public Point(int x, int y) 
    { 
        this.x = x; 
        this.y = y; 
    } 
}; 

// Taken from stack overflow https://stackoverflow.com/questions/8721406/how-to-determine-if-a-point-is-inside-a-2d-convex-polygon
boolean contains(Point polygon[], Point test) {
  int i;
  int j;
  boolean result = false;
  for (i = 0, j = points.length - 1; i < points.length; j = i++) {
    if ((polygon[i].y > test.y) != (polygon[j].y > test.y) &&
        (test.x < (polygon[j].x - polygon[i].x) * (test.y - polygon[i].y) / (polygon[j].y-polygon[i].y) + polygon[i].x)) {
      result = !result;
     }
  }
  return result;
}

boolean containsWrapper(float[][] shape, float px, float py) {
  Point p = new Point((int)px,(int)py);
  Point polygon[] = new Point[4];
  for (int i = 0; i < 4; i++) {
    Point curr = new Point((int)shape[i][0], (int)shape[i][1]);
    println("i = ", i, "; (", shape[i][0], " ", shape[i][1], ")");
    polygon[i] = curr;
  }
  println("px = ", px, "; py = ", py);
  return contains(polygon, p);
}
