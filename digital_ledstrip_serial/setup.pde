

import processing.serial.*;

int baudRate = 9600;
int serialIndex = 8;

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
  size(255, 300);
  myPort = new Serial(this, "/dev/tty.usbmodem14211", baudRate);
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

float val = 0;

boolean whiteLightOn = false;
boolean blackOut = false;
boolean oddEvenColor = false;
