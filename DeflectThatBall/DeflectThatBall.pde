import gab.opencv.*;
import KinectPV2.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import g4p_controls.*;

GButton btnPlay;
GTextArea textScore;

Box2DProcessing box2d;

int frame = 0;
int score = 0;
int lives = 5;
boolean gameContiue = false;

KinectPV2 kinect;

ArrayList<Particle> particles;
ArrayList<Surface> surfaces;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;

boolean drawParticles = false;

void setup() {
  size(512, 424);

  btnPlay = new GButton(this, width/2 - 100/2, height/2 - 30/2, 100, 30, "Start");
  btnPlay.addEventHandler(this, "handleBtnStart");
  btnPlay.setVisible(false);
  textScore = new GTextArea(this, width/2 - 100/2, height/2 - 30/2 + 50, 100, 30);
  textScore.setVisible(false);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableBodyTrackImg(true);

  kinect.init();

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -10);

  particles = new ArrayList<Particle>();
  surfaces = new ArrayList<Surface>();
}

void draw() {
  if (frame%5 == 0) {
    saveFrame("output/screen_#####.png");
  }

  frame++;

  if (!gameContiue) {
    background(0);
    btnPlay.setVisible(true);

    textScore.setText("Score: " + score);
    textScore.setVisible(true);


    for (Surface surface : surfaces) {
      surface.killBody();
    }

    for (Particle p : particles) {
      p.killBody();
    }

    particles.clear();
    surfaces.clear();
  } else {
    background(0);

    for (Surface surface : surfaces) {
      surface.killBody();
    }

    surfaces.clear();

    src = kinect.getBodyTrackImage();

    opencv = new OpenCV(this, src);

    opencv.gray();
    opencv.invert();
    opencv.threshold(70);

    dst = opencv.getOutput();

    contours = opencv.findContours();

    if (kinect.getNumOfUsers() > 0) {
      image(dst, 0, 0);
      for (Contour contour : contours) {
        ArrayList<PVector> points = contour.getPoints();

        ArrayList<PVector> tempList = new ArrayList<PVector>();

        for (int i = 0; i<points.size(); i+=3) {
          PVector point = points.get(i);
          tempList.add(point);
        }

        if (tempList.size() > 10) {
          Surface surface = new Surface(tempList);
          surfaces.add(surface);
        }

        drawParticles = true;
      }
    } else {
      for (Particle p : particles) {
        p.killBody();
      }

      particles.clear();
    }

    if (drawParticles && random(1) < 0.01) {
      float sz = random(10, 20);
      particles.add(new Particle(random(width), 50, sz));
    }


    for (Surface surface : surfaces) {
      surface.display();
    }

    for (Particle p : particles) {
      p.display();
    }

    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);

      int flag = p.done();
      if (flag >= 0) {
        particles.remove(i);

        if (flag > 0) {
          score++;
        } else {
          lives--;
        }
      }
    }

    box2d.step();

    fill(255, 155, 0);
    textSize(20);
    text("Score: " + score + "    Lives: " + lives, 10, 30);

    drawParticles = false;

    if (lives < 1) {
      gameContiue = false;
    }
  }
}

public void handleBtnStart(GButton button, GEvent event) {
  gameContiue = true;
  score = 0;
  lives = 5;

  btnPlay.setVisible(false);
  textScore.setVisible(false);
}

ArrayList<PVector> removeSimilarValues(ArrayList<PVector> list) {
  ArrayList<PVector> listToReturn = (ArrayList<PVector>)list.clone();

  for (int i = 0; i < list.size(); i++) {
    for (int j = i + 1; j < list.size(); j++) {

      double iX = list.get(i).x;
      double iY = list.get(i).y;
      double jX = list.get(j).x;
      double jY = list.get(j).y;

      double xDiff = iX - jX;
      double yDiff = iY - jY;

      if (xDiff < 0.0) {
        xDiff *= -1;
      }
      if (yDiff < 0.0) {
        yDiff *= -1;
      }

      if (xDiff < 2 && yDiff < 2) {
        listToReturn.remove(list.get(j));
      }
    }
  }

  return listToReturn;
}
