import org.openkinect.processing.*;

// Kinect Library object
Kinect2 kinect2;

void setup() {
  size(512, 424, P3D);

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initVideo();
  kinect2.initIR();
  kinect2.initDevice();
}

void draw() {
  background(0);

  PImage img = kinect2.getDepthImage();
  PImage imgColor = kinect2.getVideoImage();

  int skip = 4;

  for (int x = 0; x < img.width; x+=skip) {
    for (int y = 0; y < img.height; y+=skip) {
      int index = x + y * img.width;
      float brightness = brightness(img.pixels[index]);

      if (brightness>50 || brightness < 10) {
        continue;
      }

      float z = map(brightness, 0, 255, 250, -250);

      fill(255-brightness);
      pushMatrix();
      translate(x, y, z);
      rect(0, 0, skip, skip);
      popMatrix();
    }
  }
  
  // saveFrame("output/cool_####.png");
}
