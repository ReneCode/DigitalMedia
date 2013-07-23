Maxim maxim;
AudioPlayer[] player;
int MAX_AUDIOPLAYER = 3;

Step[] aStep;
int STEP_SIZE = 80;
int MAX_STEP = 10;
int STEP_TYPE_HIDDEN = -1;
int STEP_TYPE_NORMAL = 0;
int STEP_TYPE_JUMPER = 1;
int STEP_TYPE_ONCE = 2;
int STEP_TYPE_MAX = 3;


Ball ball;
int BALL_SIZE = 30;
float BALL_BOUNCE_BACK_VEL = -10;
float xGravity = 0;
int BALL_UPDATE_OK = 0;
int BALL_UPDATE_OUT = 1;
int BALL_UPDATE_SCROLL = 2;

int score = 0;

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
    gravity = new PVector(0, 0.2);
    BallColor = color(255, 50, 50);
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
    line(pos.x, pos.y, pos.x, pos.y+10);

    // eyes
    noStroke();
    fill(255, 255, 255);
    float d = map(vel.y, -BALL_BOUNCE_BACK_VEL, BALL_BOUNCE_BACK_VEL, +12, -2);    
    ellipse(pos.x-b4, pos.y-d, BALL_SIZE/1.8, BALL_SIZE/1.6);
    ellipse(pos.x+b4, pos.y-d, BALL_SIZE/1.8, BALL_SIZE/1.6);
    fill(0, 0, 0);
    ellipse(pos.x-b4, pos.y-d, BALL_SIZE/4, BALL_SIZE/4);
    ellipse(pos.x+b4, pos.y-d, BALL_SIZE/4, BALL_SIZE/4);
  }

  void bounceBack(Step step) {
    float newVel = vel.y;
    if (step.type == STEP_TYPE_NORMAL) 
      vel.y = BALL_BOUNCE_BACK_VEL;
    else if (step.type == STEP_TYPE_JUMPER) 
      vel.y = 2 * BALL_BOUNCE_BACK_VEL;
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
  int type;

  Step(float x, float y) {  
    pos = new PVector(x, y, 0);
    color(0, 200, 0);
    weight = 5;
    type = STEP_TYPE_NORMAL;
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

  color getColor()
  {
    color col = color(200, 200, 200);
    if (type == STEP_TYPE_NORMAL)
      col = color(0, 200, 0);
    else if (type == STEP_TYPE_JUMPER)
      col = color(200, 0, 0);
    else if (type == STEP_TYPE_ONCE)
      col = color(150, 150, 150);
    return col;
  }

  void playSound()
  {
    println("pay Sound:"+ type);
    player[type].cue(0);
    player[type].play();
  }
  
  boolean doAction()
  {
    playSound();
    if (type == STEP_TYPE_ONCE)
      return false;
    else
      return true;
  }

  void draw()
  {
    stroke(getColor());
    strokeWeight(weight); 
    line(left(), y(), right(), y());
  }
} 





void setup()
{
  // default size
  size(400, 600);

  maxim = new Maxim(this);
  player = new AudioPlayer[MAX_AUDIOPLAYER];
  for (int i=0; i<MAX_AUDIOPLAYER; i++) {
    player[i] = maxim.loadFile("boink" + i + ".wav");
    player[i].setLooping(false);
  }


  ball = new Ball(300, 300);
  aStep = new Step[MAX_STEP];
  for (int i=0; i<MAX_STEP; i++) {
    aStep[i] = new Step(random(0+STEP_SIZE, width-STEP_SIZE), 
    random(10, 1*height)-0*height);
  }
}

void draw()
{
  background(0);

  textSize(12);
  fill(100, 100, 100);
  text(score, 30, 30);

  ball.update();
  ball.addXGravity(xGravity);

  //scrolling of the steps down
  float yMid = height/2;
  if (ball.pos.y < yMid) {
    float d = yMid - ball.pos.y;
    score += d;
    // correct the ball position - on the half y
    ball.pos.y = yMid;
    for (int i=0; i<MAX_STEP; i++) {
      // scroll down the steps
      if (aStep[i] != null) 
        aStep[i].pos.y += d;
    }
  }

  for (int i=0; i<MAX_STEP; i++)  {
    if (aStep[i] != null  &&  !aStep[i].visible()) {
      aStep[i].pos.y = -10;
      aStep[i].pos.x = random(0, width);
      aStep[i].type = (int)random(STEP_TYPE_NORMAL, STEP_TYPE_MAX);
    }
  } 

  for (int i=0; i<MAX_STEP; i++) {
    if (aStep[i] != null)  {   
      aStep[i].draw();
      if (ball.reflect( aStep[i] )) {
        ball.bounceBack(aStep[i]);
        if (! aStep[i].doAction())
          aStep[i] = null;
      }
    }
  }
  ball.draw();
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

