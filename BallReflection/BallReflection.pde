//
// Assignment for Coursera / DigitalMedia
// 6/2013
//

Maxim maxim;
AudioPlayer[] player;
int MAX_AUDIOPLAYER = 11;
int player_count = 0;

Ball[] aBall;
int MAX_BALL = 300;
int MAX_BALL_AGE = 150;
float MAX_BALL_SIZE = 30;


class Ball {
  PVector pos;
  PVector vel;
  int age;
  float size;
  float sizeVel;
  float sizeMax;
  color BallColor;
  
  Ball(float x, float y) {
    pos = new PVector(x, y, 0);
    vel = new PVector(random(-1,1), random(-1,1));
    age = int(random(20, MAX_BALL_AGE));
    size = 0;
    sizeMax = random(10,MAX_BALL_SIZE);
    sizeVel = sizeMax / (age/2);
    
    int r = (int)map(mouseX, 0, width, 0, 255);
    int g = (int)map(mouseY, 0, height, 0, 255);
    int b = (int)random(0,255);
    BallColor = color( r,g,b, random(0,255) );
    
  }

  boolean update() {
    pos.add(vel);
    
    // reflect at the edges 
    if (pos.x < size) {
      vel.x = -vel.x;
      pos.x = size;
    }
    if (pos.x > (width-size)) {
      vel.x = -vel.x;
      pos.x = width-size;
    }
    if (pos.y < size) {
      vel.y = -vel.y;
      pos.y = size;
    }
    if (pos.y > (height-size)) {
      vel.y = -vel.y;
      pos.y = height-size;
    }    
    
    size += sizeVel;
    if (size > sizeMax) {
       sizeVel = -sizeVel;
       size = sizeMax;
    }
    age--;
    return age > 0;
  }

  void draw() {
    fill(BallColor);
    stroke(255);
    strokeWeight(1);
    ellipse(pos.x, pos.y, size, size);
  }
  
}



void setup()
{
  // default size
  size(600,600);
  maxim = new Maxim(this);
  player = new AudioPlayer[MAX_AUDIOPLAYER];
  for (int i=0; i<MAX_AUDIOPLAYER; i++) {
    player[i] = maxim.loadFile("bubble" + i + ".wav");
    player[i].setLooping(false);
  }
 
  aBall = new Ball[MAX_BALL];
  for (int i=0; i<MAX_BALL; i++) {
    aBall[i] = new Ball(i, i);
  }
}

void  draw()
{
  background(0);
  
  // update balls
  int idxBall = -1;
  for (int i=0; i<MAX_BALL; i++) {
    if (aBall[i].update() == false) {
      idxBall = i;
      aBall[i] = new Ball(mouseX, mouseY);
    }
  }

  // do not sound on each ball
  if (idxBall >= 0) {
    player_count++;
    if (player_count == 5) {
      player_count = 0;
      int idxPlayer = (int)map(aBall[idxBall].sizeMax, 0, MAX_BALL_SIZE, 0, MAX_AUDIOPLAYER);
      player[idxPlayer].cue(0);
      player[idxPlayer].play();
    }
  }

 
  for (int i=0; i<MAX_BALL; i++) {
    aBall[i].draw();
  }
}


