#include <Adafruit_NeoPixel.h>

#define PIN 6

Adafruit_NeoPixel strip = Adafruit_NeoPixel(60, PIN, NEO_GRB + NEO_KHZ800);

int barLength = 10;
int comingMessageLength = 1;
int messageLengthCame = 0;
int inputValue[513];
boolean inputValueChanged[513];

int mode = 0;
int SINGLE_BAR_MODE = 2;
int singleBarLength = 0;

int RAINBOW_MODE = 3;

boolean showNow;

void setup() {
  Serial.begin(9600);
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

int value = 0;
int channel;

void loop() {
  int c;

  if(Serial.available()) {
    c = Serial.read();
    if ((c>='0') && (c<='9')) {
      value = 10*value + c - '0';
    } else {
      if (c=='c') channel = value;
      else if (c=='w') {
         if(channel > 0 && channel <= 512) { 
           inputValue[channel-1] = value; 
         }
         else {
           receiveSpecialChannel(channel, value);
         }
        // if(channel > 0 && channel < 512) { inputValueChanged[channel] = true; }
         
      }
      value = 0;
    }
  }
  
  if(mode == RAINBOW_MODE) {
    rainbowCycle(10);
  }
  else {
  
    if(comingMessageLength < messageLengthCame || showNow) {
      for(int i = 0; i < 25; i++) {
        setLedStripValue(i, inputValue[i*4], inputValue[i*4+1], inputValue[i*4+2], inputValue[i*4+3]);
      } 
      strip.show();
      messageLengthCame = 0;
      showNow = false;
    }
  }
}

int oldR, oldG, oldB;

void setLedStripValue(int pxl, int r, int g, int b, int dim) {
  r = round(map(r, 0, 255, 0, dim));
  g = round(map(g, 0, 255, 0, dim));
  b = round(map(b, 0, 255, 0, dim));
  

    if(pxl < 60) { strip.setPixelColor(pxl, r, b, g); }
}


void receiveSpecialChannel(int ch, int val) {
  switch(ch-1000) {
    case 0: comingMessageLength = val;  break;
    case 1: beat(); break;
    case 2: left(); break;
    case 3: right(); break;
    
    case 21: mode = SINGLE_BAR_MODE; break;
    case 22: singleBarLength = val; makeSingleBar(); break;
    
    case 31: mode = RAINBOW_MODE; break;
    case 32: mode = 0; break;
    
    case 10: setBarLength(val); break;
    case 101: setRed(val); break;
    case 102: setGreen(val); break;
    case 103: setBlue(val); break;
    
    case 999: showNow = true; break;
  }
  
  messageLengthCame++;
}

void makeSingleBar() {
  for(int i = 0; i < 25; i++) {
    if(i < singleBarLength) {
      inputValue[i*4+3] = 255;
    }
    else {
      inputValue[i*4+3] = 0;
    }
  }
}

void beat() {
  for(int i = 0; i < 25; i++) {
    setLedStripValue(i, 255, 255, 255, 255);
  }
  strip.show();
  delay(50);
   for(int i = 0; i < 25; i++) {
    setLedStripValue(i, 0, 0, 0, 255);
  }
  strip.show();
}

void left() {
  for(int i = 0; i < 25; i++) {
    if(i < 25/2 && i >= 25/2-barLength) {
      inputValue[i*4+3] = 255;
    }
    else {
      inputValue[i*4+3] = 0;
    }
  }
}

void right() {
  for(int i = 0; i < 25; i++) {
    if(i >= 25/2 && i < 25/2+barLength) {
      inputValue[i*4+3] = 255;
    }
    else {
      inputValue[i*4+3] = 0;
    }
  }
}

void setRed(int v) {
  for(int i = 0; i < 25; i++) {
    inputValue[i*4] = v;
  }
}
void setGreen(int v) {
  for(int i = 0; i < 25; i++) {
    inputValue[i*4+1] = v;
  }
}
void setBlue(int v) {
  for(int i = 0; i < 25; i++) {
    inputValue[i*4+2] = v;
  }
}





void setBarLength(int val) { barLength = val; }
