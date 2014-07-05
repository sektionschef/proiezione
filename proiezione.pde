//Libraries
import deadpixel.keystone.*; //keystone library
import processing.serial.*; //arduino
import cc.arduino.*; //arduino

//variables
int buttonPin = 2; //arduino read pin
int buttonState; //arduino switch
int lastButtonState = 0; //last moment button state, needed for the swicht

String svg_path = "canvas_sketch_postpainting.svg"; //path to svg of canvas
int element_count = 22;// number of elements in svg, mind that the loop starts at 0
int width = 600; //width of canvas - 120*5
int height = 400; //height of canvas - 80*5

String table_path = "scheme.csv"; //path to table with colors
int surp = 0; //starting line of color csv table
//int[] element_names = new int[17]; // create array with element ids of svg
int[] hue = new int[element_count]; //array for colour levles
int whiteout = 100; //0-255 more brightness for the whole image

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
}

//
///////////////////////////////// DRAW ////////////////////////////////
//
void draw() {
  buttonState = arduino.digitalRead(buttonPin);
  background(0); //background black, so there is nothing in the projection
  
  TableRow axel_row = scheme.getRow(surp%scheme.getRowCount()); //initialize a single row manually chosen, use the modulo to restrict the surp not exceeding the row count
//    println(axel_row); //debug
  for (int i = 0; i < element_count; i++) { //for each element 
    hue[i] = unhex("ff"+axel_row.getString(i)); //get value for each element and write it in an array; getString for unhexing; mode is ARGB! so put "ff in front for full colour (in format "ff"+"2d495e") 
   //println(hue[i]); //debug
  }
  
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
  
  // Draw the scene, offscreen - mouse pointer, nor really needed for me
  /*
  offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);
  offscreen.noStroke(); 
  offscreen.fill(125,141,212);
 */
  
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

//  case 'w':

  }   
}


