
void draw() {
  background(0);
  if(!whiteLightOn && !blackOut && !oddEvenColor) {
    if(useFreq) {
      
      int avgVal = 0;
      avgVal = s2l.freq(freqToSend-freqToSendSize/2);
      for(int i = -freqToSendSize/2+1; i < freqToSendSize/2; i++) {
        avgVal = (avgVal+s2l.freq(freqToSend+i))/2;
      }
      if(min(avgVal, 25*4) > val) val=avgVal;
      if(max(avgVal, 0) < val) val-=(val-avgVal)/10;
      
      if(val > 20*4) val/=1.3;
      if(val > 23*4) val/=1.5;
      if(val > 25*4) val/=2;
      
      if(val < 0) val = 0;
      
        sendDmx(1000, 2);
        sendDmx(1021, 0);
        sendDmx(1022, int(val/4));
        
        println(val/4);
        delay(30);
        stroke(200, 200, 200);
       for(int i = 0; i < 100; i++) {
         if(i == freqToSend) {
           pushMatrix(); pushStyle(); strokeWeight(freqToSendSize); stroke(presets[actualColorPreset]);
         }
         if((i > freqToSend && i - freqToSendSize/2 > freqToSend) || (i < freqToSend && i + freqToSendSize/2 < freqToSend)) {
           line(0, i, s2l.freq(i), i);
         }
         if(i == freqToSend) {
           line(0, i, val, i);
           translate(0, 9); popMatrix(); popStyle(); 
         }
       }
       fill(255);
       text(freqToSend, 50, 150);
       
       if(beat()) { nextColorPreset();  }
    }
    else {
       if(beat()) { oddEvenSides(); }
    }
  }
  
}

boolean beat() {
  if(!s2l.beat(2)) {
    beatWasHere = false;
  }
  if(s2l.beat(2) && !beatWasHere && millis() > lastSend + 400) {
    beatWasHere = true; 
    lastSend = millis();
    return true;
  }
  return false;
}

void nextColorPreset() {
  actualColorPreset++; 
  if(actualColorPreset > 5) { actualColorPreset = 0; } 
  sendColorPreset(actualColorPreset);
}

int actualColorPreset = 0;

boolean left;
int barLength = 1;
void keyPressed() {
  if(key == ' ') {
    oddEvenSides();
  }
  for(int i = 0; i <= 9; i++) {
    if(keyCode == i+49) {
      if(useFreq) sendColorPreset(i);
      actualColorPreset = i;
    }
  }

  
  if(keyCode == UP) {
    freqToSend++;
  }
  if(keyCode == DOWN) {
    freqToSend--;
  }
  
  if(keyCode == LEFT) {
    freqToSendSize--;
    if(freqToSendSize <= 1) freqToSendSize = 1;
  }
  if(keyCode == RIGHT) {
    freqToSendSize++;
  }
  
  if(key == 'f') {
    useFreq = !useFreq;
  }
  
  if(key == 'r') {
    rainbow = !rainbow;
    sendDmx(1000, 1);
    if(rainbow) {
      sendDmx(1031, 0);
    }
    else {
      sendDmx(1032, 0);
    }
  }
  
  if(key == 'w') { whiteLight(); }
  if(key == 'b') { blackOut(); }
  if(key == 'o') { oddEven(); }
//  if(key == 'l') { loadPreset(1); }
//  if(key == 's') { savePreset(1); }
  
}

boolean rainbow;

void oddEvenSides() {
    if(left) {
      actualColorPreset = constrain(actualColorPreset, 0, presetPairs.length-1);
      sendColorPreset(presetPairs[actualColorPreset][0], 1);
      sendDmx(1002, 255);
    }
    else {
      actualColorPreset = constrain(actualColorPreset, 0, presetPairs.length-1);
      sendColorPreset(presetPairs[actualColorPreset][1], 2);
      sendDmx(1003, 255);
      sendDmx(1010, 15);
    }
    left = !left;
}

color[] presets = {
  color(255, 0, 0),
  color(0, 255, 0),
  color(0, 0, 255),
  color(255, 100, 0),
  color(0, 255, 255),
  color(255, 0, 100),
  color(255, 240, 255),
  color(0, 0, 0)
};

int[][] presetPairs = {
  { 4, 5 },
  { 0, 2 },
  { 2, 3  }
};

void sendColorPreset(int i) {
  sendColorPreset(i, 0);
}

void sendColorPreset(int i, int lngthPlus) {
  if(i < presets.length) {
    sendDmx(1000, 3+lngthPlus);
    sendDmx(1101, red(presets[i]));
    sendDmx(1102, green(presets[i]));
    sendDmx(1103, blue(presets[i]));
  }
}

void oddEven() {
  oddEvenColor = !oddEvenColor;
  if(oddEvenColor) {
    sendDmx(1000, 4*30);
    boolean odd = false;
    for(int i = 0; i < 30; i++) {
      sendColor(i, presets[presetPairs[2][int(odd)]]);
      odd = !odd;
    }
  }
}


void sendColor(int pxl, color c) {
  sendDmx(pxl*4, 255); //dim
  sendDmx(pxl*4+1, round(red(c))); //red
  sendDmx(pxl*4+2, round(green(c))); //green
  sendDmx(pxl*4+3, round(blue(c))); //blue
}

void sendDmx(int channel, float value) {
  sendMessage(str(channel) + "c" + str(int(value)) + "w");
}
void sendMessage(String message) {
  myPort.write(message);
}


void whiteLight() {
  whiteLightOn = !whiteLightOn;
  blackOut = false;
  if(whiteLightOn) {
    sendColorPreset(6, 2);
    sendDmx(1021, 0);
    sendDmx(1022, 50);
  }
}

void blackOut() {
  blackOut = !blackOut;
  whiteLightOn = false;
  if(blackOut) {
    sendColorPreset(7, 2);
    sendDmx(1021, 0);
    sendDmx(1022, 50);
  }
}

void savePreset(int id) {
  sendDmx(1000, 1);
  sendDmx(1201, id);
}

void loadPreset(int id) {
  sendDmx(1000, 1);
  sendDmx(1202, id);
}
