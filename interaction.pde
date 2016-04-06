ControlP5 cp5;
ControllerGroup lengthGroup;
ControllerGroup scalesGroup;
ControllerGroup saveLoadGroup;
ControllerGroup playheadsGroup;

Storage store;
XML tuneXml;

int defaultBgColor = color(2,46,92);
int highlightColor = color(244,144,24);

int xOffset;
int titleOffset;

float s;
int o;

void setupGui() {
  cp5 = new ControlP5(this);

  createBottomButtons();
  createLengthGroup();

  createScalesGroup();
  updateScalesGroup();

  createSaveLoadGroup();
  updateSaveLoadGroup();

  createPlayheadsGroup();
  updatePlayheadsGroup();
}

void mouseDragged() {
  if(stave.alteringLength) {
    stave.updateWidthFromAbs(mouseX);
    playheadManager.updatePlayheadsToWidth();
  }
}

void mousePressed() {
  if(stave.insideStave(mouseX,mouseY)) {
    stave.click(mouseX, mouseY);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  playheadManager.modifyPositionBy(e);
}

public void lengthButton(int theValue) {
  if(lengthGroup.isVisible()) {
    lengthGroup.hide();
    stave.stopAlteringLength();
  } else {
    scalesGroup.hide();
    saveLoadGroup.hide();
    playheadsGroup.hide();
    lengthGroup.show();
    stave.startAlteringLength();
  }
}

public void scalesButton(int theValue) {
  if(scalesGroup.isVisible()) {
    scalesGroup.hide();
    saveLoadGroup.hide();
    playheadsGroup.hide();
    stave.canEdit = true;
  } else {
    lengthGroup.hide();
    stave.stopAlteringLength();

    saveLoadGroup.hide();
    
    updateScalesGroup();
    scalesGroup.show();
    stave.canEdit = false;
  }
}

public void saveLoadButton(int theValue) {
  if(saveLoadGroup.isVisible()) {
    saveLoadGroup.hide();
    stave.canEdit = true;
  } else {
    lengthGroup.hide();
    scalesGroup.hide();
    playheadsGroup.hide();
    stave.stopAlteringLength();
    
    updateSaveLoadGroup();
    saveLoadGroup.show();
    stave.canEdit = false;
  }
}

public void playheadsButton(int theValue) {
  if(playheadsGroup.isVisible()) {
    playheadsGroup.hide();
    stave.canEdit = true;
  } else {
    lengthGroup.hide();
    scalesGroup.hide();
    saveLoadGroup.hide();
    stave.stopAlteringLength();
    
    updatePlayheadsGroup();
    playheadsGroup.show();
    stave.canEdit = false;
  }
}



public void doneAlteringLengthBut() {
  lengthGroup.hide();
  stave.stopAlteringLength();
}

public void doneAlteringScalesBut() {
  scalesGroup.hide();
  stave.canEdit = true;
  soundbox.updateScaleSounds();
}

public void closeSaveLoadButton() {
  saveLoadGroup.hide();
  stave.canEdit = true;
}

public void resetButton() {
  soundbox.reset();
  stave.reset();
}

void createLengthGroup() {
  lengthGroup = cp5.addGroup("lengthGroup")
                   .setPosition(80,80)
                   .hideArrow()
                   .setCaptionLabel("Change Sequence Length")
                   .disableCollapse()
                   .setWidth(200)
                   .setBackgroundHeight(150)
                   .setBackgroundColor(color(0,128))
                   .hide()
                   ;

  cp5.addTextlabel("lengthLabel")
     .setText("Drag the orange marker to create a loop.")
     .setPosition(10,20)
     .setWidth(40)
     .setGroup(lengthGroup);
     ;

  cp5.addButton("doneAlteringLengthBut").setBroadcast(false)
     .setValue(101)
     .setPosition(10,100)
     .setSize(180,40)
     .setGroup(lengthGroup)
     .setCaptionLabel("Done!")
     .setBroadcast(true)
     ;
}

/*
 * Begin Scales Menu
 */

void createScalesGroup() {
  scalesGroup = cp5.addGroup("scalesGroup")
                   .setPosition(100,100)
                   .hideArrow()
                   .setCaptionLabel("Change Scale and Root")
                   .disableCollapse()
                   .setWidth(600)
                   .setBackgroundHeight(300)
                   .setBackgroundColor(color(0,128))
                   .hide()
                   ;

  String[] bottomScaleButtons = {"C", "D", "E", "F", "G", "A", "B"};

  for (int i = 0; i < bottomScaleButtons.length; i++) {
    String buttonName = "scale" + bottomScaleButtons[i] + "But";
    Button but = cp5.addButton(buttonName).setBroadcast(false)
     .setPosition((85 + (i*60)),100)
     .setSize(50,50)
     .setGroup(scalesGroup)
     .setCaptionLabel(bottomScaleButtons[i])
     .setBroadcast(true)
    ;
  }

  String[] topScaleButtons = {"C#", "Eb", "F#", "Ab", "Bb"};

  for (int i = 0; i < topScaleButtons.length; i++) {
    int skew = 0;
    if( i > 1) {
      skew = 65;
    }
    String functionSafeName = topScaleButtons[i].replace("#", "sharp").replace("b", "flat");
    String buttonName = "scale" + functionSafeName + "But";
    Button but = cp5.addButton(buttonName).setBroadcast(false)
     .setPosition((115 + (i*60) + skew),40)
     .setSize(50,50)
     .setGroup(scalesGroup)
     .setCaptionLabel(topScaleButtons[i])
     .setBroadcast(true)
    ;

    but.getCaptionLabel().toUpperCase(false);
  }

  String[] scaleTypes = { "major", "minor", "dorian", "lydian", "mixolydian", "phrygian", "locrian", "pentatonic", "blues"};

  for (int i = 0; i < scaleTypes.length; i++) {
    String buttonName = "scaleType" + scaleTypes[i] + "But";
    Button but = cp5.addButton(buttonName).setBroadcast(false)
     .setPosition((30 + (i*60)),170)
     .setSize(50,50)
     .setGroup(scalesGroup)
     .setCaptionLabel(scaleTypes[i])
     .setBroadcast(true)
    ;
  }

  // cp5.addTextlabel("label")
  //    .setText("Drag the orange marker to create a loop.")
  //    .setPosition(10,20)
  //    .setWidth(40)
  //    .setGroup(scalesGroup);
  //    ;

  cp5.addButton("doneAlteringScalesBut").setBroadcast(false)
     .setPosition(210,250)
     .setSize(180,40)
     .setGroup(scalesGroup)
     .setCaptionLabel("Done!")
     .setBroadcast(true)
     ;
}

/*
 * End Scales group
 */

/*
 * Begin saveLoad group
 */

void createSaveLoadGroup() {
  saveLoadGroup = cp5.addGroup("saveLoadGroup")
                   .setPosition(100,100)
                   .hideArrow()
                   .setCaptionLabel("Save / Load")
                   .disableCollapse()
                   .setWidth(600)
                   .setBackgroundHeight(300)
                   .setBackgroundColor(color(0,128))
                   .hide()
                   ;

  // create SAVE header
  cp5.addTextlabel("saveLabel")
     .setText("SAVE")
     .setPosition(125,50)
     .setGroup(saveLoadGroup)
     ;

  // create Save Buttons
  for (int i = 0; i < 8; i++) {
    String buttonName = "save" + (i+1) + "But";
    int yPos = 100;
    int xIndex = i;
    if(i > 3) {
      yPos = 170;
      xIndex = i - 4;
    }
    Button but = cp5.addButton(buttonName).setBroadcast(false)
     .setPosition((25 + (xIndex*60)),yPos)
     .setSize(50,50)
     .setGroup(saveLoadGroup)
     .setCaptionLabel(str(i+1))
     .setBroadcast(true)
    ;

    but.getCaptionLabel().setSize(12);
  }

  // create LOAD header
  cp5.addTextlabel("loadLabel")
     .setText("LOAD")
     .setPosition(425,50)
     .setGroup(saveLoadGroup)
     ;

  // create Load Buttons
  for (int i = 0; i < 8; i++) {
    String buttonName = "load" + (i+1) + "But";
    int yPos = 100;
    int xIndex = i;
    if(i > 3) {
      yPos = 170;
      xIndex = i - 4;
    }
    Button but = cp5.addButton(buttonName).setBroadcast(false)
     .setPosition((300 + 25 + (xIndex*60)),yPos)
     .setSize(50,50)
     .setGroup(saveLoadGroup)
     .setCaptionLabel(str(i+1))
     .setBroadcast(true)
    ;

    but.getCaptionLabel().setSize(12);
  }

  // button to close without loading
  cp5.addButton("closeSaveLoadButton").setBroadcast(false)
     .setPosition(210,250)
     .setSize(180,40)
     .setGroup(saveLoadGroup)
     .setCaptionLabel("Close")
     .setBroadcast(true)
     ;

  cp5.addButton("resetButton").setBroadcast(false)
     .setPosition(495,250)
     .setSize(60,40)
     .setGroup(saveLoadGroup)
     .setCaptionLabel("Reset")
     .setBroadcast(true)
     ;
}

/*
 * end save/load group
 */

/* 
 *begin playheads group
 */


void createPlayheadsGroup() {
  playheadsGroup = cp5.addGroup("playheadsGroup")
                   .setPosition(100,100)
                   .hideArrow()
                   .setCaptionLabel("Playheads")
                   .disableCollapse()
                   .setWidth(600)
                   .setBackgroundHeight(300)
                   .setBackgroundColor(color(0,128))
                   .hide()
                   ;

  // varialbse for control positioning
  int yOffset = 75;
  int yControlSpacing = 60;
  int controlWidth = 90;
  int controlHeight = 30;

  xOffset = 30;
  titleOffset = xOffset+30;

  // create controls for Playhead ONE
  // these should probably be locked
  cp5.addTextlabel("playheadOneLabel")
     .setText("ONE")
     .setPosition(titleOffset,30)
     .setGroup(playheadsGroup)
     ;

  cp5.addToggle("togglePlayheadOneDirection")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset)
     .setSize(controlWidth,controlHeight)
     .setValue(true)
     .setState(false) // false is forwards
     .setMode(ControlP5.SWITCH)
     .setCaptionLabel("Direction")
     .setLock(true)
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("togglePlayheadOneDirection").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create speed slider
  cp5.addSlider("playheadOneSpeed")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (1*yControlSpacing))
     .setSize(controlWidth,controlHeight)
     .setRange(0.25,4)
     .setValue(1)
     .setLock(true)
     .setCaptionLabel("Speed")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadOneSpeed").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadOneSpeed").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  // create speed slider
  cp5.addSlider("playheadOneOffset")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (2*yControlSpacing))
     .setSize(controlWidth, controlHeight)
     .setRange(0,400)
     .setValue(0)
     .setCaptionLabel("Offset")
     .setLock(true)
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadOneOffset").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadOneOffset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create enable toggle with label
  cp5.addToggle("enablePlayheadOne")
     .setBroadcast(false)
     .setPosition(xOffset,245)
     .setSize(controlWidth, 40)
     .setValue(true)
     .setState(true)
     .setCaptionLabel("ENABLE")
     .setLock(true)
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("enablePlayheadOne").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

   // create controls for Playhead TWO

  xOffset = 180;
  titleOffset = xOffset+30;


  cp5.addTextlabel("playheadTwoLabel")
     .setText("TWO")
     .setPosition(titleOffset,30)
     .setGroup(playheadsGroup)
     ;

  // create backward button
  // create forward button
  cp5.addToggle("togglePlayheadTwoDirection")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset)
     .setSize(controlWidth,controlHeight)
     .setValue(true)
     .setState(false) // false is forwards
     .setMode(ControlP5.SWITCH)
     .setCaptionLabel("Direction")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("togglePlayheadTwoDirection").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create speed slider
  cp5.addSlider("playheadTwoSpeed")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (1*yControlSpacing))
     .setSize(controlWidth,controlHeight)
     .setRange(0.25,4)
     .setValue(1)
     .setCaptionLabel("Speed")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadTwoSpeed").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadTwoSpeed").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  // create speed slider
  cp5.addSlider("playheadTwoOffset")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (2*yControlSpacing))
     .setSize(controlWidth, controlHeight)
     .setRange(0,400)
     .setValue(0)
     .setCaptionLabel("Offset")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadTwoOffset").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadTwoOffset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create enable toggle with label
  cp5.addToggle("enablePlayheadTwo")
     .setBroadcast(false)
     .setPosition(xOffset,245)
     .setSize(controlWidth, 40)
     .setValue(true)
     .setState(false) // false is forwards
     .setCaptionLabel("ENABLE")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("enablePlayheadTwo").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);


  // create controls for Playhead THREE

  xOffset = 330;
  titleOffset = xOffset+25;

  cp5.addTextlabel("playheadThreeLabel")
     .setText("THREE")
     .setPosition(titleOffset,30)
     .setGroup(playheadsGroup)
     ;

  // create backward button
  // create forward button
  cp5.addToggle("togglePlayheadThreeDirection")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset)
     .setSize(controlWidth,controlHeight)
     .setValue(true)
     .setState(false) // false is forwards
     .setMode(ControlP5.SWITCH)
     .setCaptionLabel("Direction")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("togglePlayheadThreeDirection").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create speed slider
  cp5.addSlider("playheadThreeSpeed")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (1*yControlSpacing))
     .setSize(controlWidth,controlHeight)
     .setRange(0.25,4)
     .setValue(1)
     .setCaptionLabel("Speed")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadThreeSpeed").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadThreeSpeed").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  // create speed slider
  cp5.addSlider("playheadThreeOffset")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (2*yControlSpacing))
     .setSize(controlWidth, controlHeight)
     .setRange(0,400)
     .setValue(0)
     .setCaptionLabel("Offset")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadThreeOffset").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadThreeOffset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create enable toggle with label
  cp5.addToggle("enablePlayheadThree")
     .setBroadcast(false)
     .setPosition(xOffset,245)
     .setSize(controlWidth, 40)
     .setValue(true)
     .setState(false) // false is forwards
     .setCaptionLabel("ENABLE")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("enablePlayheadThree").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // create controls for Playhead FOUR

  xOffset = 480;
  titleOffset = xOffset+30;

  cp5.addTextlabel("playheadFourLabel")
     .setText("FOUR")
     .setPosition(titleOffset,30)
     .setGroup(playheadsGroup)
     ;

  // create backward button
  // create forward button
  cp5.addToggle("togglePlayheadFourDirection")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset)
     .setSize(controlWidth,controlHeight)
     .setValue(true)
     .setState(false) // false is forwards
     .setMode(ControlP5.SWITCH)
     .setCaptionLabel("Direction")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("togglePlayheadFourDirection").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create speed slider
  cp5.addSlider("playheadFourSpeed")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (1*yControlSpacing))
     .setSize(controlWidth,controlHeight)
     .setRange(0.25,4)
     .setValue(1)
     .setCaptionLabel("Speed")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadFourSpeed").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadFourSpeed").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  // create speed slider
  cp5.addSlider("playheadFourOffset")
     .setBroadcast(false)
     .setPosition(xOffset,yOffset + (2*yControlSpacing))
     .setSize(controlWidth, controlHeight)
     .setRange(0,400)
     .setValue(0)
     .setCaptionLabel("Offset")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  // cp5.getController("playheadFourOffset").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playheadFourOffset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  // create enable toggle with label
  cp5.addToggle("enablePlayheadFour")
     .setBroadcast(false)
     .setPosition(xOffset,245)
     .setSize(controlWidth, 40)
     .setValue(true)
     .setState(false) // false is forwards
     .setCaptionLabel("ENABLE")
     .setBroadcast(true)
     .setGroup(playheadsGroup)
     ;

  cp5.getController("enablePlayheadFour").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
}

/*
 * end playheads group
 */

void updateScalesGroup() {
  String[] scaleButtons = {"C", "D", "E", "F", "G", "A", "B", "C#", "Eb", "F#", "Ab", "Bb"};
  for (int i = 0; i < scaleButtons.length; i++) {
    String functionSafeName = scaleButtons[i].replace("#", "sharp").replace("b", "flat");
    String buttonName = "scale" + functionSafeName + "But";

    String normalizedScaleName = soundbox.normalizeScaleName(scaleButtons[i]);
    if(normalizedScaleName.equals(soundbox.scaleRoot)) {
      cp5.getController(buttonName).setColorBackground(highlightColor);
    } else {
      cp5.getController(buttonName).setColorBackground(defaultBgColor);
    }
  }

  String[] scaleTypes = { "major", "minor", "dorian", "lydian", "mixolydian", "phrygian", "locrian", "pentatonic", "blues"};

  for (int i = 0; i < scaleTypes.length; i++) {
    String buttonName = "scaleType" + scaleTypes[i] + "But";
    if(scaleTypes[i].equals(soundbox.scaleType)) {
      cp5.getController(buttonName).setColorBackground(highlightColor);
    } else {
      cp5.getController(buttonName).setColorBackground(defaultBgColor); 
    }
  }
}

void updateSaveLoadGroup() {
  for (int i = 0; i < 8; i++) {
    File f = new File(dataPath(str(i+1) + ".xml"));
    String buttonName = "load" + (i+1) + "But";

    if (f.exists()) {
      cp5.getController(buttonName).setColorBackground(highlightColor);
    } else {
      cp5.getController(buttonName).setColorBackground(defaultBgColor);
    }
  } 
}

void updatePlayheadsGroup() {
  String[] playheadNames = {"One", "Two", "Three", "Four"};

  for(int i = 0; i < playheadManager.playheads.length; i++) {
    int n = i + 1;
    Playhead p = playheadManager.playheads[i];

    String directionName = "togglePlayhead" + playheadNames[i] + "Direction";
    String enabledName = "enablePlayhead" + playheadNames[i];
    String offsetName = "playhead" + playheadNames[i] + "Offset";
    String speedName = "playhead" + playheadNames[i] + "Speed";

    // update direction
    Toggle tog = (Toggle)cp5.getController(directionName);
    // tog.setState((p.direction==1));
    // update enabled
    Toggle but = (Toggle)cp5.getController(enabledName);
    // if(p.active) {
    //   but.setState(false);
    // } else {
    //   but.setState(true);
    // }
    // update offset if it's not the same
    Slider s1 = (Slider)cp5.getController(offsetName);
    s1.setBroadcast(false).setValue(p.offset).setBroadcast(true);
    // update speed if it's not the same
    Slider s2 = (Slider)cp5.getController(speedName);
    s2.setBroadcast(false).setValue(p.speed).setBroadcast(true);
  }
  
}

void controlEvent(ControlEvent theEvent) {
  String name = theEvent.getName();
  switch(name) {
    case "scaleCBut":
      selectScaleButton(name);
      break;
    case "scaleCsharpBut":
      selectScaleButton(name);
      break;
    case "scaleDBut":
      selectScaleButton(name);
      break;
    case "scaleEflatBut":
      selectScaleButton(name);
      break;
    case "scaleEBut":
      selectScaleButton(name);
      break;
    case "scaleFBut":
      selectScaleButton(name);
      break;
    case "scaleFsharpBut":
      selectScaleButton(name);
      break;
    case "scaleGBut":
      selectScaleButton(name);
      break;
    case "scaleAflatBut":
      selectScaleButton(name);
      break;
    case "scaleABut":
      selectScaleButton(name);
      break;
    case "scaleBflatBut":
      selectScaleButton(name);
      break;
    case "scaleBBut":
      selectScaleButton(name);
      break;
    case "scaleTypemajorBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypeminorBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypedorianBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypelydianBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypemixolydianBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypephrygianBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypelocrianBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypepentatonicBut":
      selectScaleTypeButton(name);
      break;
    case "scaleTypebluesBut":
      selectScaleTypeButton(name);
      break;
    case "save1But":
      saveTune("data/1.xml");
      break;
    case "save2But":
      saveTune("data/2.xml");
      break;
    case "save3But":
      saveTune("data/3.xml");
      break;
    case "save4But":
      saveTune("data/4.xml");
      break;
    case "save5But":
      saveTune("data/5.xml");
      break;
    case "save6But":
      saveTune("data/6.xml");
      break;
    case "save7But":
      saveTune("data/7.xml");
      break;
    case "save8But":
      saveTune("data/8.xml");
      break;

    case "load1But":
      loadTune("data/1.xml");
      break;
    case "load2But":
      loadTune("data/2.xml");
      break;
    case "load3But":
      loadTune("data/3.xml");
      break;
    case "load4But":
      loadTune("data/4.xml");
      break;
    case "load5But":
      loadTune("data/5.xml");
      break;
    case "load6But":
      loadTune("data/6.xml");
      break;
    case "load7But":
      loadTune("data/7.xml");
      break;
    case "load8But":
      loadTune("data/8.xml");
      break;

    // playheads

    // SPEED
    case "playheadOneSpeed":
      s = theEvent.getController().getValue();
      updatePlayheadSpeed(1, s);
      break;
    case "playheadTwoSpeed":
      s = theEvent.getController().getValue();
      updatePlayheadSpeed(2, s);
      break;
    case "playheadThreeSpeed":
      s = theEvent.getController().getValue();
      updatePlayheadSpeed(3, s);
      break;
    case "playheadFourSpeed":
      s = theEvent.getController().getValue();
      updatePlayheadSpeed(4, s);
      break;


    // OFFSET
    case "playheadOneOffset":
      o = (int)(theEvent.getController().getValue());
      updatePlayheadOffset(1, o);
      break;
    case "playheadTwoOffset":
      o = (int)(theEvent.getController().getValue());
      updatePlayheadOffset(2, o);
      break;
    case "playheadThreeOffset":
      o = (int)(theEvent.getController().getValue());
      updatePlayheadOffset(3, o);
      break;
    case "playheadFourOffset":
      o = (int)(theEvent.getController().getValue());
      updatePlayheadOffset(4, o);
      break;



    // DIRECTION
    case "togglePlayheadOneDirection":
      togglePlayheadDirection(1);
      break;
    case "togglePlayheadTwoDirection":
      togglePlayheadDirection(2);
      break;
    case "togglePlayheadThreeDirection":
      togglePlayheadDirection(3);
      break;
    case "togglePlayheadFourDirection":
      togglePlayheadDirection(4);
      break;

    //enable
    case "enablePlayheadOne":
      enablePlayhead(1);
      break;
    case "enablePlayheadTwo":
      enablePlayhead(2);
      break;
    case "enablePlayheadThree":
      enablePlayhead(3);
      break;
    case "enablePlayheadFour":
      enablePlayhead(4);
      break;
  }
}

void saveTune(String filename) {
  store = new Storage(stave,soundbox);
  tuneXml = store.tuneToXml();
  saveXML(tuneXml, filename);
  updateSaveLoadGroup();
}

void loadTune(String filename) {
  store = new Storage(stave,soundbox);
  tuneXml = loadXML(filename);
  store.xmlToTune(tuneXml);
  updateScalesGroup();
}

void deselectAllScaleButtons() {
  String[] allScaleButtons = {"C", "D", "E", "F", "G", "A", "B", "C#", "Eb", "F#", "Ab", "Bb"};
  for (int i = 0; i < allScaleButtons.length; i++) {
    String functionSafeName = allScaleButtons[i].replace("#", "sharp").replace("b", "flat");
    String buttonName = "scale" + functionSafeName + "But";
    controlP5.Controller but = cp5.getController(buttonName);
    but.setColorBackground(defaultBgColor);
  }
}

void deselectAllScaleTypeButtons() {
  String[] scaleTypes = { "major", "minor", "dorian", "lydian", "mixolydian", "phrygian", "locrian", "pentatonic", "blues"};
  for (int i = 0; i < scaleTypes.length; i++) {
    String buttonName = "scaleType" + scaleTypes[i] + "But";
    controlP5.Controller but = cp5.getController(buttonName);
    but.setColorBackground(defaultBgColor);
  }
}

void selectScaleButton(String scaleButtonName) {
  controlP5.Controller but = cp5.getController(scaleButtonName);
  
  // deselect all Buttons
  deselectAllScaleButtons();
  // select this Button
  but.setColorBackground(highlightColor);
  // select this scale

  String shortName = scaleButtonName.replace("scale", "").replace("But", "").replace("sharp", "#").replace("flat", "b");
  String scaleRoot = soundbox.normalizeScaleName(shortName);
  soundbox.scaleRoot = scaleRoot;
  updateScalesGroup();
}

void selectScaleTypeButton(String scaleTypeButtonName) {
  controlP5.Controller but = cp5.getController(scaleTypeButtonName);
  // deselect all Buttons
  deselectAllScaleTypeButtons();
  // select this Button
  but.setColorBackground(highlightColor);

  String scaleType = scaleTypeButtonName.replace("scaleType", "").replace("But", "");

  soundbox.scaleType = scaleType;
  updateScalesGroup();
}

void enablePlayhead(int pN) {
  int index = pN - 1;

  Playhead p = playheadManager.playheads[index];
  if(p.active) {
    p.deactivate();
  } else {
    p.activate();
  }
  updatePlayheadsGroup();
}

void togglePlayheadDirection(int pN) {
  int index = pN - 1;

  Playhead p = playheadManager.playheads[index];
  if(p.directionOffset == 1) {
    p.directionOffset = -1;
    p.direction = 1 - p.direction;
  } else {
    p.directionOffset = 1;
    p.direction = 1 - p.direction;
  }
  updatePlayheadsGroup();
}

void updatePlayheadOffset(int pN, int off) {
  int index = pN - 1;

  Playhead p = playheadManager.playheads[index];

  println("Setting offset to ", off);

  p.changeOffset(off, playheadManager.playheads[0].position);

  println("Playhead offset is now ", p.offset);

  updatePlayheadsGroup();
}

void updatePlayheadSpeed(int pN, float s) {
  int index = pN - 1;

  Playhead p = playheadManager.playheads[index];

  p.speed = s;

  updatePlayheadsGroup();
}

void createBottomButtons() {
  Button lengthButton = cp5.addButton("lengthButton")
                            .setBroadcast(false)
                            .setValue(1)
                            .setPosition(0,440)
                            .setSize(159,40)
                            .setBroadcast(true)
                            ;

  lengthButton.setCaptionLabel("Length");

  Button scalesButton = cp5.addButton("scalesButton")
                           .setBroadcast(false)
                           .setValue(2)
                           .setPosition(160,440)
                           .setSize(159,40)
                           .setBroadcast(true)
                           ;

  scalesButton.setCaptionLabel("Scales");

  Button playheadsButton = cp5.addButton("playheadsButton")
                           .setBroadcast(false)
                           .setValue(3)
                           .setPosition(320,440)
                           .setSize(159,40)
                           .setBroadcast(true)
                           ;

  playheadsButton.setCaptionLabel("Playheads");

  Button midiButton = cp5.addButton("midiButton")
                         .setBroadcast(false)
                         .setValue(4)
                         .setPosition(480,440)
                         .setSize(159,40)
                         .setBroadcast(true)
                        ;

  midiButton.setCaptionLabel("MIDI");

  Button saveLoadButton = cp5.addButton("saveLoadButton")
                             .setBroadcast(false)
                             .setValue(5)
                             .setPosition(640,440)
                             .setSize(160,40)
                             .setBroadcast(true)
                             ;

  saveLoadButton.setCaptionLabel("Save / Load");
}
