import gab.opencv.*;
import KinectPV2.*;

KinectPV2 kinect;
PImage  img, thresh, blur, adaptive;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

float changeFactor = 0.15;

int drawCount = 1;
int waveCount = 1;
float strokeWave = 0.5, strokeWaveInitial = 0.5, strokeWaveChangeFactor = changeFactor, strokeWaveChangeChangeFactor = 1.0;
boolean strokeWaveInitalInc = true, strokeWaveAfterInc = true;

void setup() {
  size(512, 424);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableBodyTrackImg(true);

  kinect.init();
}

void draw() {
  strokeWave = strokeWaveInitial;

  background(0);

  src = kinect.getBodyTrackImage();

  opencv = new OpenCV(this, src);
  opencv.blur(12);  
  opencv.adaptiveThreshold(301, 1);
  opencv.invert();

  dst = opencv.getSnapshot();

  image(dst, 0, 0);

  contours = opencv.findContours();
  println("found " + contours.size() + " contours");

  noFill();
  strokeWeight(3);

  int avgX = 0, avgY = 0, count = 0;

  for (int x = 0; x < 512; x++) {
    for (int y = 0; y< 424; y++) {
      int offset = x + y * 512;

      if (brightness(dst.pixels[offset]) > 200) {
        avgX += x;
        avgY += y;
        count++;
      }
    }
  }

  if (avgX != 0 || avgY != 0) {
    avgX /= count;
    avgY /= count;
  }

  for (float i = 1; i < 30.0; i+=0.5) {
    waveCount++;

    pushMatrix();

    translate(width / 2, height / 2);
    translate((avgX * -1) * i, (avgY * -1) * i);
    scale(i);

    strokeWeight(2 / (i /** i*/) * strokeWave);
    setstrokeWaveAfter();

    for (Contour contour : contours) {
      stroke(0, 12, 185);
      beginShape();
      for (PVector point : contour.getPoints()) {
        vertex(point.x, point.y);
      }
      endShape();
    }

    popMatrix();
  }

  drawCount++;
  waveCount = 1;

  setstrokeWaveInitial();
  
  //saveFrame("output/frame_######.png");
}

void setstrokeWaveInitial() {
  if (strokeWaveInitalInc) {
    strokeWaveInitial += strokeWaveChangeFactor;
  } else {
    strokeWaveInitial -= strokeWaveChangeFactor;
  }

  if (strokeWaveInitial > 1.0) {
    strokeWaveInitalInc = false;
    strokeWaveChangeFactor = changeFactor;
  } else if (strokeWaveInitial < 0.4) {
    strokeWaveInitalInc = true;
    strokeWaveChangeFactor = changeFactor;
  }

  strokeWaveChangeFactor *= strokeWaveChangeChangeFactor;
}

void setstrokeWaveAfter() {
  if (strokeWaveAfterInc) {
    strokeWave += strokeWaveChangeFactor;
  } else {
    strokeWave -= strokeWaveChangeFactor;
  }

  if (strokeWave > 1.0) {
    strokeWaveAfterInc = false;
    strokeWaveChangeFactor = changeFactor;
  } else if (strokeWave < 0.4) {
    strokeWaveAfterInc = true;
    strokeWaveChangeFactor = changeFactor;
  }

  strokeWaveChangeFactor *= strokeWaveChangeChangeFactor;
}
