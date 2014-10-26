//Libraries
import deadpixel.keystone.*; //keystone library
import processing.serial.*; //arduino
import cc.arduino.*; //arduino

//variables
int buttonPin = 2; //arduino read pin
int buttonState; //arduino switch
int lastButtonState = 0; //last moment button state, needed for the switch

String svg_path = "canvas_sketch_postpainting.svg"; //path to svg of canvas
int boring = 0; //start hue loop from; first column
int zone_count = 5; // number of zones in csv
int element_count = 22;// number of elements in svg, mind that the loop starts at 0
int width = 600; //width of canvas - 120*5
int height = 400; //height of canvas - 80*5

int time; //time from start, for the delay
int wait = 10*1000; //milliseconds - delay for changing colours 

String table_path = "scheme.csv"; //path to table with colors
int surp = 0; //starting line of color csv table
//int[] element_names = new int[17]; // create array with element ids of svg
int[] hue = new int[element_count]; //array for colour levles
int whiteout = 0; //0-255 more brightness for the whole image

//Objects
Keystone ks; //keystone
CornerPinSurface surface; //keystone
Arduino arduino;
Table scheme; //table, load csv

PGraphics offscreen;

//shapes
PShape canvas;
//PShape[] element = new PShape[scheme.getColumnCount()]; //declare them all at once - column count not possible because table not loaded at this stage
PShape[] element = new PShape[element_count]; //declare them all at once - Achtung 


//
///////////////////////////////// SETUP ////////////////////////////////
//
void setup() {
  size(displayWidth, displayHeight,P3D); //P3D important for keystone, since it relies on texture mapping to deform; fill screen
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20); //height, width, distance grid
  
  //Arduino Setup
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(buttonPin, Arduino.INPUT);
    
//  colorMode(HSB); //change the color mode, so the whole color change thing is easier - still needed?

  // We need an offscreen buffer to draw the surface we
    // want projected
    // note that we're matching the resolution of the
    // CornerPinSurface.
    // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(displayWidth, displayHeight, P3D);
    
  //get svg elements
  canvas = loadShape( svg_path ); //load the svg
//  rect_a = canvas.getChild("a"); //archive for getting child
  for (int i = 0; i < element_count; i++) { //get all the children at once
      element[i] = canvas.getChild(str(i)); // Initialize each object with the ID of the svg; convert it to string so it is accepted
      element[i].scale(0.5);// scale, which percentage
  }
  
  scheme = loadTable( table_path, "header");
  println(scheme.getRowCount() + " total rows in table"); //debug, Anzahl Rows

  time = millis();//store the current time
}

//
///////////////////////////////// DRAW ////////////////////////////////
//
void draw() {
  buttonState = arduino.digitalRead(buttonPin);
  background(0); //background black, so there is nothing in the projection
  
  TableRow axel_row = scheme.getRow(surp%scheme.getRowCount()); //initialize a single row manually chosen, use the modulo to restrict the surp not exceeding the row count
//    println(axel_row); //debug
 
 int[][] zone = { //number of elements for the five zones 
                     {6,10,16},
                     {0,3,14,18},
                     {4,7,9,13,15,17},
                     {1,8,12,20,21},
                     {2,5,11,19}  
                   };
// println(zone[0]);

  for (int i = 0; i < zone_count; i++) { //loop for the five zones
    int r = (i+boring)%5; //the color is swapped but the cycle stays between 0 and 5
    for (int z = 0; z < zone[i].length ; z++) {
      //println(r);
      //println(zone[i][z]);    
      hue[zone[i][z]] = unhex("ff"+axel_row.getString(r)); //get value for each element and write it in an array; getString for unhexing; mode is ARGB! so put "ff in front for full colour (in format "ff"+"2d495e") 
    }
  }


  println(axel_row.getString(zone_count)); //artist
  println(axel_row.getString(zone_count+1)); //palette
  

  
  offscreen.beginDraw();
  
  for (int i = 0; i < element_count; i++) {           
      element[i].disableStyle();
      offscreen.fill(hue[i]);
      offscreen.noStroke(); 
      offscreen.shape( element[i], 0 ,125); //552, 122 oder 0px deviance, no idea why - probably because of rescaling from 1000 to 500; for offscreen (keystoning) it takes 0 instead of -552px for y)
  }  
  
  // add a white rectengular for softening the colours in total, transparency value = whiteout
  offscreen.fill(255,255,255,whiteout);
  offscreen.noStroke();
  offscreen.rect(0,0,width,height);
  
  
  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  PVector surfaceMouse = surface.getTransformedMouse();
  
  offscreen.endDraw();
 
  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);     
  
  // compare the buttonState to its previous state
  if (buttonState != lastButtonState) {
    // if the state has changed, increment the counter
    if (buttonState == 1) {
      // if the current state is 1 then the button
      // wend from off to on:
      surp+=1;
      println("button pressed");//debug
    }
  }
  
  // save the current state as the last state, 
  //for next time through the loop
  lastButtonState = buttonState;

  //TIMED COLOR CHANGE
  if(millis() - time >= wait){ //delay loop
    println("tick");
    boring+=1;
    
    time = millis();//update the stored time
  }

}


// MOUSE INSTEAD OF ARDUINO
/*
void mousePressed(){ // pressing the mouse
  surp+=1; 
  //println(surp); 
}
*/

void keyPressed() { //function for keystone
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;

  case 'w':
    if (whiteout < 255) {
      whiteout+=15;
      println("whiteout: " + whiteout);
    }
    break;
  case 'b':
    if (whiteout > 0) {
      whiteout-=15;
      println("whiteout: " + whiteout);
    }  
    break;
  case 'p':
    surp+=1;
    println("p pressed");//debug
    break;
  }   
}

