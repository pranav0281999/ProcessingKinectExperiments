import org.openkinect.processing.*;

Kinect2 kinect2;
int maxB, minB;
int skip=5;
boolean record = false;

void setup() {
  size(512, 424, P3D);

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  minB = 20;
  maxB = 50;
}


void draw() {
  background(0);

  PImage img = kinect2.getDepthImage();

  pushMatrix();

  beginShape(POINTS);

  for (int x = skip; x < img.width - skip; x+=skip) {
    for (int y = skip; y < img.height - skip; y+=skip) {
      int index = x + y*img.width;
      float b = brightness(img.pixels[index]);

      if (b < maxB && b > minB) {
        float z = map(b, 0, 255, 250, -500);
        strokeWeight(4);
        stroke(map(255-b, 255 - maxB, 255 - minB, 0, 250));
        vertex(x, y, z);

        for (int dx = x - skip; dx <= x+skip; dx += skip) {
          for (int dy = y - skip; dy <= y+skip; dy += skip) {
            int dindex = dx + dy*img.width;
            float db = brightness(img.pixels[dindex]);

            if (db < maxB && db > minB) {
              float dz = map(db, 0, 255, 250, -500);
              strokeWeight(1);
              stroke(map(255-db, 255 - maxB, 255 - minB, 0, 250));
              line(x, y, z, dx, dy, dz);
            }
          }
        }
      }
    }
  }
  endShape();

  popMatrix();
  
  if(record) {
    saveFrame("output/frame_####.png");
  }
}

void keyPressed() {
  if (key == 'p') {
    saveFrame("screenshot_#####.png");
  } else if (key == 'a') {
    if (skip > 1) {
      skip--;
    }
  } else if (key == 'd') {
    skip++;
  } else if(key =='r') {
    record = !record;
  }
}
