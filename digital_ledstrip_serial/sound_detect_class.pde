
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

