//Libraries
import deadpixel.keystone.*; //keystone library

//int[] element_names = new int[17]; // create array with element ids of svg
int element_count = 17;


//Objects
Keystone ks; //keystone
CornerPinSurface surface; //keystone
Table scheme; //table, load csv

PGraphics offscreen;

//shapes
PShape canvas;
//PShape[] element = new PShape[scheme.getColumnCount()]; //declare them all at once - column count not possible because table not loaded at this stage
PShape[] element = new PShape[element_count]; //declare them all at once - Achtung 


//variables
String svg_path = "canvas.svg"; //path to svg
int sau; //arduino switch
int surp = 0; //increase of colour
int[] hue = new int[element_count]; //array for colour levles

//
///////////////////////////////// SETUP ////////////////////////////////
//
void setup() {
  size(500,500,P3D); //P3D important for keystone, since it relies on texture mapping to deform
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(500, 500, 20);
  
  colorMode(HSB); //change the color mode, so the whole color change thing is easier

  // We need an offscreen buffer to draw the surface we
    // want projected
    // note that we're matching the resolution of the
    // CornerPinSurface.
    // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(500, 500, P3D);
    
  //get svg elements
  canvas = loadShape( svg_path ); //load the svg
//  rect_a = canvas.getChild("a"); //archive for getting child
  for (int i = 0; i < element_count; i++) { //get all the children at once
      element[i] = canvas.getChild(str(i)); // Initialize each object with the ID of the svg; convert it to string so it is accepted
  }
  
  scheme = loadTable("scheme.csv", "header");
  //println(scheme.getRowCount() + " total rows in table"); //debug, Anzahl Rows
}

//
///////////////////////////////// DRAW ////////////////////////////////
//
void draw() {
  //sau = arduino.digitalRead(buttonPin);
  background(0);
  
  TableRow axel_row = scheme.getRow(surp%scheme.getRowCount()); //initialize a single row manually chosen, use the modulo to restrict the surp not exceeding the row count
    //println(axel_row); //debug
  for (int i = 0; i < element_count; i++) { //for each element
    hue[i] = axel_row.getInt(i); //get value for each element and write it in an array
    //println(hue[i]); //debug
  }
  
  offscreen.beginDraw();
  
  for (int i = 0; i < element_count; i++) {           
      element[i].disableStyle();
      fill((hue[i]), 99, 188); 
      noStroke(); 
      shape( element[i], 0 ,0); //552px keine Ahnung wieso - wahrscheinlich beim Verkleinern von 1000 auf 500; bei offscreen (keystoning) benötigt man 0 statt -552px auf y)
  }  
  
  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  PVector surfaceMouse = surface.getTransformedMouse();
  
  // Draw the scene, offscreen
  offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);
 
  offscreen.noStroke(); 
  offscreen.fill(125,141,212); 

  offscreen.endDraw();
 
  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);    
}


// MOUSE INSTEAD OF ARDUINO
void mousePressed(){ // pressing the mouse
  surp+=1; 
  //println(surp); 
}



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
  }   
}

