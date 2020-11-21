import java.util.ArrayList;
import KinectPV2.*;
import gab.opencv.*;

int countFlap = 0;
boolean previousEventFlap = true;

KinectPV2 kinect;

PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

PImage sprite_flappy;
PImage sprite_pipe;
PImage sprite_city;
PImage sprite_floor;
PImage sprite_title;

//EVENTS
boolean mousePress = false;
boolean mousePressEvent = false;
boolean mouseReleaseEvent = false;
boolean keyPress = false;
boolean keyPressEvent = false;
boolean keyReleaseEvent = false;

ArrayList<Pipe> pipes;

FlappyBird flappy_bird;

MenuGameOver menu_gameover;

int score = 0;
int hightscore = 0;
int speed = 3;
int gap = 120;

boolean gameover = false;
String page = "MENU";

int overflowX = 0;

boolean startgame = false;

int frame = 0;

class FlappyBird {

  int x = 100;
  int y = 0;

  int target = 0;

  float velocityY = 0;

  boolean fly = false;

  int angle = 0;

  boolean falls = false;
  int flashAnim = 0;
  boolean flashReturn = false;
  int kinematicAnim = 0;

  void display() {
    if ((!mousePress) || this.falls) {
      pushMatrix();
      noFill();
      strokeWeight(3);
      translate(width / -2 * 0.1, height / -2 * 0.1);
      translate(this.x, this.y);
      scale(0.1);
      rotate(radians(this.angle));

      strokeWeight(2);
      fill(0);

      for (Contour contour : contours) {
        stroke(0, 12, 185);
        beginShape();
        for (PVector point : contour.getPoints()) {
          vertex(point.x, point.y);
        }
        endShape();
      }
      popMatrix();
    } else {
      pushMatrix();
      noFill();
      strokeWeight(3);
      translate(width / -2 * 0.1, height / -2 * 0.1);
      translate(this.x, this.y);
      scale(0.1);
      rotate(radians(this.angle));

      strokeWeight(2);
      fill(0);

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
  }

  void update() {
    if (this.falls) {
      if (this.flashAnim>255) {
        this.flashReturn = true;
      }

      if (this.flashReturn) {
        this.flashAnim -=60;
      } else {
        this.flashAnim +=60;
      }

      if (this.flashReturn && this.flashAnim == 0) {
        gameover = true;
        menu_gameover.easein();

        if (score > hightscore) { 
          hightscore = score;
        }
      }

      this.y += this.velocityY;
      this.velocityY += 0.4;
      this.angle += 4;

      if (speed > 0) {
        speed = 0;
      }

      if (this.angle > 90) {
        this.angle = 90;
      }
    } else {
      this.y += this.velocityY;
      this.angle += 2.5;

      if (this.angle > 90) {
        this.angle = 90;
      }

      if (mousePressEvent || (keyPressEvent && key == ' ') ) {
        this.velocityY = 0;
        this.fly = true;
        this.target = clamp(this.y - 60, -19, height);
        this.angle = -45;
      }


      if (this.y < this.target) {
        this.fly = false;
        this.target = 10000;
      }


      if (!this.fly) {
        this.velocityY+=0.4;
      } else {
        this.y -= 5;
      }

      if (this.y > height-49) {
        this.falls = true;
      }
    }
    this.y = clamp(this.y, -20, height-50);
  }

  void kinematicMove() {
    if (gameover) {
      this.x = width/2;
      this.y = height/2;

      gameover = false;
      score = 0;
      gap = 90;
    }

    this.y = int(height/2 + map( sin(frameCount*0.1), 0, 1, -2, 2 ));

    pushMatrix();
    translate(this.x, this.y);
    image(sprite_flappy, 0, 0, sprite_flappy.width/2, sprite_flappy.height, 0, 0, sprite_flappy.width/2*3, sprite_flappy.height*3);
    popMatrix();
  }
}

void setup() {
  size(400, 600);

  kinect = new KinectPV2(this);

  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);
  kinect.enableDepthImg(true);
  kinect.enableBodyTrackImg(true);

  kinect.init();

  pipes = new ArrayList<Pipe>();
  menu_gameover = new MenuGameOver();
  flappy_bird = new FlappyBird();

  imageMode(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);
  textAlign(CENTER, CENTER);

  noSmooth();

  pipes.add(new Pipe());

  sprite_flappy = loadImage("flappybird.png");
  sprite_pipe = loadImage("pipe.png");
  sprite_city = loadImage("city.png");
  sprite_floor = loadImage("floor.png");
  sprite_title = loadImage("title.png");

  flappy_bird.y = height/2;
}

void ss(String data) {
  print(data);
}

void draw() {
  background(123, 196, 208);

  src = kinect.getBodyTrackImage();

  opencv = new OpenCV(this, src);
  opencv.blur(12);
  opencv.adaptiveThreshold(301, 1);
  opencv.invert();

  dst = opencv.getSnapshot();

  contours = opencv.findContours();
  println("found " + contours.size() + " contours");

  switch(page) {
  case "GAME":
    page_game();
    break;
  case "MENU":
    page_menu();
    break;
  }

  mousePressEvent = false;
  mouseReleaseEvent = false;
  keyPressEvent = false;
  keyReleaseEvent = false;

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);

      checkFlapEvent(joints);
    }
  }

  pushMatrix();
  scale(0.2);
  image(kinect.getBodyTrackImage(), 200, 200);
  popMatrix();

  if (frame % 3 == 0) {
    saveFrame("output/frame_#####.png");
  }

  frame++;
}

void checkFlapEvent(KJoint[] joints) {
  if (joints[KinectPV2.JointType_ElbowRight].getY() < joints[KinectPV2.JointType_HandRight].getY() && joints[KinectPV2.JointType_ElbowLeft].getY() < joints[KinectPV2.JointType_HandLeft].getY() && !previousEventFlap) {
    previousEventFlap = true;
    mousePressed();
  } else if (!(joints[KinectPV2.JointType_ElbowRight].getY() < joints[KinectPV2.JointType_HandRight].getY() && joints[KinectPV2.JointType_ElbowLeft].getY() < joints[KinectPV2.JointType_HandLeft].getY())) {
    previousEventFlap = false;
  }
}

void mousePressed() {
  mousePress = true;
  mousePressEvent = true;
}
void mouseReleased() {
  mousePress = false;
  mouseReleaseEvent = true;
}
void keyPressed() {
  keyPress = true;
  keyPressEvent = true;
}
void keyReleased() {
  keyPress = false;
  keyReleaseEvent = true;
}

void page_game() {

  overflowX += speed;
  if (overflowX > sprite_city.width/2) {
    overflowX = 0;
  }

  image(sprite_city, sprite_city.width/2/2, height-sprite_city.height/2/2-40, sprite_city.width/2, sprite_city.height/2);

  if (!flappy_bird.falls) {
    if (parseInt(frameCount)%70 == 0) {
      pipes.add(new Pipe());
    }
  }

  for (int i=0; i<pipes.size(); i++) {
    if (pipes.get(i).x < -50) {
      pipes.remove(i);
      i--;
    }

    try {
      pipes.get(i).display();
      pipes.get(i).update();
    } 
    catch(Exception e) {
    }
  }

  image(sprite_floor, sprite_floor.width-overflowX, height-sprite_floor.height, sprite_floor.width*2, sprite_floor.height*2);
  image(sprite_floor, sprite_floor.width+sprite_floor.width-overflowX, height-sprite_floor.height, sprite_floor.width*2, sprite_floor.height*2);
  image(sprite_floor, sprite_floor.width+sprite_floor.width*2-overflowX, height-sprite_floor.height, sprite_floor.width*2, sprite_floor.height*2);


  flappy_bird.display();
  flappy_bird.update();
  flappy_bird.x = int(smoothMove(flappy_bird.x, 90, 0.02));

  if (!gameover) {
    pushMatrix();
    stroke(0);
    strokeWeight(5);
    fill(255);
    textSize(30);
    text(score, width/2, 50);
    popMatrix();
  }

  pushMatrix();
  noStroke();
  fill(255, flappy_bird.flashAnim);
  rect(width/2, height/2, width, height);
  popMatrix();

  if (gameover) {
    menu_gameover.display();
    menu_gameover.update();
  }
}

void page_menu() {
  speed = 1;
  overflowX += speed;
  if (overflowX > sprite_city.width/2) {
    overflowX = 0;
  }

  image(sprite_city, sprite_city.width/2/2, height-sprite_city.height/2/2-40, sprite_city.width/2, sprite_city.height/2);

  image(sprite_floor, sprite_floor.width-overflowX, height-sprite_floor.height, sprite_floor.width*2, sprite_floor.height*2);
  image(sprite_floor, sprite_floor.width+sprite_floor.width-overflowX, height-sprite_floor.height, sprite_floor.width*2, sprite_floor.height*2);
  image(sprite_floor, sprite_floor.width+sprite_floor.width*2-overflowX, height-sprite_floor.height, sprite_floor.width*2, sprite_floor.height*2);

  image(sprite_title, width/2, 100, sprite_title.width/4, sprite_title.height/4);

  flappy_bird.kinematicMove();

  pushMatrix();
  fill(230, 97, 29);
  stroke(255);
  strokeWeight(3);
  text("Tap to play", width/2, height/2-50);
  popMatrix();

  if (mousePressEvent || (keyPressEvent && key == ' ') ) {
    page = "GAME";
    resetGame();

    flappy_bird.velocityY = 0;
    flappy_bird.fly = true;
    flappy_bird.target = clamp(flappy_bird.y - 60, -19, height);
    flappy_bird.angle = -45;
    flappy_bird.update();
  }
  flappy_bird.x = width/2;
}

class Pipe {

  int gapSize = gap;
  int y = int(random(150, height-150));
  int x = width + 50;
  boolean potential = true;

  void display() {
    pushMatrix();
    translate(this.x, this.y+this.gapSize+sprite_pipe.height/2/2);
    image(sprite_pipe, 0, 0, sprite_pipe.width/2, sprite_pipe.height/2);
    popMatrix();

    pushMatrix();
    translate(this.x, this.y-this.gapSize-sprite_pipe.height/2/2);
    rotate(radians(180));
    scale(-1, 1);
    image(sprite_pipe, 0, 0, sprite_pipe.width/2, sprite_pipe.height/2);
    popMatrix();

    if (this.potential && (flappy_bird.x > this.x-25 && flappy_bird.x < this.x+25)) {
      score++;
      this.potential = false;
    }

    if (
      ((flappy_bird.x+20 > this.x-25 && flappy_bird.x-20 < this.x+25) && (flappy_bird.y+20 > (this.y-this.gapSize-sprite_pipe.height/2/2)-200 && flappy_bird.y-20 < (this.y-this.gapSize-sprite_pipe.height/2/2)+200))

      ||

      ((flappy_bird.x+20 > this.x-25 && flappy_bird.x-20 < this.x+25) && (flappy_bird.y+20 > (this.y+this.gapSize+sprite_pipe.height/2/2)-200 && flappy_bird.y-20 < (this.y+this.gapSize+sprite_pipe.height/2/2)+200))
      ) {
      flappy_bird.falls = true;
    }
  }

  void update() {
    this.x-= speed;
  }
}

int clamp(int value, int min, int max) {

  if (value < min) {
    value = min;
  }
  if (value > max) {
    value = max;
  }

  return value;
}

void resetGame() {
  gameover = false;
  gap = 80;
  speed = 3;
  score = 0;
  flappy_bird.y = height/2;
  flappy_bird.falls = false;
  flappy_bird.velocityY = 0;
  flappy_bird.angle = 0;
  flappy_bird.flashAnim = 0;
  flappy_bird.flashReturn = false;
  pipes.clear();
  flappy_bird.target = 10000;
  menu_gameover.ease = 0;
}

class MenuGameOver {
  int ease = 0; 
  boolean easing = false;
  boolean open =false; 

  void display() {
    pushMatrix();
    translate(width/2, height/2);
    scale(this.ease);

    stroke(83, 56, 71);
    strokeWeight(2);
    fill(222, 215, 152);
    rect(0, 0, 200, 200);

    noStroke();
    fill(83, 56, 71);

    textSize(20);
    strokeWeight(5);
    stroke(83, 56, 71);
    fill(255);
    
    pushMatrix();
    textAlign(LEFT, CENTER);
    textSize(12);
    noStroke();
    fill(83, 56, 71);

    stroke(0);
    strokeWeight(3);
    fill(255);
    popMatrix();

    resetGame();

    popMatrix();
  }

  void update() {
    if (this.easing) {
      this.ease += 0.1;
      if (this.ease > 1) {
        this.open = true;
        this.ease = 1;
        this.easing = false;
      }
    }
  }

  void easein() {
    this.easing = true;
  }
}

boolean press(String txt, int x, int y, int tX, int tY) {
  boolean this_h = false;

  if (mouseX > tX+x-textWidth(txt)/2-10 && mouseX < tX+x+textWidth(txt)/2+10 && mouseY > tY+y-textAscent()/2-10 && mouseY < tY+y+textAscent()/2+10) {
    this_h = true;
  }

  pushMatrix();
  textSize(16);

  if (this_h && mousePress) {
    noStroke();
    fill(83, 56, 71);
    rect(x, y+3, textWidth(txt)+25+10, textAscent()+10+10);

    fill(250, 117, 49);
    stroke(255);
    strokeWeight(3);
    rect(x, y+2, textWidth(txt)+25, textAscent()+10);

    noStroke();
    fill(255);
    text(txt, x, y+2);
  } else {
    noStroke();
    fill(83, 56, 71);
    rect(x, y+2, textWidth(txt)+25+10, textAscent()+10+12);

    if (this_h) {
      fill(250, 117, 49);
    } else {
      fill(230, 97, 29);
    }
    stroke(255);
    strokeWeight(3);
    rect(x, y, textWidth(txt)+25, textAscent()+10);

    noStroke();
    fill(255);
    text(txt, x, y);
  }
  popMatrix();

  return (this_h && mouseReleaseEvent);
}

float smoothMove(int pos, int target, float speed) {
  return pos + (target-pos) * speed;
}
