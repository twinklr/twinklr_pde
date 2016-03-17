class Note {
  int x, y, scaleIndex;
  boolean played;
  Ani growAni, shrinkAni, fadeInAni, fadeOutAni;
  PApplet parent;
  Stave stave;
  Playhead playhead;
  
  float diameter = 30;
  float startDiameter = 0;
  float drawOpacity = 255;
  float radius = diameter / 2;
  
  Note(int xPos, int yPos, Stave s, Playhead pl, PApplet p) {
    x = xPos;
    y = yPos;
    this.stave = s;
    this.playhead = pl;
    this.parent = p;
    played = false;
    
    growAni = new Ani(this, 0.1, "startDiameter", diameter, Ani.LINEAR);
    shrinkAni = new Ani(this, 0.1, "startDiameter", 0.0, Ani.LINEAR, "onEnd:remove");  

    fadeInAni = new Ani(this, 0.3, "drawOpacity", 128, Ani.LINEAR);
    fadeOutAni = new Ani(this, 0.3, "drawOpacity", 255, Ani.LINEAR);
    
    growAni.start();
  }

  void draw() {
    // get colour for note
    int i = stave.getColorIndexForNote(this);

    color c = colorFromColorIndex(i);

    if(intersectedBy(playhead.position)) {
      strokeWeight(3);
      stroke(128,0,0);
    } else {
      noStroke();
    }
    fill(c); 

    int absX = x + stave.xPadding;
    int absY = y + stave.topPadding;
    
    ellipse(absX, absY,startDiameter,startDiameter);
  }
  
  void play() {
    if(intersectedBy(playhead.position) && !played) {
      // println(stave.indexOfNote(this));
      stave.soundBox.playSound(stave.indexOfNote(this));
      played = true;
    }
  }
  
  void destroy() {
    shrinkAni.setBegin();
    shrinkAni.start();
  }

  void fadeOut() {
    fadeOutAni.setBegin();
    fadeOutAni.start();
  }

  void fadeIn() {
    fadeInAni.setBegin();
    fadeInAni.start();
  }
  
  void remove() {
    stave.notes.remove(this);
  }
  
  boolean intersectedBy(int xPos) {
    if(((xPos) > (x-radius)) && ((xPos) < x+radius)) {
      return true;
    } else {
      return false;
    }
  }
  
  boolean intersectedBy(int xPos, int yPos) {
    if(((xPos) > (x-radius)) && ((xPos) < x+radius)) {
      if(((yPos) > (y-radius)) && ((yPos) < y+radius)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  private color colorFromColorIndex(int i) {
    color[] colors = new color[0];

    colors = append(colors, color(245, 120, 107, drawOpacity));
    colors = append(colors, color(255, 206, 42, drawOpacity));
    colors = append(colors, color(254, 178, 196,drawOpacity));
    colors = append(colors, color(200, 214, 87,drawOpacity));
    colors = append(colors, color(176, 60, 164,drawOpacity));
    colors = append(colors, color(255, 179, 38,drawOpacity));
    colors = append(colors, color(126, 212, 210,drawOpacity));

    return colors[i];
  }
}