Maxim maxim;
AudioPlayer[] player;
int MAX_AUDIOPLAYER = 2;

Step[] aStep;
int STEP_SIZE = 80;
int MAX_STEP = 10;

Ball ball;
int BALL_SIZE = 30;
float BALL_UP_VEL = -10;
float xGravity = 0;
int BALL_UPDATE_OK = 0;
int BALL_UPDATE_OUT = 1;
int BALL_UPDATE_SCROLL = 2;


class Ball {
  PVector pos;
  PVector vel;
  PVector gravity;
  float hSize;
  color BallColor;
  float frameHeight;
   
  Ball(float x, float y) {
    pos = new PVector(x, y, 0);
    vel = new PVector(0, 0);
    gravity = new PVector(0,0.2);
    BallColor = color(255,50,50);
    hSize = BALL_SIZE/2;
    frameHeight = height;
  }

  // return true, of ball is out
  int update() {
    pos.add(vel);
    vel.add(gravity);
    if (pos.x < 0) {
      pos.x = width;
    }
    if (pos.x > width) {
      pos.x = 0;
    }
    if (pos.y > frameHeight) {
      return BALL_UPDATE_OUT;
    }
    if (pos.y < frameHeight/2) {
      return BALL_UPDATE_SCROLL;
    }    
    return BALL_UPDATE_OK;
  }

  void addXGravity(float xGrav) {
    pos.x += xGrav;
  }
  
  void draw() {
    float b4 = BALL_SIZE/3.5;
    // body
    fill(BallColor);
    noStroke();
    rect(pos.x-hSize, pos.y-hSize, BALL_SIZE, BALL_SIZE);
    
    // legs
    stroke(255, 100, 0);
    strokeWeight(3);
    line(pos.x-5, pos.y+BALL_SIZE/2, pos.x-b4, pos.y+BALL_SIZE/2+7);
    line(pos.x+5, pos.y+BALL_SIZE/2, pos.x+b4, pos.y+BALL_SIZE/2+7);

    // nose    
    stroke(255, 255, 0);
    strokeWeight(5); 
    line(pos.x,pos.y, pos.x, pos.y+10);
    
    // eyes
    noStroke();
    fill(255,255,255);
    float d = map(vel.y, -BALL_UP_VEL, BALL_UP_VEL, +10, 2);    
    ellipse(pos.x-b4, pos.y-d, BALL_SIZE/1.8, BALL_SIZE/1.6);
    ellipse(pos.x+b4, pos.y-d, BALL_SIZE/1.8, BALL_SIZE/1.6);
    fill(0,0,0);
    ellipse(pos.x-b4, pos.y-d, BALL_SIZE/4, BALL_SIZE/4);
    ellipse(pos.x+b4, pos.y-d, BALL_SIZE/4, BALL_SIZE/4);

  }

  void bounceBack() {
    // junp up
    vel.y = BALL_UP_VEL;
  }

  boolean reflect(Step step) {
    // ball right or left of the step
    float rightEdge = pos.x+hSize;
    float leftEdge = pos.x-hSize;
    if (rightEdge < step.left()  ||  step.right() < leftEdge) {
      return false;
    }
    float yOld = pos.y + BALL_SIZE/2;
    float yNew = yOld + vel.y;
    if (yNew > step.y()  &&  yOld < step.y()) {
      return true;
    }
    return false;
  }
}


class Step { 
  PVector pos;
  int weight; 
  color StepColor;
  
  Step(float x, float y) {  
    pos = new PVector(x,y,0);
    StepColor = color(0, 200, 0);
    weight = 5;
  } 
  boolean visible() {
    return pos.y < height;
  } 

  float left() {
    return pos.x - STEP_SIZE/2;
  }

  float right() {
    return pos.x + STEP_SIZE/2;
  }
  float y() {
    return pos.y;
  }
  void draw()
  {
    stroke(StepColor);
    strokeWeight(weight); 
    line(left(), y(), right(), y()); 
  } 
} 





void setup()
{
  // default size
  size(400,600);
 
  maxim = new Maxim(this);
  player = new AudioPlayer[MAX_AUDIOPLAYER];
  for (int i=0; i<MAX_AUDIOPLAYER; i++) {
    player[i] = maxim.loadFile("boink" + i + ".wav");
    player[i].setLooping(false);
  }

 
  ball = new Ball(300,300);
  aStep = new Step[MAX_STEP];
  for (int i=0; i<MAX_STEP; i++) {
    aStep[i] = new Step(random(0+STEP_SIZE, width-STEP_SIZE), 
                  random(10, 1*height)-0*height);
  }

}

void draw()
{
  background(0);
  
  ball.update();
  ball.addXGravity(xGravity);
  
  //scrolling of the steps down
  float yMid = height/2;
  if (ball.pos.y < yMid) {
    float d = yMid - ball.pos.y;
    // correct the ball position - on the half y
    ball.pos.y = yMid;
    for (int i=0; i<MAX_STEP; i++) {
      // scroll down the steps
      aStep[i].pos.y += d;
    }
  }

  for (int i=0; i<MAX_STEP; i++) {
    if (!aStep[i].visible()) {
      aStep[i].pos.y = -10;
      aStep[i].pos.x = random(0, width);
      aStep[i].StepColor = color( random(50,255),
                                  random(50,255),
                                  random(50,255) ); 
    }
  } 
  
  boolean bBounce = false;
  boolean bSound = false;
  for (int i=0; i<MAX_STEP; i++) {
    if (ball.reflect( aStep[i] )) {
      bBounce = true;
      if ( red(aStep[i].StepColor) > 200 ) {
         bSound = true;
      } 
    }
    aStep[i].draw();
  }
  ball.draw();

  if (bBounce) {
      if (!bSound) {
        player[0].cue(0);
        player[0].play();
      }
      ball.bounceBack();
  }

  if (bSound) {
      player[1].cue(0);
      player[1].play();
  }

}

void keyPressed()
{
  if (keyCode == RIGHT) {
    xGravity = 2;
  }
  if (keyCode == LEFT) {
    xGravity = -2;
  }
}

void keyReleased()
{
  xGravity = 0;
}


