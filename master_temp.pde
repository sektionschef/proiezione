//Libraries

//int[] element_names = new int[17]; // create array with element ids of svg
int element_count = 17;


//Objects
Table scheme; //table

//shapes
PShape canvas;
//PShape[] element = new PShape[scheme.getColumnCount()]; //declare them all at once
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
  size(500,500); //P3D important for keystone, since it relies on texture mapping to deform
  colorMode(HSB); //change the color mode, so the whole color change thing is easier
    
  //get svg elements
  canvas = loadShape( svg_path ); //load the svg
//  rect_a = canvas.getChild("a"); //archive for getting child
  for (int i = 0; i < element_count; i++) {
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
  
  
  for (int i = 0; i < element_count; i++) {           
      element[i].disableStyle();
      fill((hue[i]), 99, 188); 
      noStroke(); 
      shape( element[i], 0 ,-552); //552px keine Ahnung wieso - wahrscheinlich beim Verkleinern von 1000 auf 500
  }  
}


// MOUSE INSTEAD OF ARDUINO
void mousePressed(){ // pressing the mouse
  surp+=1; 
  //println(surp); 
}



