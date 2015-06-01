

import processing.serial.*;

int baudRate = 9600;
int serialIndex = 9;

Serial myPort;



//------------------------------------s2l---------------------------------------//|
                                                                                //|
//sound to light kirjastot                                                      //|
import ddf.minim.spi.*;                                                         //|
import ddf.minim.signals.*;                                                     //|
import ddf.minim.*;                                                             //|
import ddf.minim.analysis.*;                                                    //|
import ddf.minim.ugens.*;                                                       //|
import ddf.minim.effects.*;                                                     //|
                                                                                //|
Minim minim;                                                                    //|
AudioPlayer song;                                                               //|
AudioInput in;                                                                  //|
BeatDetect beat;                                                                //|
                                                                                //|
FFT fft;                                                                        //|
                                                                                //|
int buffer_size = 1024;  // also sets FFT size (frequency resolution)           //|
float sample_rate = 44100;                                                      //|
                                                                                //|
//------------------------------------------------------------------------------//|

soundDetect s2l;

void setup() {
  size(300, 300);
  myPort = new Serial(this, Serial.list()[serialIndex], baudRate);
  delay(2000);
  for(int i = 0; i < 50; i++) {
    sendDmx(i*4+4, 255);
  }
  sendDmx(1021, 2);
  sendDmx(1022, 10);
  
    //--------------------------------------Setup commands of minim library----------------------------------------
    minim = new Minim(this);
    in = minim.getLineIn(Minim.MONO,buffer_size,sample_rate);
    beat = new BeatDetect(in.bufferSize(), in.sampleRate());

    fft = new FFT(in.bufferSize(), in.sampleRate());
    fft.logAverages(16, 2);
    fft.window(FFT.HAMMING);
  //------------------------------------------------------------------------------------------------------------
  
  s2l = new soundDetect();
}
int iterator = 0;
int freqToSend = 10;
boolean useFreq = false;
boolean beatWasHere = false;

long lastSend = 0;

int freqToSendSize = 40;

int val = 0;

void draw() {
  background(0);
  if(useFreq) {
    
    int avgVal = 0;
    avgVal = s2l.freq(freqToSend-freqToSendSize/2);
    for(int i = -freqToSendSize/2+1; i < freqToSendSize/2; i++) {
      avgVal = (avgVal+s2l.freq(freqToSend+i))/2;
    }
    if(avgVal > val) val=avgVal;
    if(avgVal < val) val-=(val-avgVal)/4;
    
    if(val > 20*4) val/=1.3;
    if(val > 23*4) val/=1.5;
    if(val > 25*4) val/=2;
    
    if(val < 0) val = 0;
    
      sendDmx(1000, 2);
      sendDmx(1021, 0);
      sendDmx(1022, val/4);
      
      println(val/4);
      delay(30);
      stroke(200, 200, 200);
     for(int i = 0; i < 100; i++) {
       if(i == freqToSend) {
         pushMatrix(); pushStyle(); strokeWeight(freqToSendSize); stroke(255, 0, 100);
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
     
     if(s2l.beat(2) && !beatWasHere && millis() > lastSend + 100) { actualColorPreset++; if(actualColorPreset > 8) { actualColorPreset = 0; } sendColorPreset(actualColorPreset); beatWasHere = true; lastSend = millis(); }
     if(!s2l.beat(2)) beatWasHere = false;
  }
  else {
     if(s2l.beat(2) && !beatWasHere && millis() > lastSend + 100) { oddEvenSides(); beatWasHere = true; lastSend = millis(); }
     if(!s2l.beat(2)) beatWasHere = false;
  }
  
  
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
      sendColorPreset(i);
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
  
}

boolean rainbow;

void oddEvenSides() {
      if(left) {
      sendDmx(1000, 1);
      sendDmx(1002, 255);
    }
    else {
      sendDmx(1000, 2);
      sendDmx(1003, 255);
      sendDmx(1010, 15);
    }
    left = !left;
}

color[] presets = {
  color(255, 0, 0),
  color(0, 255, 0),
  color(0, 0, 255),
  color(255, 255, 0),
  color(0, 255, 255),
  color(255, 0, 255)
};

void sendColorPreset(int i) {
  if(i < presets.length) {
    sendDmx(1000, 3);
    sendDmx(1101, red(presets[i]));
    sendDmx(1102, green(presets[i]));
    sendDmx(1103, blue(presets[i]));
  }
}

void left(color c) {
  for(int i = 0; i < 25/2; i++) {
    sendColor(i, c);
  }
  sendDmx(1999, 0);
}

void sendColor(int pxl, color c) {
  sendDmx(pxl*4+1, red(c));
  sendDmx(pxl*4+2, green(c));
  sendDmx(pxl*4+3, blue(c));
}

void sendDmx(int channel, float value) {
  sendMessage(str(channel) + "c" + str(int(value)) + "w");
}
void sendMessage(String message) {
  myPort.write(message);
}

class soundDetect { //----------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
  //init all the variables
  float[] bands = new float[getFreqMax()];
  float[] avgTemp = new float[getFreqMax()];
  float[] avgCounter = new float[getFreqMax()];
  float[] avg = new float[getFreqMax()];
  float[] currentAvgTemp = new float[getFreqMax()];
  float[] currentAvg = new float[getFreqMax()];
  float[] currentAvgCounter = new float[getFreqMax()];
  float[] max = new float[getFreqMax()];
 
  boolean blinky = false;
  
  int oldFrameCount = 0;
  boolean onset, kick, snare, hat;
  
  //end initing variables
  
  
  
  soundDetect() {
  }
  
  
  boolean beat(int bT) {
    beat.detect(in.mix); //beat detect command of minim library
    boolean toReturn = true;
    
    if(frameCount > oldFrameCount) {
      oldFrameCount = frameCount;
      switch(bT) {
        case 1: toReturn = beat.isOnset(); onset = toReturn; break;
        case 2: toReturn = beat.isKick(); kick = toReturn; break;
        case 3: toReturn = beat.isSnare(); snare = toReturn; break;
        case 4: toReturn = beat.isHat(); hat = toReturn; break;
      }
    }
    else {
      switch(bT) {
        case 1: toReturn = onset; break;
        case 2: toReturn = kick; break;
        case 3: toReturn = snare; break;
        case 4: toReturn = hat; break;
      }
    }
    
    return toReturn;
  }
  
  
  //inside soundDetect class
  int freq(int i) { //Get freq of specific band
    i = constrain(i, 0, avg.length-1);
    float toReturn = 0;
    fft.forward(in.mix);
    toReturn = 0;
    float val = getBand(i);
    toReturn = map(val, avg[i], max[i], 0, 255*2); //This is what this function returns
    { //Counting avg values
      avgTemp[i] += val;
      avgCounter[i]++;
      if(avgCounter[i] > 200) {
        avg[i] = (avg[i] + (avgTemp[i] / avgCounter[i])) / 2;
        avgTemp[i] = 0;
        avgCounter[i] = 0;
      }
    } //End of counting avg values
    
    { //Counting max values
      if(max[i] > 0.8) { max[i]-=0.01; } //Make sure max isn't too big
      if(val > max[i]) { max[i] = val; } //Make sure max isn't too small
    } //End of counting max values
    return round(toReturn);
    //command to get  right freq from fft or something like it.
  }
  
  float getBand(int i) {
    if(blinky) {
      return log(getRawBand(i));
    }
    else {
      return getRawBand(i);
    }
  }
  
  float getRawBand(int i) {
    return fft.getBand(i);
  }
  
  float freqWithoutProcessing(int i) {
    fft.forward(in.mix);
    return getRawBand(i);
  }
  
  int getFreqMax() { //How many bands are available
    int toReturn = fft.specSize();
    return toReturn;
    //command which tells how many frequencies there is available.
  }
  
  
} //en of soundDetect class-----------------------------------------------------------------------------------------------------------------------------------------------------

